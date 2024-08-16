//
//  PhotoPickerViewModel.swift
//  Feature
//
//  Created by 다솔 on 2023/12/07.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import PhotosUI
import Combine
import FirebaseStorage

import Shared


final class PhotoPickerViewModel: ObservableObject {
    
    var photoSelectionCount: Int = 0
    
    @Published private(set) var selectedImages: [UIImage] = [] {
        didSet {
            print("selectedImages didSet")
            self.photoSelectionCount = selectedImages.count
        }
    }
    
    @Published var photoSelections: [PhotosPickerItem] = [] {
        didSet {
            print("imageSelections didSet")
            self.photoSelectionCount = photoSelections.count
            //            setImages(from: imageSelections)
        }
    }
    
    @Published var isPhotoErrorPopUpShown: Bool = false
   
    
    @MainActor
    func convertDataToImage() {
        if !photoSelections.isEmpty {
            for eachItem in photoSelections {
                Task {
                    if let imageData = try? await eachItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: imageData), !selectedImages.contains(image) {
                            selectedImages.append(image)
                        }
                    }
                }
            }
        }
        
        photoSelections.removeAll()
    }
    
    @MainActor
    func convertDataToImage(imageURLsCount: Int) {
        if !photoSelections.isEmpty {
            for eachItem in photoSelections {
                Task {
                    if let imageData = try? await eachItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: imageData) {
                            selectedImages.append(image)
                            
                            if selectedImages.count + imageURLsCount > 3 {
                                selectedImages.removeLast()
                                isPhotoErrorPopUpShown = true
                            }
                        }
                    }
                }
            }
        }
        photoSelections.removeAll()
    }
    
    func removeImage(_ image: UIImage) {
        DispatchQueue.main.async {
            if let index = self.selectedImages.firstIndex(of: image) {
                self.selectedImages.remove(at: index)
//                self.imageSelections.remove(at: index)
            }
        }
    }
    
    func removeIndex(_ index: Int) {
        
    }
    
    func removeAllSelectedImages() {
        selectedImages.removeAll()
    }
}

extension PhotoPickerViewModel {
    private func uploadImage(_ image: UIImage) async throws -> URL {
        let storageRef = FirebaseManager.shared.storage.reference()
        let imageRef = storageRef.child("mumoryImages/\(UUID().uuidString).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw UploadError.dataConversionFailed
        }
        
        let _ = try await imageRef.putDataAsync(imageData)
        
        let url = try await imageRef.downloadURL()
        
        return url
    }
    
    // 모든 이미지를 업로드하고 URL을 가져오는 함수
    func uploadAllImages() async -> [String] {
        var uploadedImageURLs: [String] = []
//        for (index, image) in self.selectedImages.enumerated() {
//            do {
//                let url = try await uploadImage(image)
//                uploadedImageURLs.append(url.absoluteString)
//                print("Image \(index + 1) uploaded successfully.")
//            } catch {
//                print("Failed to upload image \(index + 1): \(error.localizedDescription)")
//            }
//        }
        
        await withTaskGroup(of: URL?.self) { group in
            for image in self.selectedImages {
                group.addTask {
                    do {
                        let url = try await self.uploadImage(image)
                        return url
                    } catch {
                        print("Failed to upload image: \(error.localizedDescription)")
                        return nil
                    }
                }
            }
            
            for await url in group {
                if let url = url {
                    uploadedImageURLs.append(url.absoluteString)
                }
            }
        }
        
        return uploadedImageURLs
    }
    
    enum UploadError: Error {
        case dataConversionFailed
    }
    
//    public func fetchUsers(uIds: [String]) async -> [UserProfile] {
//        return await withTaskGroup(of: UserProfile?.self) { taskGroup -> [UserProfile] in
//            var returnUsers: [UserProfile] = []
//            for id in uIds {
//                taskGroup.addTask {
//                    let user = await FetchManager.shared.fetchUser(uId: id)
//                    if user.nickname == "탈퇴계정" {return nil}
//                    return user
//                }
//            }
//            for await value in taskGroup {
//                guard let user = value else {continue}
//                returnUsers.append(user)
//            }
//            return returnUsers
//        }
//    }
}
