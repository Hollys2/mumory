//
//  HomeMapView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/17.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import MapKit
import MusicKit
import Core
import Shared

struct HomeMapViewRepresentable: UIViewRepresentable {
    
    typealias UIViewType = MKMapView
    
    @Binding var annotationSelected: Bool
    @Binding var region: MKCoordinateRegion?
    
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    func makeUIView(context: Context) -> UIViewType {
        let mapView: MKMapView = .init()
        
        mapView.mapType = .mutedStandard
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        
        mapView.setRegion(MKCoordinateRegion(center: MapConstant.defaultCoordinate2D, span: MapConstant.defaultSpan), animated: true)
        
        if let encodedCoordinate = UserDefaults.standard.data(forKey: "lastCenterCoordinate"),
           let decodedCoordinate = try? JSONDecoder().decode(CodableCoordinate.self, from: encodedCoordinate),
           let encodedSpan = UserDefaults.standard.data(forKey: "lastCenterSpan"),
           let decodedSpan = try? JSONDecoder().decode(CodableCoordinateSpan.self, from: encodedSpan) {
            mapView.setRegion(MKCoordinateRegion(center: decodedCoordinate.toCoordinate, span: decodedSpan.toSpan), animated: true)
        }
        
        context.coordinator.mapView = mapView
        context.coordinator.setGPSButton()
        context.coordinator.setCompassButton()
        
        mapView.delegate = context.coordinator
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tappedMap))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // Remove annotations that are no longer in myMumoryAnnotations
//        let currentAnnotationIDs = Set(uiView.annotations.compactMap { ($0 as? Mumory)?.id })
        let newAnnotationIDs = Set(self.mumoryDataViewModel.myMumoryAnnotations.map { $0.id })
        let annotationsToRemove = uiView.annotations.compactMap { $0 as? Mumory }.filter { !newAnnotationIDs.contains($0.id) }
        uiView.removeAnnotations(annotationsToRemove)
        
        for annotation in self.mumoryDataViewModel.myMumoryAnnotations {
            // Find the corresponding annotation in the map view
            if let existingAnnotation = uiView.annotations.first(where: { ($0 as? Mumory)?.id == annotation.id }) as? Mumory {
                // Compare properties of the annotation in the map view with the updated annotation
                if existingAnnotation != annotation {
                    // Remove the existing annotation from the map view
                    uiView.removeAnnotation(existingAnnotation)
                    
                    // Add the updated annotation to the map view
//                    uiView.addAnnotation(annotation)
                }
            }
        }
        
        let sortedAnnotations = self.mumoryDataViewModel.myMumoryAnnotations.sorted(by: { $0.date > $1.date })
        uiView.addAnnotations(sortedAnnotations)

        if let newRegion = self.region {
            uiView.setRegion(newRegion, animated: true)
            DispatchQueue.main.async {
                self.region = nil
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension HomeMapViewRepresentable {
    
    class Coordinator: NSObject {
        
        let parent: HomeMapViewRepresentable
        var mapView: MKMapView?
        var isRegionUpdated: Bool = false
        
        init(parent: HomeMapViewRepresentable) {
            self.parent = parent
            super.init()
        }
        
        @objc func tappedMap(sender: UITapGestureRecognizer) {
            guard let mapView = self.mapView else { return }
            
            if !parent.annotationSelected {
                print("탭맵")
                if let selectedAnnotation = mapView.selectedAnnotations.first {
                    mapView.deselectAnnotation(selectedAnnotation, animated: false)
                }
            }
        }
        
        func setGPSButton() {
            guard let mapView = self.mapView else { return }
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: mapView.bounds.width - 48 - 22, y: mapView.bounds.height - 48 - 24, width: 48, height: 48)
            button.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
            button.setImage(SharedAsset.gps.image, for: .normal)
            button.addTarget(self, action:#selector(self.tappedGPSButton), for:.touchUpInside)
            
            mapView.addSubview(button)
        }
        
        func setCompassButton() {
            guard let mapView = self.mapView else { return }
            
            let compassButton = MKCompassButton(mapView: mapView)
            compassButton.compassVisibility = .adaptive
            compassButton.frame = CGRect(x: mapView.bounds.width - compassButton.bounds.width - 22, y: mapView.bounds.height - compassButton.bounds.height - 87, width: 48, height: 48)
            compassButton.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
            
            mapView.addSubview(compassButton)
        }
        
        func setPlayingMusicBar() {
            
        }
        
        @objc private func tappedGPSButton() {
            guard let mapView = mapView, let userLocation = mapView.userLocation.location else { return }
            
            let regionRadius: CLLocationDistance = 1000
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            mapView.setRegion(region, animated: true)
        }
        
        func moveFocusOnUserLocation() {
            guard let mapView = self.mapView else { return }
            print("moveFocusOnUserLocation")
            mapView.showsUserLocation = true
            mapView.setUserTrackingMode(.follow, animated: true)
        }
        
    }
}

extension HomeMapViewRepresentable.Coordinator: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !isRegionUpdated {
            mapView.setRegion(MKCoordinateRegion(center: userLocation.coordinate, span: MapConstant.defaultSpan), animated: true)
            isRegionUpdated = true
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let coordinate = CodableCoordinate(coordinate: mapView.centerCoordinate)
        let span = CodableCoordinateSpan(span: mapView.region.span)

        let encodedCoordinate = try? JSONEncoder().encode(coordinate)
        let encodedSpan = try? JSONEncoder().encode(span)
        UserDefaults.standard.set(encodedCoordinate, forKey: "lastCenterCoordinate")
        UserDefaults.standard.set(encodedSpan, forKey: "lastCenterSpan")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "CustomUserLocation") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "CustomUserLocation")
            
            annotationView.image = SharedAsset.userLocation.image
            annotationView.frame = CGRect(x: 0, y: 0, width: 47, height: 47)
            
            annotationView.zPriority = .max
            
            return annotationView
        } else if annotation is Mumory {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "MumoryAnnotation") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "MumoryAnnotation")
            
            annotationView.image = SharedAsset.musicPin.image
            annotationView.frame = CGRect(x: 0, y: 0, width: 74, height: 81)
            
            if let mumoryAnnotation = annotation as? Mumory, let url = mumoryAnnotation.musicModel.artworkUrl {
                let artwork = AsyncImageView()
                artwork.frame = CGRect(x: 6.74, y: 6.74, width: 60.65238, height: 60.65238)
                artwork.layer.cornerRadius = 12
                artwork.clipsToBounds = true
                artwork.loadImage(from: url)
                annotationView.addSubview(artwork)
                
                if !mumoryAnnotation.isPublic {
                    let imageView = UIImageView(frame: CGRect(x: (annotationView.frame.width - 34) / 2, y: (annotationView.frame.width - 34) / 2, width: 34, height: 34))
                    let lockImage: UIImage = SharedAsset.musicPinPrivate.image
                    imageView.image = lockImage
                    annotationView.addSubview(imageView)
                }
            } else {
                print("ERROR: NO URL")
            }

            annotationView.clusteringIdentifier = "ClusterView"
            
            return annotationView
        } else if let cluster = annotation as? MKClusterAnnotation {
            
            let memberAnnotations = cluster.memberAnnotations.compactMap { $0 as? Mumory }
            let sortedAnnotations = memberAnnotations.sorted { $0.date > $1.date }
            
            let topAnnotation = sortedAnnotations.first
            let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: "ClusterView") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "ClusterView")
            
            print("cluster.memberAnnotations.count: \(cluster.memberAnnotations.count)")
            
            clusterView.isUserInteractionEnabled = true
            clusterView.image = SharedAsset.musicPin.image
            clusterView.frame = CGRect(x: 0, y: 0, width: 74, height: 81)
            
            if let mumoryAnnotation = topAnnotation, let url = mumoryAnnotation.musicModel.artworkUrl {
                
                let artwork = AsyncImageView()
                artwork.frame = CGRect(x: 6.74, y: 6.74, width: 60.65238, height: 60.65238)
                artwork.layer.cornerRadius = 12
                artwork.clipsToBounds = true
                artwork.loadImage(from: url)
                clusterView.addSubview(artwork)
            } else {
                print("ERROR: NO URL2")
            }
            
            if cluster.memberAnnotations.count > 1 {
                let countView = CountView(text: String(cluster.memberAnnotations.count))
                let hostingController = UIHostingController(rootView: countView)
                clusterView.addSubview(hostingController.view)
            }
            
            return clusterView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        if let mumoryAnnotation = annotation as? Mumory {
            let region = MKCoordinateRegion(center: annotation.coordinate, span: MapConstant.defaultSpan)
            mapView.setRegion(region, animated: true)
            self.parent.annotationSelected = true
            self.parent.mumoryDataViewModel.mumoryCarouselAnnotations = [mumoryAnnotation]
            
            print("didSelect MumoryAnnotation: \(mumoryAnnotation)")
        } else if annotation is MKUserLocation {
            print("didSelect User Location")
        } else if let cluster = annotation as? MKClusterAnnotation {
            self.parent.annotationSelected = true
            
            let memberAnnotations = cluster.memberAnnotations.compactMap { $0 as? Mumory }
            
            let sortedAnnotations = memberAnnotations.sorted { $0.date > $1.date }
            self.parent.mumoryDataViewModel.mumoryCarouselAnnotations = sortedAnnotations
                
            print("didSelect cluster: \(cluster)")
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("didDeselect")
        DispatchQueue.main.async {
            self.parent.annotationSelected = false
        }
    }
}

