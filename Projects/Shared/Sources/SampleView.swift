//import SwiftUI
//
//public struct SampleView: View {
//        
//    public init() {
//        
//    }
//    
//    public var body: some View {
//        
//        
//        
//        Rectangle()
//          .foregroundColor(.clear)
//          .frame(width: 312, height: 133)
//          .background(Color(red: 0.16, green: 0.16, blue: 0.16))
//          .cornerRadius(15)
//          .overlay(
//            VStack(spacing: 0) {
//                Text("나의 댓글을 삭제하시겠습니까?")
//                  .font(
//                    Font.custom("Pretendard", size: 16)
//                      .weight(.semibold)
//                  )
//                  .multilineTextAlignment(.center)
//                  .foregroundColor(.white)
//                  .padding(.top, 36)
//                  .background(.pink)
//                
//                Spacer()
//                
//                HStack(spacing: 0) {
//                    Button(action: {
//                        // Handle button action
//                    }) {
//                        Rectangle()
//                            .foregroundColor(.clear)
//                            .frame(width: 156, height: 50)
//                            .background(Color(red: 0.16, green: 0.16, blue: 0.16))
//                            .cornerRadius(15, corners: [.bottomLeft])
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 15)
//                                    .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), lineWidth: 0.3)
//                            )
//                    }
//                    
//                    Button(action: {
//                        // Handle button action
//                    }) {
//                        Rectangle()
//                            .foregroundColor(.clear)
//                            .frame(width: 156, height: 50)
//                            .background(Color(red: 0.16, green: 0.16, blue: 0.16))
//                            .cornerRadius(15, corners: [.bottomRight])
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 15)
//                                    .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), lineWidth: 0.3)
//                            )
//                    }
//                } // HStack
//            } // VStack
//          )
//    }
//}
//
//
//struct MumoryDetailCommentSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        SampleView()
//    }
//}
