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

public enum photoType{
    case background
    case profile
}

public struct PhotoSelectBottomSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State var backgroundOpacity = 0.0
    @State var yOffset: CGFloat = 0
    @Binding public var isPresent: Bool
    @Binding var selectedItem: PhotosPickerItem?
    public var type: photoType = .profile
    var typeString: String = "프로필"
    
    public init(isPresent: Binding<Bool>, selectedItem: Binding<PhotosPickerItem?>) {
        self._isPresent = isPresent
        self._selectedItem = selectedItem
    }
    
    public init(isPresent: Binding<Bool>, selectedItem: Binding<PhotosPickerItem?>, photoType: photoType) {
        self._isPresent = isPresent
        self._selectedItem = selectedItem
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
                        
                        PhotosPicker(selection: $selectedItem, matching: .images) {
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
                        
                        if selectedItem != nil {
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
                                selectedItem = nil
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
                if drag.startLocation.y < 30 {
                    if drag.velocity.height < 0 {
                        //위로 올리는 제스처
                        withAnimation(.linear(duration: 0.2)) {
                            yOffset = 0
                        }
                    }else if drag.velocity.height > 500{
                        //아래로 빠르게 내리는 제스처
                        backgroundOpacity = 0
                        dismiss()
                    }else {
                        //아래로 천천히 내리는 제스처
                        if drag.location.y > 200 {
                            backgroundOpacity = 0
                            dismiss()
                        }else {
                            withAnimation(.linear(duration: 0.2)) {
                                yOffset = 0
                            }
                        }
                    }
                }
                
            })
        
    }
}


