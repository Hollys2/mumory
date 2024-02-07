//
//  MumoryDetailEditView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/01.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import PhotosUI

import Core
import Shared


public struct MumoryDetailEditView: View {
    
    @State private var contentText: String = ""
    @State private var isPublic: Bool = true

    @State private var showDatePicker: Bool = false
    @State private var selectedDate: Date = Date()

    @State private var tagText: String = ""
    @State private var tags: [String] = []
    
    @State private var isEditing = false
    @State private var isTagEditing = false
    @State private var isCommit = false
    
    @State private var editingTag: Int? = nil
    @State private var tagWidth: CGFloat = .zero

    var formattedDate: String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy. MM. dd. EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        
        return formatter.string(from: selectedDate)
    }
    
    @StateObject private var photoPickerViewModel: PhotoPickerViewModel = .init()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    @State private var translation: CGSize = .zero
    
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            SharedAsset.backgroundColor.swiftUIColor
            
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Button(action: {
                            withAnimation(Animation.easeInOut(duration: 0.2)) {
                                appCoordinator.isCreateMumorySheetShown = false
                                
                                mumoryDataViewModel.choosedMusicModel = nil
                                mumoryDataViewModel.choosedLocationModel = nil
                                
                                appCoordinator.rootPath.removeLast()
                            }
                        }) {
                            Image(uiImage: SharedAsset.closeCreateMumory.image)
                                .resizable()
                                .frame(width: 25, height: 25)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if let choosedMusicModel = mumoryDataViewModel.choosedMusicModel, let choosedLocationModel = mumoryDataViewModel.choosedLocationModel {
                                let newMumoryAnnotation = MumoryAnnotation(date: Date(), musicModel: choosedMusicModel, locationModel: choosedLocationModel)
//                                mumoryDataViewModel.createdMumoryAnnotation = newMumoryAnnotation
                                mumoryDataViewModel.mumoryAnnotations.append(newMumoryAnnotation)
                            }
                            
                            withAnimation(Animation.easeInOut(duration: 0.2)) { // 사라질 때 애니메이션 적용
                                appCoordinator.isCreateMumorySheetShown = false
                                
                            }
                            
                            mumoryDataViewModel.choosedMusicModel = nil
                            mumoryDataViewModel.choosedLocationModel = nil
                        }) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 46, height: 30)
                                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            //                                .background(Color(red: 0.47, green: 0.47, blue: 0.47)) 미충족
                                .cornerRadius(31.5)
                                .overlay(
                                    Text("완료")
                                        .font(Font.custom("Pretendard", size: 13).weight(.bold))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.black)
                                )
                        }
                    } // HStack
                    
                    Text("수정하기") // 추후 재사용 위해 분리
                        .font(
                            Font.custom("Pretendard", size: 18)
                                .weight(.semibold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                } // ZStack
                .padding(.top, 16 + appCoordinator.safeAreaInsetsTop)
                .padding(.bottom, 11)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // MARK: -Search Music
                        NavigationLink(value: 2) {
                            HStack(spacing: 16) {
                                Image(uiImage: SharedAsset.musicCreateMumory.image)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                        .cornerRadius(15)
                                    if let choosedMusicModel = mumoryDataViewModel.choosedMusicModel {
                                        HStack(spacing: 10) {
                                            Rectangle()
                                                .foregroundColor(.clear)
                                                .frame(width: 40, height: 40)
                                                .background(
                                                    AsyncImage(url: choosedMusicModel.artworkUrl) { phase in
                                                        switch phase {
                                                        case .success(let image):
                                                            image
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .frame(width: 40, height: 40)
                                                        default:
                                                            Color.purple
                                                                .frame(width: 40, height: 40)
                                                        }
                                                    }
                                                )
                                                .cornerRadius(6)
                                            
                                            VStack(spacing: 3) {
                                                Text(choosedMusicModel.title)
                                                    .font(
                                                        Font.custom("Pretendard", size: 15)
                                                            .weight(.semibold)
                                                    )
                                                    .lineLimit(1)
                                                    .foregroundColor(.white)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                Text(choosedMusicModel.artist)
                                                    .font(Font.custom("Pretendard", size: 13))
                                                    .lineLimit(1)
                                                    .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .frame(height: 60)
                                        } // HStack
                                        .padding(.horizontal, 15)
                                    } else {
                                        Text("음악 추가하기")
                                            .font(Font.custom("Pretendard", size: 16))
                                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 20)
                                    }
                                } // ZStack
                            } // HStack
                        } // NavigationLink
                        
                        // MARK: -Underline
                        Divider()
                            .frame(height: 0.3)
                            .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                            .padding(.top, 16)
                        
                        // MARK: -Search location
                        HStack(spacing: 16) {
                            NavigationLink(value: 3) {
                                Image(uiImage: SharedAsset.locationCreateMumory.image)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                            }
                            
                            NavigationLink(value: 3) {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 60)
                                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                        .cornerRadius(15)
                                    if let choosedLocationModel = mumoryDataViewModel.choosedLocationModel {
                                        VStack(spacing: 10) {
                                            Text("\(choosedLocationModel.locationTitle)")
                                                .font(Font.custom("Pretendard", size: 15))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .lineLimit(1)
                                            
                                            Text("\(choosedLocationModel.locationSubtitle)")
                                                .font(Font.custom("Pretendard", size: 13))
                                                .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .lineLimit(1)
                                        }
                                        .padding(.horizontal, 15)
                                    } else {
                                        Text("위치 추가하기")
                                            .font(Font.custom("Pretendard", size: 16))
                                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .lineLimit(1)
                                            .padding(.horizontal, 20)
                                    }
                                    
                                }
                            }
                        }
                        .padding(.top, 14)
                        
                        // MARK: -Underline
                        Divider()
                            .frame(height: 0.5) // ???
                            .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                            .padding(.top, 16)
                        
                        // MARK: -Date
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                .cornerRadius(15)
                            
                            HStack {
                                Text("\(formattedDate)")
                                    .font(Font.custom("Pretendard", size: 16).weight(.medium))
                                    .foregroundColor(.white)
                                Spacer()
                                
                                Button(action: {
                                    self.showDatePicker = true
                                }) {
                                    Image(uiImage: SharedAsset.calendarCreateMumory.image)
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                }
                                .popover(isPresented: $showDatePicker, content: {
                                    DatePicker("", selection: $selectedDate)
                                        .datePickerStyle(.automatic)
                                        .presentationDetents([.height(100)])
                                        .frame(width: 0, height: 0)
                                        .background(.black)
                                })
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 14)
                        
                        // MARK: -Tag
                        // 긴 문자열 수정시 오류
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: 50)
                                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                .cornerRadius(15)
                            
                            HStack(spacing: 8) {
                                ForEach(tags.indices, id: \.self) { index in
                                    TextField("", text: $tags[index], onEditingChanged: { isEditing in
                                        self.isTagEditing = isEditing
                                    })
                                    .font(
                                        Font.custom("Pretendard", size: 16)
                                            .weight(.medium)
                                    )
                                    .foregroundColor(self.isTagEditing ? .white : Color(red: 0.64, green: 0.51, blue: 0.99))
                                    .frame(width: min(CGFloat(tags[index].count * 9), (UIScreen.main.bounds.width - 80 - 16) / 3), alignment: .leading)
                                    .onChange(of: tags[index], perform: { i in
                                        if i.contains(" ") || i.hasSuffix(" ") {
                                            let beforeSpace = i.components(separatedBy: " ").first ?? ""
                                            tags[index] = beforeSpace
                                            
                                            self.isCommit = true
                                        } else if i == "" {
                                            tags.remove(at: index)
                                        } else if !i.hasPrefix("#") {
                                            tags.remove(at: index)
                                        }
                                    })
                                }
                                
                                
                                if self.tags.count < 3 {
                                    CustomTextField(text: $tagText, onCommit: {
                                        if tagText.first == "#" {
                                            tags.append(tagText)
                                            tagText = ""
                                        }
                                    }, onEditingChanged: { isEditing in
                                        self.isEditing = isEditing
                                    })
                                    .frame(maxWidth: (UIScreen.main.bounds.width - 80 - 16) / 3, alignment: .leading)
                                }
                                
                                Spacer(minLength: 0)
                            } // HStack
                            .padding(.horizontal, 20)
                            
                            if self.tags.count == 0 {
                                Text(self.isEditing ? "" : "#을 넣어 기분을 태그해 보세요  (최대 3개)")
                                    .font(Font.custom("Pretendard", size: 15))
                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 20)
                                    .allowsHitTesting(false)
                            }
                        } // ZStack
                        .padding(.top, 15)
                        
                        // MARK: -Content
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $contentText)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(Color.white)
                                .font(.custom("Pretendard", size: 15))
                                .lineSpacing(5)
                                .frame(minHeight: 104)
                                .padding(.leading, 20 - 6)
                                .padding(.trailing, 20 - 6)
                                .padding(.vertical, 22 - 8)
                            //                                .onReceive(contentText.publisher.collect()) {
                            //                                    let newText = String($0.prefix(60))
                            //                                    if newText != contentText {
                            //                                        contentText = newText
                            //                                    }
                            //                                }
                                .onTapGesture {} // VStack의 onTapGesture를 무효화합니다.
                                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                            //                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                            //                            isEditing = true
                            //                        }
                            //                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                            //                            isEditing = false
                            //                        }
                            
                            
                            //                            Text(contentText.count > 0 ? "\(contentText.count)" : "00")
                            //                                .font(Font.custom("Pretendard", size: 13))
                            //                                .foregroundColor(.white)
                            //                                .padding(.trailing, 15)
                            //                                .padding(.vertical, 22)
                            //                                .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            
                            if self.contentText.isEmpty {
                                Text("자유롭게 내용을 입력하세요  (60자 이내)")
                                    .font(Font.custom("Pretendard", size: 15))
                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                    .allowsHitTesting(false)
                                    .padding(.leading, 20)
                                //                                    .padding(.trailing, 42)
                                    .padding(.vertical, 22)
                            }
                        }
                        .cornerRadius(15)
                        .padding(.top, 15)
                        
                        // MARK: -Image
                        HStack(spacing: 10) {
                            PhotosPicker(selection: $photoPickerViewModel.imageSelections,
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
                                            
                                            HStack(spacing: 0) {
                                                Text("\(photoPickerViewModel.imageSelectionCount)")
                                                    .font(Font.custom("Pretendard", size: 14).weight(.medium))
                                                    .foregroundColor(photoPickerViewModel.imageSelectionCount >= 1 ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.47, green: 0.47, blue: 0.47))
                                                Text(" / 3")
                                                    .font(Font.custom("Pretendard", size: 14).weight(.medium))
                                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                            }
                                            .multilineTextAlignment(.center)
                                            .padding(.top, 11.25)
                                        }
                                    )
                            }
                            
                            if !photoPickerViewModel.selectedImages.isEmpty {
                                ForEach(photoPickerViewModel.selectedImages, id: \.self) { image in
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
                                            photoPickerViewModel.removeImage(image)
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
                        .padding(.top, 20)
                        .onChange(of: photoPickerViewModel.imageSelections) { _ in
                            photoPickerViewModel.convertDataToImage()
                        }
                    } // VStack
                    .padding(.top, 25)
                    .padding(.bottom, 50)
                    .frame(width: UIScreen.main.bounds.width - 40)
                    
                } // ScrollView
                .scrollIndicators(.hidden)
                
                ZStack {
                    Rectangle()
                        .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.12))
                        .frame(height: 55 + appCoordinator.safeAreaInsetsBottom)
                        .overlay(
                            Rectangle()
                                .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                                .frame(height: 0.5),
                            alignment: .top
                        )
                        .padding(.horizontal, -20)
                    
                    HStack(spacing: 7) {
                        Button(action: {
                            self.isPublic.toggle()
                        }) {
                            Text("전체공개")
                                .font(
                                    Font.custom("Pretendard", size: 15)
                                        .weight(self.isPublic ? .semibold : .medium)
                                )
                                .foregroundColor(self.isPublic ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.76, green: 0.76, blue: 0.76))
                                .padding(.leading, 5)
                            
                            Image(uiImage: self.isPublic ? SharedAsset.publicOnCreateMumory.image : SharedAsset.publicOffCreateMumory.image)
                                .frame(width: 17, height: 17)
                        }
                        
                        Spacer()
                    }
                } // ZStack
            } // VStack
        } // ZStack
        .frame(width: UIScreen.main.bounds.width - 40)
        .padding(.horizontal, 20)
        .background(SharedAsset.backgroundColor.swiftUIColor)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
    }
}