class AsyncImageView: UIImageView {
    
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            }
        }.resume()
    }
}

struct CountSwiftUIView: View {
    
    let text: String
    
    @State private var textWidth: CGFloat = .zero
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 0) {
            Text("\(text)")
                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .frame(minWidth: 9)
                .frame(height: 10)
                .background() {
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                self.textWidth = geometry.size.width
                            }
                    }
                }
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 8)
        .background(SharedAsset.mainColor.swiftUIColor)
        .cornerRadius(12)
        .offset(x: (self.textWidth + 16) / 2 + 56, y: 12 - 6)
        
    }
}

struct CountView: UIViewRepresentable {
    
    let text: String
    
    init(text: String) {
        self.text = text
    }
    
    func makeUIView(context: Context) -> UIView {
        let hostingController = UIHostingController(rootView: CountSwiftUIView(text: text))
        let hostingView = hostingController.view!
        
        hostingView.backgroundColor = .clear
        
        return hostingView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct CodableCoordinate: Codable {
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees

    init(coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }
    
    var toCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct CodableCoordinateSpan: Codable {
    var latitudeDelta: CLLocationDegrees
    var longitudeDelta: CLLocationDegrees

    init(span: MKCoordinateSpan) {
        latitudeDelta = span.latitudeDelta
        longitudeDelta = span.longitudeDelta
    }

    var toSpan: MKCoordinateSpan {
        return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
}
