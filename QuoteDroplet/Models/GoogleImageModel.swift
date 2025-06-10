//
//  GoogleImageModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-23.
//

import Foundation

struct GoogleImageSearchResponse: Decodable {
    let items: [ImageItem]?
    
    struct ImageItem: Decodable {
        let link: String
        let image: ImageInfo?
    }
    
    struct ImageInfo: Decodable {
        let thumbnailLink: String?
        let contextLink: String?
    }
}

// Keep for backward compatibility
typealias TestModel = GoogleImageSearchResponse
