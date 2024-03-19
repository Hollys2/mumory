import MapKit
import CoreLocation

public enum MapConstant {
    // 할리스 강남역2점
    public static let defaultCoordinate2D = CLLocationCoordinate2D(latitude: 37.50039, longitude: 127.0270)
    public static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    public static let distance: CLLocationDistance = 1000
    
    public static let boundaries = [
        "서울특별시": (
            latitude: (min: 37.426, max: 37.701),
            longitude: (min: 126.764, max: 127.183)
        ),
        "부산광역시": (
            latitude: (min: 35.052, max: 35.245),
            longitude: (min: 128.960, max: 129.210)
        ),
        "인천광역시": (
            latitude: (min: 37.354, max: 37.469),
            longitude: (min: 126.416, max: 126.733)
        ),
        "대구광역시": (
            latitude: (min: 35.798, max: 35.888),
            longitude: (min: 128.543, max: 128.711)
        ),
        "경기도": (
            latitude: (min: 36.999, max: 38.000),
            longitude: (min: 126.600, max: 127.700)
        ),
        "제주도": (
            latitude: (min: 33.100, max: 34.000),
            longitude: (min: 126.100, max: 127.000)
        )
    ]
}
