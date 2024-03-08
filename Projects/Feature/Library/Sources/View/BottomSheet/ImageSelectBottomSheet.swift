//
//  MusickitTestView.swift
//  Feature
//
//  Created by 제이콥 on 2/3/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit
import _PhotosUI_SwiftUI

public struct ImageSelectBottomSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State var backgroundOpacity = 0.0
    @State var yOffset: CGFloat = 0
    @Binding public var isPresent: Bool
    @Binding public var imageBundle: ImageBundle
    @State var item: PhotosPickerItem?
    public var type: photoType = .profile
    var typeString: String = "프로필"
    
    public init(isPresent: Binding<Bool>, imageBundle: Binding<ImageBundle>) {
        self._isPresent = isPresent
        self._imageBundle = imageBundle
    }
    
    public init(isPresent: Binding<Bool>, imageBundle: Binding<ImageBundle>, photoType: photoType) {
        self._isPresent = isPresent
        self._imageBundle = imageBundle
        self.type = photoType
        switch(photoType){
        case .profile:
            self.typeString = "프로필"
        case .background:
            self.typeString = "배경"
        }
    }
    
    public var body: some View {
            
            ZStack(alignment: .bottom, content: {
                Color.black.opacity(backgroundOpacity).ignoresSafeArea()
                    .onTapGesture {
                        backgroundOpacity = 0
                        dismiss()
                    }
                VStack(spacing: 0, content: {
                    SharedAsset.dragIndicator.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 47)
                        .padding(.top, 11)
                        .padding(.bottom, 2)
                    
                 
                    VStack(spacing: 0, content: {
                        
                        PhotosPicker(selection: $item, matching: .images) {
                            HStack(spacing: 0, content: {
                                SharedAsset.upload.swiftUIImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                
                                Text("\(typeString) 사진 업로드" )
                                    .padding(.leading, 12)
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                                    .foregroundStyle(Color.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            })
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .padding(.horizontal, 20)
                            .background(ColorSet.background)
                        }
                        .onChange(of: item) { value in
                            Task {
                                guard let data = try? await value?.loadTransferable(type: Data.self) else {
                                    imageBundle.image = nil
                                    imageBundle.data = nil
                                    return
                                }
                                guard let uiImage = UIImage(data: data) else {
                                    return
                                }
                                imageBundle.image = Image(uiImage: uiImage)
                                imageBundle.data = uiImage.jpegData(compressionQuality: 0.2)
                            }
                        }
                        
                        if imageBundle.image != nil {
                            Divider()
                                .frame(maxWidth: .infinity)
                                .frame(height: 0.2)
                                .background(ColorSet.darkGray)
                                .padding(.horizontal, 2)
                            
                            HStack(spacing: 0, content: {
                                SharedAsset.delete.swiftUIImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                
                                Text("\(typeString) 사진 지우기")
                                    .padding(.leading, 12)
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                                    .foregroundStyle(Color.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            })
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .padding(.horizontal, 20)
                            .background(ColorSet.background)
                            .onTapGesture {
                                imageBundle.image = nil
                                imageBundle.data = nil
                                dismiss()
                            }

                        }
                    })
                    .background(ColorSet.background)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 9)
                    
                    
                    
                })
                .frame(maxWidth: .infinity)
                .background(ColorSet.moreDeepGray)
                .cornerRadius(15, corners: [.allCorners])
                .padding(.horizontal, 7)
                .offset(y: yOffset)
                .gesture(drag)
                
            })
            .onAppear(perform: {
                withAnimation(.easeIn(duration: 0.5)){
                    backgroundOpacity = 0.7
                }
            })
            .onChange(of: isPresent, perform: { value in
                if !isPresent {
                    backgroundOpacity = 0.0
                }
            })
        
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged({ drag in
                if drag.startLocation.y < 30 {
                    yOffset = drag.location.y >= 0 ? drag.location.y : 0
                }
            })
            .onEnded({ drag in
                  if drag.location.y - drag.startLocation.y < 65  {
                      withAnimation(.linear(duration: 0.2)) {
                          yOffset = 0
                      }
                  }else {
                      backgroundOpacity = 0
                      dismiss()
                  }
                  
              })
        
    }
}


