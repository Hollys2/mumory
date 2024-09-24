import MapKit
import CoreLocation
import Firebase

public enum MapConstant {
    // 할리스 강남역2점
    public static var defaultCoordinate2D = CLLocationCoordinate2D(latitude: 37.50039, longitude: 127.0270)
    public static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    public static let defaultSouthKoreaCoordinate2D = CLLocationCoordinate2D(latitude: 36.32553558831784, longitude: 127.96146817978284)
    public static let defaultSouthKoreaSpan = MKCoordinateSpan(latitudeDelta: 8.043374432964534, longitudeDelta: 6.711901555855434)
    
    public static let defaultRegion = MKCoordinateRegion(center: defaultCoordinate2D, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
    public static let defaultDistance: CLLocationDistance = 1000
}

public struct MapManager {
    
    public static func getLocationModel(location: CLLocation, completion: @escaping (LocationModel) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                print("Error: ", error?.localizedDescription ?? "Unknown error")
                return }
            
            let locationTitle = placemark.name ?? ""
            let locationSubtitle = (placemark.locality ?? "") + " " + (placemark.thoroughfare ?? "") + " " + (placemark.subThoroughfare ?? "")
            
            let locationModel = LocationModel(geoPoint: GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), locationTitle: locationTitle, locationSubtitle: locationSubtitle, country: placemark.country ?? "", administrativeArea: placemark.administrativeArea ?? "")
            
            completion(locationModel)
        }
    }
    
    public static func getLocationModel2(location: CLLocation) async -> LocationModel? {
        return await withCheckedContinuation { continuation in
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                guard let placemark = placemarks?.first, error == nil else {
                    print("Error: ", error?.localizedDescription ?? "Unknown error")
                    continuation.resume(returning: nil)  // 오류 발생 시 nil 반환
                    return
                }
                
                let locationTitle = placemark.name ?? ""
                let locationSubtitle = (placemark.locality ?? "") + " " + (placemark.thoroughfare ?? "") + " " + (placemark.subThoroughfare ?? "")
                
                let locationModel = LocationModel(
                    geoPoint: GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
                    locationTitle: locationTitle,
                    locationSubtitle: locationSubtitle,
                    country: placemark.country ?? "",
                    administrativeArea: placemark.administrativeArea ?? ""
                )
                
                continuation.resume(returning: locationModel)
            }
        }
    }

}




