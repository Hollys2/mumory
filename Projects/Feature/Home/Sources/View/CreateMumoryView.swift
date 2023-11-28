//
//  MakeMumoryView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/17.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import PhotosUI
import Shared


@available(iOS 16.0, *)
final class PhotoPickerViewModel: ObservableObject {
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            setImage(from: imageSelection)
        }
    }
    
    @Published var imageSelectionCount: Int = 0
    @Published private(set) var selectedImages: [UIImage] = [] {
        didSet {
            print("selectedImages didSet")
            self.imageSelectionCount = selectedImages.count
        }
    }
    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet {
            print("imageSelections didSet")
//            setImages(from: imageSelections)
        }
    }
    
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }
        
        Task {
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                
                selectedImage = uiImage
            } catch {
                print(error)
            }
        }
    }
    
    private func setImages(from selections: [PhotosPickerItem]) {
//        selectedImages = []
        selectedImages.removeAll()
        
        if !imageSelections.isEmpty {
            for selection in selections {
                Task {
                    if let data = try? await selection.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        DispatchQueue.main.async { [weak self] in
                            self?.selectedImages.append(uiImage)
                        }
                    }
                }
            }
        }
        imageSelections.removeAll()
    }
    
    @MainActor
    func convertDataToImage() {
        // reset the images array before adding more/new photos
        selectedImages.removeAll()
        
        if !imageSelections.isEmpty {
            for eachItem in imageSelections {
                Task {
                    if let imageData = try? await eachItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: imageData) {
                            selectedImages.append(image)
                        }
                    }
                }
            }
        }
        
        // uncheck the images in the system photo picker
        imageSelections.removeAll()
    }


    
    //    private func setImages(from selections: [PhotosPickerItem]) {
    //        Task {
    //            var images: [UIImage] = []
    //            for selection in selections {
    //                if let data = try? await selection.loadTransferable(type: Data.self) {
    //                    if let uiImage = UIImage(data: data) {
    //                        images.append(uiImage)
    //                    }
    //                }
    //            }
    //            selectedImages = images
    //        }
    //    }
    
    func removeImage(_ image: UIImage) {
        DispatchQueue.main.async {
            if let index = self.selectedImages.firstIndex(of: image) {
                self.selectedImages.remove(at: index)
//                self.imageSelections.remove(at: index)
            }
        }
    }
}

@available(iOS 16.0, *)
struct MakeMumoryView: View {
    @Binding var isShown: Bool
    @State private var contentText: String = ""
    @State private var isPublic: Bool = true
    
    @StateObject private var viewModel = PhotoPickerViewModel()
    
