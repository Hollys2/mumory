import SwiftUI

public struct BlurView: UIViewRepresentable {
    
    public typealias UIViewType = UIVisualEffectView
    
    var style: UIBlurEffect.Style

    public func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        
        return view
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
//
//
//struct MumoryDetailCommentSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        SampleView()
//    }
//}
