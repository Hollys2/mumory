//
//  FriendMumoryMapView.swift
//  Shared
//
//  Created by 다솔 on 2024/08/24.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import MapKit


public struct FriendMumoryMapView: View {
    
    @State private var region: MKCoordinateRegion = MapConstant.defaultRegion

    let mumorys: [Mumory]
    let user: UserProfile
    var isFriendPage: Bool?
    
    @EnvironmentObject private var appCoordinator: AppCoordinator
    
    public init(mumorys: [Mumory], user: UserProfile, isFriendPage: Bool? = nil) {
        self._region = State(initialValue: MKCoordinateRegion(center: MapConstant.defaultSouthKoreaCoordinate2D, span: MapConstant.defaultSouthKoreaSpan))

        self.mumorys = mumorys
        self.user = user
        self.isFriendPage = isFriendPage
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            
            FriendMapViewRepresentable(friendMumorys: self.mumorys)
            
            HStack {
                
                Color.clear
                    .frame(width: 30, height: 30)
                
                Spacer()
                
                Text("\(self.user.nickname)님의 뮤모리")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    self.appCoordinator.isMumoryMapViewShown = false
                } label: {
                    SharedAsset.closeButtonMumoryDetailMap.swiftUIImage
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .padding(.top, self.getSafeAreaInsets().top)
            .padding(.horizontal, 20)
            .background(Color(red: 0.09, green: 0.09, blue: 0.09, opacity: 0.898))
        }
        .ignoresSafeArea()
    }
}

public struct FriendMapViewRepresentable: UIViewRepresentable {
    
    public typealias UIViewType = MKMapView
    
    let friendMumorys: [Mumory]
    @State private var isFirst: Bool = false
    
    public init(friendMumorys: [Mumory]) {
        self.friendMumorys = friendMumorys
    }
    
    public func makeUIView(context: Context) -> UIViewType {
        let mapView: MKMapView = .init()
        
        mapView.delegate = context.coordinator
        mapView.overrideUserInterfaceStyle = .light
        mapView.mapType = .mutedStandard
        mapView.showsUserLocation = true
        mapView.showsCompass = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = false
        
        mapView.setRegion(MKCoordinateRegion(center: self.friendMumorys.isEmpty ? MapConstant.defaultSouthKoreaCoordinate2D : self.friendMumorys[0].coordinate, span: self.friendMumorys.isEmpty ? MapConstant.defaultSouthKoreaSpan : MapConstant.defaultSpan), animated: true)
        context.coordinator.mapView = mapView
                
        return mapView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        let mumoryIds = self.friendMumorys.map { $0.id }
        let annotationsToRemove = uiView.annotations.compactMap { $0 as? Mumory }.filter { !mumoryIds.contains($0.id) }
        uiView.removeAnnotations(annotationsToRemove)
        
        for annotation in self.friendMumorys {
            if let existingAnnotation = uiView.annotations.first(where: { ($0 as? Mumory)?.id == annotation.id }) as? Mumory {
                if existingAnnotation != annotation {
                    uiView.removeAnnotation(existingAnnotation)
                }
            }
        }
        
        uiView.addAnnotations(self.friendMumorys)
        
        if !self.isFirst {
            uiView.setRegion(MKCoordinateRegion(center: self.friendMumorys.isEmpty ? MapConstant.defaultSouthKoreaCoordinate2D : self.friendMumorys[0].coordinate, span: self.friendMumorys.isEmpty ? MapConstant.defaultSouthKoreaSpan : MapConstant.defaultSpan), animated: true)
            DispatchQueue.main.async {
                self.isFirst = true
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension FriendMapViewRepresentable {
    
    public class Coordinator: NSObject {
        let parent: FriendMapViewRepresentable
        var mapView: MKMapView?
        var isRegionUpdated: Bool = false
        
        public init(parent: FriendMapViewRepresentable) {
            self.parent = parent
            super.init()
        }
        
        public func setCompassButton() {
            guard let mapView = self.mapView else { return }
            
            let compassButton = MKCompassButton(mapView: mapView)
            compassButton.compassVisibility = .adaptive
            compassButton.frame = CGRect(x: mapView.bounds.width - compassButton.bounds.width - 22, y: mapView.bounds.height - compassButton.bounds.height - 87, width: 48, height: 48)
            compassButton.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
            
            mapView.addSubview(compassButton)
        }
    }
}

extension FriendMapViewRepresentable.Coordinator: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        if !isRegionUpdated {
//            mapView.setRegion(MKCoordinateRegion(center: userLocation.coordinate, span: MapConstant.defaultSpan), animated: true)
//            isRegionUpdated = true
//        }
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        let coordinate = CodableCoordinate(coordinate: mapView.centerCoordinate)
//        let span = CodableCoordinateSpan(span: mapView.region.span)
//
//        let encodedCoordinate = try? JSONEncoder().encode(coordinate)
//        let encodedSpan = try? JSONEncoder().encode(span)
//        UserDefaults.standard.set(encodedCoordinate, forKey: "lastCenterCoordinate")
//        UserDefaults.standard.set(encodedSpan, forKey: "lastCenterSpan")
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {

        } else if annotation is Mumory {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "MumoryAnnotation") ?? MKAnnotationView(annotation: annotation, reuseIdentifier: "MumoryAnnotation")
            
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
                
                let text = "\(mumoryAnnotation.location.locationTitle)"
                // UILabel 생성
                let label = UILabel()
                label.text = text
                label.textColor = .white
                label.textAlignment = .center
                label.font = SharedFontFamily.Pretendard.medium.font(size: 16)
                
                // 최대 너비 설정
                label.preferredMaxLayoutWidth = 309
                
                // 두 줄로 제한
                label.numberOfLines = 2
                label.lineBreakMode = .byTruncatingTail

                
                // UILabel을 포함하는 UIView 생성
                let containerView = UIView()
                containerView.addSubview(label)
                
                // AutoLayout 설정
                label.translatesAutoresizingMaskIntoConstraints = false
                containerView.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                    
                    // 텍스트 좌우로 19포인트 씩 여백
                    label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
                    label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
                    
                    // 텍스트 상하로 12포인트 씩 여백
                    label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 9),
                    label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -9)
                ])

