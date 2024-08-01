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


final class PhotoPickerViewModel: ObservableObject {
    
    @Published var isPhotoErrorPopUpShown: Bool = false
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
            self.imageSelectionCount = imageSelections.count
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
        if !imageSelections.isEmpty {
            for eachItem in imageSelections {
                Task {
                    if let imageData = try? await eachItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: imageData), !selectedImages.contains(image) {
                            selectedImages.append(image)
                        }
                    }
                }
            }
        }
        
        imageSelections.removeAll()
    }
    
    @MainActor
    func convertDataToImage(imageURLsCount: Int) {
        if !imageSelections.isEmpty {
            for eachItem in imageSelections {
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
    
    func removeIndex(_ index: Int) {
        
    }
    
    func removeAllSelectedImages() {
        selectedImages.removeAll()
    }
    
    func downloadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let image = UIImage(data: data)
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
