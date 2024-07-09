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
    
    @Binding var isAnnotationTapped: Bool
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var locationManager: LocationManager
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView: MKMapView = .init()
        
        mapView.overrideUserInterfaceStyle = .light
        mapView.mapType = .mutedStandard
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        mapView.setRegion(MKCoordinateRegion(center: MapConstant.defaultSouthKoreaCoordinate2D, span: MapConstant.defaultSouthKoreaSpan), animated: true)
        
        if let encodedCoordinate = UserDefaults.standard.data(forKey: "lastCenterCoordinate"),
           let decodedCoordinate = try? JSONDecoder().decode(CodableCoordinate.self, from: encodedCoordinate),
           let encodedSpan = UserDefaults.standard.data(forKey: "lastCenterSpan"),
           let decodedSpan = try? JSONDecoder().decode(CodableCoordinateSpan.self, from: encodedSpan) {
            mapView.setRegion(MKCoordinateRegion(center: decodedCoordinate.toCoordinate, span: decodedSpan.toSpan), animated: true)
        }
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tappedMap))
        
        mapView.addGestureRecognizer(tapGesture)
        
        mapView.delegate = context.coordinator
        
        context.coordinator.mapView = mapView
        context.coordinator.setGPSButton()
        context.coordinator.setCompassButton()
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let mumoryIds: [String] = self.mumoryDataViewModel.myMumorys.map { $0.id ?? "" }
        let annotationsToRemove = self.mumoryDataViewModel.myMumorys.filter { !mumoryIds.contains($0.id ?? "") }
//        let annotationsToRemove = uiView.annotations.compactMap { $0 as? Mumory }.filter { !mumoryIds.contains($0.id) }
        
        uiView.removeAnnotations(annotationsToRemove)
        
        for annotation in self.mumoryDataViewModel.myMumorys {
            if let existingAnnotation = uiView.annotations.first(where: { ($0 as? Mumory)?.id == annotation.id }) as? Mumory {
                if existingAnnotation != annotation {
                    uiView.removeAnnotation(existingAnnotation)
                }
            }
        }
        
        uiView.addAnnotations(self.mumoryDataViewModel.myMumorys)
        
        if let newRegion = self.appCoordinator.createdMumoryRegion {
            uiView.setRegion(newRegion, animated: true)
            DispatchQueue.main.async {
                self.appCoordinator.createdMumoryRegion = nil
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
        var isFirstRegionUpdated: Bool = false
        
        init(parent: HomeMapViewRepresentable) {
            self.parent = parent
//            super.init()
        }
        
        func setGPSButton() {
            guard let mapView = self.mapView else { return }
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: mapView.bounds.width - 48 - 15, y: mapView.bounds.height - 48 - 24, width: 48, height: 48)
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
        
        @objc func tappedMap(sender: UITapGestureRecognizer) {
            guard let mapView = self.mapView else { return }
            
            if !parent.isAnnotationTapped {
                if let selectedAnnotation = mapView.selectedAnnotations.first {
                    mapView.deselectAnnotation(selectedAnnotation, animated: false)
                }
            }
        }
        
        @objc private func tappedGPSButton() {
            guard let mapView = self.mapView,
                  let userLocation = mapView.userLocation.location else { return }
            
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: MapConstant.defaultSpan)
            
            mapView.setRegion(region, animated: true)
            
            switch CLLocationManager().authorizationStatus {
            case .notDetermined, .restricted, .denied:
                self.parent.locationManager.promptForLocationSettings()
            case .authorizedAlways, .authorizedWhenInUse:
                break
            @unknown default:
                break
            }
        }
    }
}

extension HomeMapViewRepresentable.Coordinator: MKMapViewDelegate {
    
