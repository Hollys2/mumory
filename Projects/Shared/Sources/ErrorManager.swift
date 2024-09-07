//
//  ErrorManager.swift
//  Shared
//
//  Created by 다솔 on 2024/07/06.
//  Copyright © 2024 hollys. All rights reserved.
//


import Foundation

enum FetchError: Error {
    case documentIdError
    case getDocumentError
    case documentNotFound
    case invalidData
    case decodingError
}

extension FetchError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .documentIdError:
            return NSLocalizedString("Failed to get the document id.", comment: "Document ID not found error")            
        case .getDocumentError:
            return NSLocalizedString("Failed to get the document.", comment: "Get document error")
        case .documentNotFound:
            return NSLocalizedString("The requested document was not found.", comment: "Document not found error")
        case .invalidData:
            return NSLocalizedString("The data retrieved is invalid.", comment: "Invalid data error")
        case .decodingError:
            return NSLocalizedString("Failed to decode the data.", comment: "Decoding error")
        }
    }
}

