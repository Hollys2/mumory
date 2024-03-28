import MapKit
import CoreLocation

public enum MapConstant {
    // 할리스 강남역2점
    public static let defaultCoordinate2D = CLLocationCoordinate2D(latitude: 37.50039, longitude: 127.0270)
    public static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    public static let defaultSouthKoreaCoordinate2D = CLLocationCoordinate2D(latitude: 36.32553558831784, longitude: 127.96146817978284)
    public static let defaultSouthKoreaSpan = MKCoordinateSpan(latitudeDelta: 8.043374432964534, longitudeDelta: 6.711901555855434)
    
    public static let defaultRegion = MKCoordinateRegion(center: defaultCoordinate2D, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
    public static let distance: CLLocationDistance = 1000
    
    public static let boundaries = [
        "서울특별시": (
            latitude: (min: 37.426, max: 37.701),
            longitude: (min: 126.764, max: 127.183)
        ),
        "부산광역시": (
            latitude: (min: 35.052, max: 35.245),
            longitude: (min: 129.009, max: 129.394)
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
        ),
        "대전광역시": (
            latitude: (min: 36.250, max: 36.482),
            longitude: (min: 127.306, max: 127.477)
        ),
        "광주광역시": (
            latitude: (min: 35.126, max: 35.230),
            longitude: (min: 126.791, max: 126.926)
        ),
        "울산광역시": (
            latitude: (min: 35.495, max: 35.600),
            longitude: (min: 129.220, max: 129.342)
        ),
        "강원도": (
            latitude: (min: 36.000, max: 38.000),
            longitude: (min: 127.000, max: 129.000)
        ),
        "충청북도": (
            latitude: (min: 36.000, max: 37.000),
            longitude: (min: 127.000, max: 128.000)
        ),
        "충청남도": (
            latitude: (min: 36.000, max: 37.000),
            longitude: (min: 126.000, max: 127.000)
        ),
        "전라북도": (
            latitude: (min: 35.000, max: 36.000),
            longitude: (min: 127.000, max: 128.000)
        ),
        "전라남도": (
            latitude: (min: 34.000, max: 35.000),
            longitude: (min: 125.000, max: 127.000)
        ),
        "경상북도": (
            latitude: (min: 35.500, max: 37.000),
            longitude: (min: 128.000, max: 130.000)
        ),
        "경상남도": (
            latitude: (min: 34.000, max: 36.000),
            longitude: (min: 127.000, max: 129.000)
        ),
        "세종특별자치시": (
            latitude: (min: 36.000, max: 37.000),
            longitude: (min: 127.000, max: 128.000)
        ),
        "영국🇬🇧": (
            latitude: (min: 49.7, max: 60.9),
            longitude: (min: -8.6, max: 2.3)
        ),
        "미국🇺🇸": (
            latitude: (min: 24.4, max: 49.4),
            longitude: (min: -125.0, max: -66.9)
        ),
        "이탈리아🇮🇹": (
            latitude: (min: 36.3, max: 47.1),
            longitude: (min: 6.6, max: 18.5)
        ),
        "프랑스🇫🇷": (
            latitude: (min: 41.3, max: 51.1),
            longitude: (min: -5.2, max: 9.6)
        ),
        "독일🇩🇪": (
            latitude: (min: 47.3, max: 55.2),
            longitude: (min: 5.9, max: 15.1)
        ),
        "일본🇯🇵": (
            latitude: (min: 24.3, max: 45.5),
            longitude: (min: 122.9, max: 153.9)
        ),
        "중국🇨🇳": (
            latitude: (min: 18.2, max: 53.5),
            longitude: (min: 73.5, max: 135.0)
        ),
        "캐나다🇨🇦": (
            latitude: (min: 41.7, max: 83.1),
            longitude: (min: -140.0, max: -52.6)
        ),
        "오스트레일리아🇦🇹": (
            latitude: (min: -43.6, max: -10.1),
            longitude: (min: 113.1, max: 153.6)
        ),
        "브라질🇧🇷": (
            latitude: (min: -33.7, max: 5.3),
            longitude: (min: -73.8, max: -34.8)
        ),
        "인도🇮🇳": (
            latitude: (min: 6.7, max: 35.7),
            longitude: (min: 68.1, max: 97.4)
        ),
        "러시아🇷🇺": (
            latitude: (min: 41.2, max: 81.9),
            longitude: (min: 19.7, max: 190.0)
        ),
        "호주🇦🇺": (
            latitude: (min: -43.6, max: -10.1),
            longitude: (min: 113.1, max: 153.6)
        ),
        "멕시코🇲🇽": (
            latitude: (min: 14.5, max: 32.7),
            longitude: (min: -117.3, max: -86.6)
        ),
        "인도네시아🇮🇩": (
            latitude: (min: -11.0, max: 6.2),
            longitude: (min: 94.9, max: 141.0)
        ),
        "터키🇹🇷": (
            latitude: (min: 35.8, max: 42.1),
            longitude: (min: 25.0, max: 44.8)
        ),
        "사우디아라비아🇸🇦": (
            latitude: (min: 15.6, max: 32.2),
            longitude: (min: 34.4, max: 55.7)
        ),
        "스페인🇪🇸": (
            latitude: (min: 27.6, max: 43.8),
            longitude: (min: -18.2, max: 4.3)
        ),
        "네덜란드🇳🇱": (
            latitude: (min: 50.8, max: 53.6),
            longitude: (min: 3.3, max: 7.3)
        ),
        "스위스🇨🇭": (
            latitude: (min: 45.8, max: 47.8),
            longitude: (min: 5.9, max: 10.5)
        ),
        "아르헨티나🇦🇷": (
            latitude: (min: -55.1, max: -21.8),
            longitude: (min: -73.6, max: -53.7)
        ),
        "스웨덴🇸🇪": (
            latitude: (min: 55.1, max: 69.1),
            longitude: (min: 10.6, max: 24.2)
        ),
        "폴란드🇵🇱": (
            latitude: (min: 49.0, max: 54.8),
            longitude: (min: 14.1, max: 24.1)
        ),
        "벨기에🇧🇪": (
            latitude: (min: 49.5, max: 51.5),
            longitude: (min: 2.5, max: 6.5)
        ),
        "태국🇹🇭": (
            latitude: (min: 5.6, max: 20.5),
            longitude: (min: 97.3, max: 105.7)
        ),
        "이란🇮🇷": (
            latitude: (min: 24.4, max: 39.8),
            longitude: (min: 44.0, max: 63.3)
        ),
        "오스트리아🇦🇹": (
            latitude: (min: 46.4, max: 49.2),
            longitude: (min: 9.5, max: 17.2)
        ),
        "노르웨이🇳🇴": (
            latitude: (min: 57.7, max: 71.2),
            longitude: (min: 4.9, max: 31.2)
        ),
        "아랍에미리트🇦🇪": (
            latitude: (min: 22.6, max: 26.1),
            longitude: (min: 51.6, max: 56.4)
        ),
        "나이지리아🇳🇬": (
            latitude: (min: 4.3, max: 13.9),
            longitude: (min: 2.7, max: 14.6)
        ),
        "기타🏁": (
            latitude: (min: -90.0, max: 90.0),
            longitude: (min: -180.0, max: 180.0)
        )
    ]
}