                containerView.layer.cornerRadius = 19.53
                containerView.backgroundColor = UIColor(red: 0.188, green: 0.188, blue: 0.188, alpha: 0.898)
                annotationView.addSubview(containerView)

                containerView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    containerView.bottomAnchor.constraint(equalTo: annotationView.topAnchor, constant: -2),
                    containerView.centerXAnchor.constraint(equalTo: annotationView.centerXAnchor)
                ])
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
            
            clusterView.isUserInteractionEnabled = true
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
            } else {
                print("ERROR: NO URL2")
            }
            
            if cluster.memberAnnotations.count > 1 {
//                let countView = CountView(text: String(cluster.memberAnnotations.count))
//                let hostingController = UIHostingController(rootView: countView)
//                hostingController.view.frame.origin = CGPoint(x: 74 - 5.5, y: 8)
//
//                clusterView.addSubview(hostingController.view)
            }
            return clusterView
        }
        return nil
    }
    
//    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
//        if let mumoryAnnotation = annotation as? Mumory {
//            let region = MKCoordinateRegion(center: annotation.coordinate, span: MapConstant.defaultSpan)
//            mapView.setRegion(region, animated: true)
//            self.parent.annotationSelected = true
//            self.parent.mumoryDataViewModel.mumoryCarouselAnnotations = [mumoryAnnotation]
//
//            print("didSelect MumoryAnnotation: \(mumoryAnnotation)")
//        } else if annotation is MKUserLocation {
//            print("didSelect User Location")
//        } else if let cluster = annotation as? MKClusterAnnotation {
//            self.parent.annotationSelected = true
//
//            let memberAnnotations = cluster.memberAnnotations.compactMap { $0 as? Mumory }
//
//            let sortedAnnotations = memberAnnotations.sorted { $0.date > $1.date }
//            self.parent.mumoryDataViewModel.mumoryCarouselAnnotations = sortedAnnotations
//
//            print("didSelect cluster: \(cluster)")
//        }
//
//    }
    
//    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//        print("didDeselect")
//        DispatchQueue.main.async {
//            self.parent.annotationSelected = false
//        }
//    }
}

public class AsyncImageView: UIImageView {
    public func loadImage(from url: URL) {
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
