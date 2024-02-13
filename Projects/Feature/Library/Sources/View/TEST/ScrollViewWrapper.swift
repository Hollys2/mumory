import SwiftUI
import MusicKit

public struct ScrollViewWrapper<Content: View>: UIViewRepresentable {
    @Binding var contentOffset: CGPoint
    @Binding var scrollViewHeight: CGFloat
    @Binding var visibleHeight: CGFloat
    let content: () -> Content
    
    public init(
        contentOffset: Binding<CGPoint>,
        scrollViewHeight: Binding<CGFloat>,
        visibleHeight: Binding<CGFloat>,
        @ViewBuilder _ content: @escaping () -> Content) {
            self._contentOffset = contentOffset
            self._scrollViewHeight = scrollViewHeight
            self._visibleHeight = visibleHeight
            
            self.content = content
        }
    
    public func makeUIView(context: UIViewRepresentableContext<ScrollViewWrapper>) -> UIScrollView {
        let view = UIScrollView()
        view.delegate = context.coordinator
        
        // Instantiate the UIHostingController with the SwiftUI view
        let controller = UIHostingController(rootView: content())
        controller.view.translatesAutoresizingMaskIntoConstraints = false  // Disable autoresizing
        view.addSubview(controller.view)
        
        // Set constraints for the controller's view
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            controller.view.widthAnchor.constraint(equalTo: view.widthAnchor)  // Ensures the width matches the scroll view
        ])
        
        return view
    }
    
    public func updateUIView(_ uiView: UIScrollView, context: UIViewRepresentableContext<ScrollViewWrapper>) {
        print("update")
        uiView.contentOffset = self.contentOffset
        
        DispatchQueue.main.async {
            self.scrollViewHeight = uiView.contentSize.height
            self.visibleHeight = uiView.frame.size.height
            
            // Update the frame of the hosted view if necessary
            if let hostedView = uiView.subviews.first {
                print("hosting view exist")
                hostedView.translatesAutoresizingMaskIntoConstraints = true
                hostedView.frame = CGRect(origin: .zero, size: uiView.contentSize)
                
                print("1set auto layout again")
                NSLayoutConstraint.activate([
                    hostedView.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
                    hostedView.trailingAnchor.constraint(equalTo: uiView.trailingAnchor),
                    hostedView.topAnchor.constraint(equalTo: uiView.topAnchor),
                    hostedView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor),
                    hostedView.widthAnchor.constraint(equalTo: uiView.widthAnchor)  // Ensures the width matches the scroll view
                ])
                print("2set auto layout again")

                
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(contentOffset: self._contentOffset, scrollViewHeight: self._scrollViewHeight) // Modify this line
    }
    
    public class Coordinator: NSObject, UIScrollViewDelegate {
        let contentOffset: Binding<CGPoint>
        let scrollViewHeight: Binding<CGFloat>  // Add this line
        
        init(contentOffset: Binding<CGPoint>, scrollViewHeight: Binding<CGFloat>) { // Modify this line
            self.contentOffset = contentOffset
            self.scrollViewHeight = scrollViewHeight  // Add this line
        }
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            contentOffset.wrappedValue = scrollView.contentOffset
        }
        
    }
}