struct MumoryDetailEditView_Previews: PreviewProvider {
    static var previews: some View {
        MumoryDetailEditView()
            .environmentObject(AppCoordinator())
            .environmentObject(MumoryDataViewModel())
    }
}


struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    var onCommit: () -> Void
    var onEditingChanged: ((Bool) -> Void)?
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator

        if let customFont = UIFont(name: "Pretendard", size: 16) {
            textField.font = customFont
            //        textField.font = UIFont.systemFont(ofSize: 36, weight: .medium)
        } else {
            print("폰트 로드에 실패했습니다.")
        }

        textField.textColor = .white
        
//        textField.attributedPlaceholder = NSAttributedString(
//             string: "",
//             attributes: [NSAttributedString.Key.foregroundColor: UIColor.red],
//             font: UIFont(name: "Pretendard", size: 36)
//         )
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField
        
        init(parent: CustomTextField) {
            self.parent = parent
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            print("textFieldDidChangeSelection")
            
            DispatchQueue.main.async {
                self.parent.text = textField.text ?? ""
                
                if let lastCharacter = textField.text?.last, lastCharacter == " " {
                    self.parent.onCommit()
                }
            }
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // 최대 길이를 6로 제한
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)

            return newText.count <= 6
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.parent.onCommit()
            return true
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            // 포커스가 들어왔을 때 호출
            self.parent.onEditingChanged?(true)
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            // 포커스가 나갔을 때 호출
            self.parent.onEditingChanged?(false)
        }
    }
}

