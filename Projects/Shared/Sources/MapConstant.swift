import MapKit
import CoreLocation

public enum MapConstant {
    // 할리스 강남역2점
    public static let defaultCoordinate2D = CLLocationCoordinate2D(latitude: 37.50039, longitude: 127.0270)
    public static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    public static let distance: CLLocationDistance = 1000
}
