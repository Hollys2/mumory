//
//  AddPlaylistSongView.swift
//  Feature
//
//  Created by 제이콥 on 2/14/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

class SnackBarViewModel: ObservableObject {
    @Published var snackbarTitle: String = ""
    @Published var isPresent: Bool = false
    @Published var alreadExists: Bool = false
    var snackbarTimer = 0.0
    var timer: Timer?
    init() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { timer in
            self.snackbarTimer += 0.2
            
            if self.snackbarTimer == 1.0 {
                withAnimation {
                    self.isPresent = false
                }
            }
        })
    }
    public func setSnackBar(alreadExists: Bool) {
        self.snackbarTimer = 0.0
        self.alreadExists = alreadExists
        withAnimation {
            self.isPresent = true
        }
    }
}



struct AddPlaylistSongView: View {
    @EnvironmentObject var manager: LibraryManageModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @StateObject var snackbarManager: SnackBarViewModel = SnackBarViewModel()
    @EnvironmentObject var userManager: UserViewModel
    @State var originPlaylist: MusicPlaylist
    @State var isTapFavorite: Bool = true
    @State var selectLineWidth: CGFloat = 55
    
    private let lineGray = Color(white: 0.31)
    private let noneSelectedColor = Color(white: 0.65)
    
    init(originPlaylist: MusicPlaylist) {
        self.originPlaylist = originPlaylist
    }

    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            VStack(spacing: 0, content: {
                //상단바
                HStack(spacing: 0){
                        SharedAsset.back.swiftUIImage
                            .resizable()
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                manager.pop()
                            }

                    Spacer()
                    
                    Text("음악 추가")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(width: 30, height: 30)
                    
                }
                .padding(.horizontal, 20)
                .frame(height: 40)
                
                HStack(spacing: 0, content: {
                    Text("즐겨찾기")
                        .font(isTapFavorite ?  SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16) : SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundStyle(isTapFavorite ? .white : noneSelectedColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            withAnimation (.linear(duration: 0.2)){
                                isTapFavorite = true
                                selectLineWidth = 55
                            }
                        }
                    
                    Text("검색")
                        .font(isTapFavorite ?  SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16) : SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundStyle(isTapFavorite ? noneSelectedColor : .white)
                        .frame(maxWidth: .infinity)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            withAnimation (.linear(duration: 0.2)) {
                                isTapFavorite = false
                                selectLineWidth = 28
                            }
                        }
                })
                .padding(.vertical, 14)
                
                //선택시 움직이는 보라색 선
                VStack(content: {
                    Rectangle()
                        .frame(width: 390/2, height: 3)
                        .foregroundStyle(.clear)
                        .overlay(content: {
                            Rectangle()
                                .frame(width: selectLineWidth, height: 3)
                                .foregroundStyle(ColorSet.mainPurpleColor)
                        })
                })
                .frame(maxWidth: .infinity, alignment: isTapFavorite ? .leading : .trailing)
                
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.5)
                    .background(lineGray)
                
                if isTapFavorite{
                    AddSongFromFavoriteView(originPlaylist: $originPlaylist)
                        .environmentObject(snackbarManager)
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                }else {
                    AddSongFromSearchView(originPlaylist: $originPlaylist)
                        .environmentObject(snackbarManager)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                }
        
                
            })
            
            VStack{
                Spacer()
                if snackbarManager.isPresent{
                        HStack(spacing: 0) {
                            Text(snackbarManager.alreadExists ?  "이미 플레이리스트 " : "플레이리스트")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                                .foregroundStyle(Color.black)
                            
                            Text("\"\(originPlaylist.title)\"")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                                .foregroundStyle(Color.black)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            Text(snackbarManager.alreadExists ? "에 존재 합니다." : "에 추가 되었습니다.")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                                .foregroundStyle(Color.black)
                        }
                        .padding(.horizontal, 20)
                        .frame(height: 41)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
                        .padding(.horizontal, 20)
                        .transition(.opacity)
                        .padding(.bottom, userManager.bottomInset + 2)
                    }
         
                   
                    
                }

            
        }
        .onDisappear(perform: {
            withAnimation {
                appCoordinator.isHiddenTabBar = false
            }
        })
    }
}

//#Preview {
//    AddPlaylistSongView()
//}


