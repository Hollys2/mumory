import MapKit
import CoreLocation

public enum MapConstant {
    // 할리스 강남역2점
    public static let defaultCoordinate2D = CLLocationCoordinate2D(latitude: 37.50039, longitude: 127.0270)
    public static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    public static let defaultSouthKoreaCoordinate2D = CLLocationCoordinate2D(latitude: 36.32553558831784, longitude: 127.96146817978284)
    public static let defaultSouthKoreaSpan = MKCoordinateSpan(latitudeDelta: 8.043374432964534, longitudeDelta: 6.711901555855434)
    
    public static let defaultRegion = MKCoordinateRegion(center: defaultCoordinate2D, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
    public static let defaultDistance: CLLocationDistance = 1000
}
