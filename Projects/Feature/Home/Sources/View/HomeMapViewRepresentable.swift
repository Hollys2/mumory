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
    
    @State var count: Int = 1
    @Binding var annotationSelected: Bool
    @Binding var region: MKCoordinateRegion?
    
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var locationManager: LocationManager
    
    func makeUIView(context: Context) -> UIViewType {
        print("@@makeUIView")
        
        let mapView: MKMapView = .init()
        
        mapView.mapType = .mutedStandard
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.isPitchEnabled = false
        //        mapView.userTrackingMode = .follow 권한 동의 후에
        
        mapView.setRegion(MKCoordinateRegion(center: MapConstant.defaultCoordinate2D, span: MapConstant.defaultSpan), animated: true)
        
        if let currentLocation = locationManager.currentLocation {
            mapView.setRegion(MKCoordinateRegion(center: currentLocation.coordinate, span: MapConstant.defaultSpan), animated: true)
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
//        uiView.removeAnnotations(uiView.annotations)

        
        let sortedAnnotations = self.mumoryDataViewModel.mumoryAnnotations.sorted(by: { $0.date > $1.date })
        uiView.addAnnotations(sortedAnnotations)
//        if mumoryDataViewModel.isFetchFinished {
//            uiView.addAnnotations(mumoryDataViewModel.mumoryAnnotations)
//        }
        
//        let groupedAnnotations = Dictionary(grouping: annotations, by: { $0.date })
//
//        // Add grouped annotations to the map
//        for (_, groupedAnnotations) in groupedAnnotations {
//            let cluster = MKClusterAnnotation(memberAnnotations: groupedAnnotations)
//            uiView.addAnnotation(cluster)
//        }
        
        if let newRegion = self.region {
            uiView.setRegion(newRegion, animated: true)
            DispatchQueue.main.async {
                self.region = nil
            }
        }
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(parent: self)
    }
    
    func distanceBetweenCoordinates(_ coord1: CLLocationCoordinate2D, _ coord2: CLLocationCoordinate2D) -> CLLocationDistance {
        let location1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let location2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
        return location1.distance(from: location2)
    }
    
    private func groupAndShowAnnotations(on mapView: MKMapView) {
        var groupedAnnotations: [[MumoryAnnotation]] = []
        
        for annotation in mumoryDataViewModel.mumoryAnnotations {
            var foundGroup = false
            
            for (index, group) in groupedAnnotations.enumerated() {
                if let firstAnnotation = group.first,
                   distanceBetweenCoordinates(firstAnnotation.coordinate, annotation.coordinate) < 100 {
                    groupedAnnotations[index].append(annotation)
                    foundGroup = true
                    break
                }
            }
            
            if !foundGroup {
                groupedAnnotations.append([annotation])
            }
        }
        
        for group in groupedAnnotations {
            if group.count > 1 {
                // Add logic to display number on the map
                let numberAnnotation = MKPointAnnotation()
                numberAnnotation.coordinate = group[0].coordinate // Use the coordinate of the first annotation in the group
                numberAnnotation.title = "\(group.count)"
                
                mapView.addAnnotation(numberAnnotation)
                
                print("count: \(group.count)")
                DispatchQueue.main.async {
                    self.count = group.count
                }
            }
        }
    }
    
}

extension HomeMapViewRepresentable {
    
    class MapViewCoordinator: NSObject {
        
        let parent: HomeMapViewRepresentable
        var mapView: MKMapView?
        
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

extension HomeMapViewRepresentable.MapViewCoordinator: MKMapViewDelegate {
    
    // 사용자의 현재 위치가 변할 때
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print("didUpdate in MKMapViewDelegate")
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        //        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "CustomUserLocation") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "CustomUserLocation")
            
            annotationView.image = SharedAsset.userLocation.image
            annotationView.frame = CGRect(x: 0, y: 0, width: 47, height: 47)
            
            annotationView.zPriority = .max
            
            return annotationView
        } else if annotation is MumoryAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "MumoryAnnotation") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "MumoryAnnotation")
            
            annotationView.image = SharedAsset.musicPin.image
            annotationView.frame = CGRect(x: 0, y: 0, width: 74, height: 81)
            
            if let mumoryAnnotation = annotation as? MumoryAnnotation, let url = mumoryAnnotation.musicModel.artworkUrl {
                let artwork = AsyncImageView()
                artwork.frame = CGRect(x: 6.74, y: 6.74, width: 60.65238, height: 60.65238)
                artwork.layer.cornerRadius = 12
                artwork.clipsToBounds = true
                artwork.loadImage(from: url)
                annotationView.addSubview(artwork)
            } else {
                print("ERROR: NO URL222")
            }

            annotationView.clusteringIdentifier = "ClusterView"
            
            return annotationView
        } else if let cluster = annotation as? MKClusterAnnotation {
            
//            let sortedAnnotations = cluster.memberAnnotations.sorted { ($0 as? MumoryAnnotation)?.date ?? Date() > ($1 as? MumoryAnnotation)?.date ?? Date() }
            let memberAnnotations = cluster.memberAnnotations.compactMap { $0 as? MumoryAnnotation }
            let sortedAnnotations = memberAnnotations.sorted { $0.date > $1.date }
            
            let topAnnotation = sortedAnnotations.first
//            let topAnnotation = cluster.memberAnnotations.first
            let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: "ClusterView") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "ClusterView")
            
            print("cluster.memberAnnotations.count: \(cluster.memberAnnotations.count)")
            
            clusterView.isUserInteractionEnabled = true
            clusterView.image = SharedAsset.musicPin.image
            clusterView.frame = CGRect(x: 0, y: 0, width: 74, height: 81)
            
            if let mumoryAnnotation = topAnnotation as? MumoryAnnotation, let url = mumoryAnnotation.musicModel.artworkUrl {
                
                let artwork = AsyncImageView()
                artwork.frame = CGRect(x: 6.74, y: 6.74, width: 60.65238, height: 60.65238)
                artwork.layer.cornerRadius = 12
                artwork.clipsToBounds = true
                artwork.loadImage(from: url)
                clusterView.addSubview(artwork)
            } else {
                print("ERROR: NO URL222")
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
    
    //    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
    //        let nonUserLocationAnnotations = memberAnnotations.filter { !($0 is MKUserLocation) }
    //
    //        let cluster = MKClusterAnnotation(memberAnnotations: nonUserLocationAnnotations)
    //        return cluster
    //    }
    
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        //        if annotation is MumoryAnnotation {
        //            self.parent.annotationSelected = true
        //            print("didSelect: \(annotation)")
        //        }
        
        if let mumoryAnnotation = annotation as? MumoryAnnotation {
            self.parent.annotationSelected = true
            self.parent.mumoryDataViewModel.mumoryCarouselAnnotations = [mumoryAnnotation]
            print("didSelect MumoryAnnotation: \(mumoryAnnotation)")
        } else if annotation is MKUserLocation {
            print("didSelect User Location")
        } else if let cluster = annotation as? MKClusterAnnotation {
            self.parent.annotationSelected = true
            
            let memberAnnotations = cluster.memberAnnotations.compactMap { $0 as? MumoryAnnotation }
            
            let sortedAnnotations = memberAnnotations.sorted { $0.date > $1.date }
            self.parent.mumoryDataViewModel.mumoryCarouselAnnotations = sortedAnnotations
                
            
            print("didSelect cluster: \(cluster)")
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("didDeselect")
        self.parent.annotationSelected = false
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