    // 사용자 현재 위치 업데이트 됐을 때
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !self.isFirstRegionUpdated {
            mapView.setRegion(MKCoordinateRegion(center: userLocation.coordinate, span: MapConstant.defaultSpan), animated: true)
            self.isFirstRegionUpdated = true
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
            let annotationView: MKAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "CustomUserLocation") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "CustomUserLocation")
            
            annotationView.image = SharedAsset.userLocation.image
            annotationView.frame = CGRect(x: 0, y: 0, width: 47, height: 47)
            annotationView.zPriority = .max
            
            return annotationView
        } else if annotation is Mumory {
            let annotationView: MKAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "MumoryAnnotation") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "MumoryAnnotation")
            
            annotationView.image = SharedAsset.musicPin.image
            annotationView.frame = CGRect(x: 0, y: 0, width: 74, height: 81)
            
            if let mumoryAnnotation = annotation as? Mumory, let url = mumoryAnnotation.song.artworkUrl {
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
            }

            annotationView.clusteringIdentifier = "MumoryCluster"
            
            return annotationView
        } else if let cluster = annotation as? MKClusterAnnotation {
            let mumoryAnnotations = cluster.memberAnnotations.compactMap { $0 as? Mumory }
            let sortedAnnotations = mumoryAnnotations.sorted { $0.date > $1.date }
            let topAnnotation = sortedAnnotations.first
            let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: "MumoryCluster") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "MumoryCluster")
            
            clusterView.image = SharedAsset.musicPin.image
            clusterView.frame = CGRect(x: 0, y: 0, width: 74, height: 81)
            
            if let mumoryAnnotation = topAnnotation, let url = mumoryAnnotation.song.artworkUrl {
                let artwork = AsyncImageView()
                artwork.frame = CGRect(x: 6.74, y: 6.74, width: 60.65238, height: 60.65238)
                artwork.layer.cornerRadius = 12
                artwork.clipsToBounds = true
                artwork.loadImage(from: url)
                clusterView.addSubview(artwork)
                
                if !mumoryAnnotation.isPublic {
                    let imageView = UIImageView(frame: CGRect(x: (clusterView.frame.width - 34) / 2, y: (clusterView.frame.width - 34) / 2, width: 34, height: 34))
                    let lockImage: UIImage = SharedAsset.musicPinPrivate.image
                    imageView.image = lockImage
                    clusterView.addSubview(imageView)
                }
            }
            
            if cluster.memberAnnotations.count > 1 {
                //                                let countView = CountView(text: String(cluster.memberAnnotations.count))
                //                                let hostingController = UIHostingController(rootView: countView)
                //                                hostingController.view.frame.origin = CGPoint(x: 74 - 5.5, y: 8)
                //
                //                                clusterView.addSubview(hostingController.view)
                
                let label = CountUILabel(text: "\("99")")
                label.textInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
                label.font = SharedFontFamily.Pretendard.bold.font(size: 14)
                
                clusterView.addSubview(label)
                
                label.translatesAutoresizingMaskIntoConstraints = false
                let minWidthConstraint = label.widthAnchor.constraint(greaterThanOrEqualToConstant: 25)
                minWidthConstraint.priority = .required
                
                NSLayoutConstraint.activate([
                    //                    minWidthConstraint,
                    label.heightAnchor.constraint(equalToConstant: 24),
                    //                        label.topAnchor.constraint(equalTo: clusterView.topAnchor, constant: 0),
                    //                        label.leadingAnchor.constraint(equalTo: clusterView.leadingAnchor, constant: 74 - 5.5)
                ])
            }
            return clusterView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        if let mumoryAnnotation = annotation as? Mumory {
            self.parent.isAnnotationTapped = true
            self.parent.mumoryDataViewModel.mumoryCarouselAnnotations = [mumoryAnnotation]
            
            let region = MKCoordinateRegion(center: annotation.coordinate, span: MapConstant.defaultSpan)
            
            mapView.setRegion(region, animated: true)
            
            print("didSelect MumoryAnnotation: \(mumoryAnnotation)")
        } else if let cluster = annotation as? MKClusterAnnotation {
            self.parent.isAnnotationTapped = true
            
            let mumoryAnnotations = cluster.memberAnnotations.compactMap { $0 as? Mumory }
            
            let sortedAnnotations = mumoryAnnotations.sorted { $0.date > $1.date }
            
            self.parent.mumoryDataViewModel.mumoryCarouselAnnotations = sortedAnnotations
            
            print("didSelect cluster: \(cluster)")
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("didDeselect")
        DispatchQueue.main.async {
            self.parent.isAnnotationTapped = false
        }
    }
}

class CountUILabel: UILabel {
    
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        self.font = UIFont(name: SharedFontFamily.Pretendard.bold.name, size: 14)
        self.textColor = .black
        self.textAlignment = .center
        self.layer.backgroundColor = SharedAsset.mainColor.color.cgColor
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var textInsets = UIEdgeInsets.zero {
        didSet { setNeedsDisplay() }
    }
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        super.drawText(in: insetRect)
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
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

class AsyncImageView: UIImageView {
    
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            }
        }
        .resume()
    }
}