    var body: some View {
        //        NavigationView {
        GeometryReader { geometry in
            //                ScrollView {
            VStack {
                //                VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            self.isShown.toggle()
                        }
                    }) {
                        Image(uiImage: SharedAsset.closeCreateMumory.image)
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                    
                    Spacer()
                    
                    Text("뮤모리 만들기")
                        .font(
                            Font.custom("Pretendard", size: 18)
                                .weight(.semibold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        
                    }) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 46, height: 30)
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(31.5)
                            .overlay(
                                Text("게시")
                                    .font(Font.custom("Pretendard", size: 13).weight(.bold))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.black)
                            )
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 20)
                
                ScrollView {
                    HStack(spacing: 16) {
                        Button(action: {
                            
                        }) {
                            Image(uiImage: SharedAsset.musicCreateMumory.image)
                                .resizable()
                                .frame(width: 60, height: 60)
                            //                                    .background(
                            //                                        NavigationLink(destination: SearchLocationView()) {
                            //                                            EmptyView() // NavigationLink를 숨기기 위해 빈 뷰를 사용합니다.
                            //                                        }
                            //                                    )
                        }
                        
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                .cornerRadius(15)
                            
                            HStack {
                                Text("음악 추가하기")
                                    .font(Font.custom("Pretendard", size: 16))
                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                    .padding(.leading, 20)
                                Spacer()
                            }
                        }
                        
                        
                    }
                    .padding(.top, 25)
                    
                    // MARK: -Underline
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth: .infinity)
                        .frame(height: 0.3)
                        .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                        .padding(.top, 16)

                    // MARK: -Search location
                    HStack(spacing: 16) {
                        NavigationLink(destination: SearchLocationView()) {
                            Image(uiImage: SharedAsset.locationCreateMumory.image)
                                .resizable()
                                .frame(width: 60, height: 60)
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                    .cornerRadius(15)
                                
                                HStack {
                                    Text("위치 추가하기")
                                        .font(Font.custom("Pretendard", size: 16))
                                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                        .padding(.leading, 20)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.top, 14)
                    
                    
                    
                    
                    // MARK: -Underline
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth: .infinity)
                        .frame(height: 0.3)
                        .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                        .padding(.top, 16)
                        .padding(.bottom, 14)
                    
                    // MARK: -Date
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                            .cornerRadius(15)
                        
                        HStack(alignment: .center) {
                            Text("2023. 10. 02. 월요일")
                                .font(Font.custom("Pretendard", size: 16).weight(.medium))
                                .foregroundColor(.white)
                            Spacer()
                            
                            Button(action: {
                                
                            }) {
                                Image(uiImage: SharedAsset.calendarCreateMumory.image)
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // MARK: -Tag
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                            .cornerRadius(15)
                        HStack {
                            Text("#을 넣어 기분을 태그해 보세요  (최대 3개)")
                                .font(Font.custom("Pretendard", size: 15))
                                .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                .padding(.leading, 20)
                            Spacer()
                        }
                    }
                    .padding(.top, 15)
                    
                    // MARK: -Content
                    ZStack(alignment: .topLeading) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(maxWidth: .infinity)
                            .frame(height: 104)
                            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                        
                        TextEditor(text: $contentText)
                            .frame(maxWidth: .infinity)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .foregroundColor(Color.white)
                            .font(.custom("Pretendard", size: 15))
                            .lineSpacing(5)
                            .padding(.leading, 20 - 6)
                            .padding(.trailing, 42 - 6)
                            .padding(.vertical, 22 - 8)
                            .onReceive(contentText.publisher.collect()) {
                                let newText = String($0.prefix(60))
                                if newText != contentText {
                                    contentText = newText
                                }
                            }
                        
                        Text(contentText.count > 0 ? "\(contentText.count)" : "00")
                            .font(Font.custom("Pretendard", size: 13))
                            .foregroundColor(.white)
                            .padding(.trailing, 15)
                            .padding(.vertical, 22)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        

                        if self.contentText.isEmpty {
                            Text("자유롭게 내용을 입력하세요  (60자 이내)")
                                .font(Font.custom("Pretendard", size: 15))
                                .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                .allowsHitTesting(false)
                                .padding(.leading, 20)
                                .padding(.trailing, 42)
                                .padding(.vertical, 22)
                        }
                    }
                    .cornerRadius(15)
                    .padding(.top, 15)
                    .padding(.bottom, 20)
                    
                    // MARK: -Image
                    HStack(spacing: 10) {
                        PhotosPicker(selection: $viewModel.imageSelections,
                                     maxSelectionCount: 3,
                                     matching: .images) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 72, height: 72)
                                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .inset(by: 0.5)
                                        .stroke(Color(red: 0.47, green: 0.47, blue: 0.47), lineWidth: 1)
                                )
                                .overlay(
                                    VStack(spacing: 0) {
                                        Image(uiImage: SharedAsset.imageCreateMumory.image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 23.5, height: 23.5)
                                        //                                    .offset(y: -(75 - 23.5) / 2 + 15.25)
                                        //                                .padding(.bottom, 36.25)
                                        
                                        HStack(spacing: 0) {
                                            Text("\(viewModel.imageSelectionCount)")
                                                .font(Font.custom("Pretendard", size: 14).weight(.medium))
                                                .foregroundColor(viewModel.imageSelectionCount >= 1 ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.47, green: 0.47, blue: 0.47))
                                            Text(" / 3")
                                                .font(Font.custom("Pretendard", size: 14).weight(.medium))
                                                .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                        }
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 11.25)
                                    }
                                )
                        }
                        
                        if !viewModel.selectedImages.isEmpty {
                            ForEach(viewModel.selectedImages, id: \.self) { image in
                                ZStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 72, height: 72)
                                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .inset(by: 0.5)
                                                .stroke(Color(red: 0.47, green: 0.47, blue: 0.47), lineWidth: 1)
                                        )
                                    Button(action: {
                                        viewModel.removeImage(image)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .resizable()
                                            .frame(width: 27, height: 27)
                                            .foregroundColor(.white)
                                    }
                                    .offset(x: -51 + 57 + 27, y: -(-51 + 57 + 27))
                                }
                            }
                            
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 111)
                    .onChange(of: viewModel.imageSelections) { _ in
                        viewModel.convertDataToImage()
                        
                    }
                }
                .padding(.horizontal, 20)
                //                .frame(height: UIScreen.main.bounds.height)
                .cornerRadius(23)
                .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                .scrollIndicators(.hidden)
                
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                        .overlay(
                            Rectangle()
                                .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                                .frame(height: 0.5),
                            alignment: .top
                        )
                        .padding(.horizontal, -20)
                        .padding(.bottom, 0)
                    
                    Button(action: {
                        self.isPublic.toggle()
                    }, label: {
                        HStack(spacing: 7) {
                            if self.isPublic {
                                Text("전체공개")
                                    .font(
                                        Font.custom("Pretendard", size: 15)
                                            .weight(.semibold)
                                    )
                                    .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                                
                                Image(uiImage: SharedAsset.publicOnCreateMumory.image)
                                    .frame(width: 17, height: 17)
                            } else {
                                Text("전체공개")
                                  .font(
                                    Font.custom("Pretendard", size: 15)
                                      .weight(.medium)
                                  )
                                  .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                
                                Image(uiImage: SharedAsset.publicOffCreateMumory.image)
                                    .frame(width: 17, height: 17)
                            }
                            Spacer()
                        }
                        .padding(.leading, 25)
                    })
                }
                
            }
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        }
        //        }
    }
}




struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            MakeMumoryView(isShown: .constant(true))
        } else {
            // Fallback on earlier versions
        }
    }
}
