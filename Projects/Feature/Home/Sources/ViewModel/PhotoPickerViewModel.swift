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


struct PhotoPickerManager {
    
    static private func uploadImage(_ image: UIImage) async throws -> URL {
        let storageRef = FirebaseManager.shared.storage.reference()
        let imageRef = storageRef.child("mumoryImages/\(UUID().uuidString).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw UploadError.convertError
        }
        
        do {
            _ = try await imageRef.putDataAsync(imageData)
        } catch {
            throw UploadError.uploadFailed
        }
        
        do {
            let url = try await imageRef.downloadURL()
            
            return url
        } catch {
            throw UploadError.urlRetrievalFailed
        }
    }
    
    static func uploadAllImages(selectedImages: [UIImage]) async -> [String] {
        var uploadedImageURLs: [String] = []
        
        await withTaskGroup(of: URL?.self) { group in
            for image in selectedImages {
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
}

enum UploadError: Error {
    case convertError
    case uploadFailed
    case urlRetrievalFailed
}
