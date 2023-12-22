//
//  PhotoPickerViewModel.swift
//  Feature
//
//  Created by 다솔 on 2023/12/07.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import PhotosUI

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
        imageSelections.removeAll()
    }
    
    func removeImage(_ image: UIImage) {
        DispatchQueue.main.async {
            if let index = self.selectedImages.firstIndex(of: image) {
                self.selectedImages.remove(at: index)
                //                self.imageSelections.remove(at: index)
            }
        }
    }
}
