//
//  Photo.swift
//  Unsplasher
//
//  Created by Adrian Bouza Correa on 19/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import Foundation

public struct Photo: Codable {
    
    public let id: String
    public let width: UInt32?
    public let height: UInt32?
    public let description: String?
    public let hexColor: String?
    public let user: User?
    public let urls: PhotoURL?
    public let links: Links?
    public let categories: [Category]?
    public var exif: Exif?
    public let downloads: UInt32?
    public let likes: UInt32?
    public var likedByUser: Bool?
    public var location: Location?
    public let currentUserCollections: [Collection]?
    
    public var color: UIColor? {
        guard let colorString = hexColor else {
            return nil
        }
        return UIColor(hex: colorString)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case description
        case hexColor = "color"
        case user
        case urls
        case links
        case categories
        case exif
        case downloads
        case likes
        case likedByUser = "liked_by_user"
        case location
        case currentUserCollections = "current_user_collections"
    }
    
}

public struct PhotoURL: Codable {
    
    public let raw: URL
    public let full: URL
    public let regular: URL
    public let small: URL
    public let thumb: URL
    public let custom: URL?
    
}

public struct Exif: Codable {
    
    public var make: String?
    public var model: String?
    public var exposureTime: String?
    public var aperture: String?
    public var focalLength: String?
    public var iso: UInt32?
    
    private enum CodingKeys: String, CodingKey {
        case make
        case model
        case exposureTime = "exposure_time"
        case aperture
        case focalLength = "focal_length"
        case iso
    }
    
    public init(make: String? = nil, model: String? = nil, exposureTime: String? = nil, aperture: String? = nil, focalLength: String? = nil, iso: UInt32? = nil) {
        self.make = make
        self.model = model
        self.exposureTime = exposureTime
        self.aperture = aperture
        self.focalLength = focalLength
        self.iso = iso
    }
    
}

public struct Location: Codable {
    
    public var city: String?
    public var country: String?
    public var positon: Position?
    public var name: String?
    public var confidential: Bool?
    
}

public struct Position: Codable {
    
    public var latitude: Double
    public var longitude: Double
    
}

public struct Like: Codable {
    
    public let photo: Photo
    public let user: User
    
}
