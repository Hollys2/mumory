//
//  MyMumoriItem.swift
//  Feature
//
//  Created by 제이콥 on 2/25/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct MyMumoryItem: View {
    let mumory: Mumory
    @State var song: Song?
    init(mumory: Mumory) {
        self.mumory = mumory
    }
    
    var body: some View {
        VStack(spacing: 0, content: {
            AsyncImage(url: song?.artwork?.url(width: 500, height: 500)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: getUIScreenBounds().width * 0.43, height: getUIScreenBounds().width * 0.43)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
                
            } placeholder: {
                RoundedRectangle(cornerRadius: 10, style: .circular)
                    .frame(width: getUIScreenBounds().width * 0.43, height: getUIScreenBounds().width * 0.43)
            }
            .overlay(content: {
                Color.black.opacity(0.4)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))

                Text(DateText(date: mumory.date))
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                    .foregroundStyle(Color.white)
                    .frame(height: 20)
                    .padding(.horizontal, 10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 35, style: .circular)
                            .stroke(Color.white, lineWidth: 1)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(11)
                
                if !mumory.isPublic {
                    SharedAsset.lockPurple.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 21, height: 21)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(11)
                }
                
                HStack(spacing: 4, content: {
                    SharedAsset.locationMumoryPopup.swiftUIImage
                        .resizable()
                        .frame(width: 18, height: 18)
                        .scaledToFit()
                    
                    Text(mumory.location.locationTitle)
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .truncationMode(.tail)
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(11)
            })
           
            
        })
        .onAppear {
            Task {
                self.song = await fetchSong(songID: mumory.song.id)
            }
        }
    }
    
    private func DateText(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: date)
    }
    
    private func fetchSong(songID: String) async -> Song? {
        let musicItemID = MusicItemID(rawValue: songID)
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        guard let response = try? await request.response() else {
            return nil
        }
        guard let song = response.items.first else {
            return nil
        }
        return song
    }
}


struct MumorySkeletonView: View {
    @State var startAnimation: Bool = false
    var body: some View {
        ForEach(0...6, id: \.self) { index in
          MumorySkeletonItem
        }
        .onAppear {
            startAnimation.toggle()
        }
    }
    
    
    var MumorySkeletonItem: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 10, style: .circular)
                .fill(startAnimation ? ColorSet.skeleton : ColorSet.skeleton02)
                .frame(width: getUIScreenBounds().width * 0.43, height: getUIScreenBounds().width * 0.43)
                .overlay {
                    RoundedRectangle(cornerRadius: 35, style: .circular)
                        .fill(startAnimation ? ColorSet.skeleton02 : Color(white: 0.35))
                        .frame(width: 62, height: 21)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(11)
                    
                    Circle()
                        .fill(startAnimation ? ColorSet.skeleton02 : Color(white: 0.35))
                        .frame(width: 21, height: 21)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(11)
                    
                    RoundedRectangle(cornerRadius: 35, style: .circular)
                        .fill(startAnimation ? ColorSet.skeleton02 : Color(white: 0.35))
                        .frame(width: getUIScreenBounds().width * 0.43 - 22, height: 21)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 11)
                }
        }
        .animation(.easeIn(duration: 1.0).repeatForever(autoreverses: true), value: startAnimation)
    }
}

