//
//  PhotoRequests.swift
//  Unsplasher
//
//  Created by Adrián Bouza Correa on 27/02/2018.
//  Copyright © 2018 adboco. All rights reserved.
//

import Foundation
import Alamofire

final public class PhotoRequests: Paginable {
    
    private var manager: Unsplash
    
    init(_ manager: Unsplash) {
        self.manager = manager
    }
    
    typealias paginableType = [Photo]
    
    /// Get list of photos
    ///
    /// - Parameters:
    ///   - page: Page
    ///   - perPage: Number of photos per page
    ///   - orderBy: Order
    ///   - completion: Completion handler
    public func photos(page: Int? = nil, perPage: Int? = nil, orderBy: Unsplash.OrderBy? = .popular, curated: Bool = false, completion: @escaping (PhotoListResult) -> Void) {
        var parameters: Parameters = [:]
        if let page = page {
            parameters["page"] = page
        }
        if let perPage = perPage {
            parameters["per_page"] = perPage
        }
        if let orderBy = orderBy {
            parameters["order_by"] = orderBy
        }
        
        let url = Unsplash.photosURLString + (curated ? "/curated" : "")
        self.manager.request(url: url, parameters: parameters, expectedType: [Photo].self, completion: completion)
    }
    
    /// Get a photo by id
    ///
    /// - Parameters:
    ///   - id: Identifier
    ///   - width: Width
    ///   - height: Height
    ///   - rect: Rect (format: x,y,width,height)
    ///   - completion: Completion handler
    public func photo(id: String, width: UInt32? = nil, height: UInt32? = nil, rect: String? = nil, completion: @escaping (PhotoResult) -> Void) {
        var parameters: Parameters = [:]
        if let width = width {
            parameters["w"] = width
        }
        if let height = height {
            parameters["h"] = height
        }
        if let rect = rect {
            let dimensions = rect.split(separator: ",").flatMap({ UInt32($0) })
            if dimensions.count == 4 {
                parameters["rect"] = rect
            }
        }
        let url = Unsplash.photosURLString + "/\(id)"
        self.manager.request(url: url, parameters: parameters, expectedType: Photo.self, completion: completion)
    }
    
    /// Update photo info
    ///
    /// - Parameters:
    ///   - photo: Photo to update
    ///   - completion: Completion handler
    public func update(_ photo: Photo, completion: @escaping (PhotoResult) -> Void) {
        let requiredScope: Unsplash.PermissionScope = .writePhotos
        guard self.manager.scopes.contains(requiredScope) else {
            completion(.failure(UnsplashError.scopeRequiredError(requiredScope)))
            return
        }
        var parameters: Parameters = [:]
        if let location = photo.location {
            var locationParameters: [String: Any] = [:]
            if let latitude = location.positon?.latitude {
                locationParameters["latitude"] = latitude
            }
            if let longitude = location.positon?.longitude {
                locationParameters["longitude"] = longitude
            }
            if let name = location.name {
                locationParameters["name"] = name
            }
            if let city = location.city {
                locationParameters["city"] = city
            }
            if let country = location.country {
                locationParameters["country"] = country
            }
            if let confidential = location.confidential {
                locationParameters["confidential"] = confidential
            }
            parameters["location"] = locationParameters
        }
        if let exif = photo.exif {
            var exifParameters: [String: Any] = [:]
            if let make = exif.make {
                exifParameters["make"] = make
            }
            if let model = exif.model {
                exifParameters["model"] = model
            }
            if let exposureTime = exif.exposureTime {
                exifParameters["exposure_time"] = exposureTime
            }
            if let aperture = exif.aperture {
                exifParameters["aperture_value"] = aperture
            }
            if let focal = exif.focalLength {
                exifParameters["focal_length"] = focal
            }
            if let iso = exif.iso {
                exifParameters["iso_speed_ratings"] = iso
            }
            parameters["exif"] = exifParameters
        }
        let url = Unsplash.photosURLString + "/\(photo.id)"
        self.manager.request(url: url, method: .put, parameters: parameters, expectedType: Photo.self, completion: completion)
    }
    
    /// Like a photo
    ///
    /// - Parameters:
    ///   - id: Photo ID
    ///   - completion: Completion handler
    public func like(id: String, completion: @escaping (LikeResult) -> Void) {
        let requiredScope: Unsplash.PermissionScope = .writeLikes
        guard self.manager.scopes.contains(requiredScope) else {
            completion(.failure(UnsplashError.scopeRequiredError(requiredScope)))
            return
        }
        let url = Unsplash.photosURLString + "/\(id)" + "/like"
        self.manager.request(url: url, method: .post, expectedType: Like.self, completion: completion)
    }
    
    /// Dislike a photo
    ///
    /// - Parameters:
    ///   - id: Photo ID
    ///   - completion: Completion handler
    public func unlike(id: String, completion: @escaping (LikeResult) -> Void) {
        let requiredScope: Unsplash.PermissionScope = .writeLikes
        guard self.manager.scopes.contains(requiredScope) else {
            completion(.failure(UnsplashError.scopeRequiredError(requiredScope)))
            return
        }
        let url = Unsplash.photosURLString + "/\(id)" + "/like"
        self.manager.request(url: url, method: .delete, expectedType: Like.self, completion: completion)
    }
    
    /// Get random photos
    ///
    /// - Parameters:
    ///   - collectionIds: Array of collection ids
    ///   - featured: Featured
    ///   - username: Username
    ///   - query: Query (uncompatible with collectionIds)
    ///   - width: Width
    ///   - height: Height
    ///   - orientation: Orientation
    ///   - count: Count
    ///   - completion: Completion handler
    public func randomPhotos(collectionIds: [UInt32]? = nil, featured: Bool? = nil, username: String? = nil, query: String? = nil, width: UInt32? = nil, height: UInt32? = nil, orientation: Unsplash.Orientation? = nil, count: UInt32 = 1, completion: @escaping (PhotoListResult) -> Void) {
        var parameters: Parameters = [:]
        if let collectionIds = collectionIds {
            parameters["collections"] = collectionIds.map({ "\($0)" }).joined(separator: ",")
        }
        if let featured = featured {
            parameters["featured"] = featured
        }
        if let username = username {
            parameters["username"] = username
        }
        if let query = query, collectionIds == nil { // Can't use collections and query in the same request
            parameters["query"] = query
        }
        if let width = width {
            parameters["w"] = width
        }
        if let height = height {
            parameters["h"] = height
        }
        if let orientation = orientation {
            parameters["orientation"] = orientation.rawValue
        }
        if 1...30 ~= count {
            parameters["count"] = count
        } else {
            completion(.failure(UnsplashError.wrongCountError))
        }
        let url = Unsplash.photosURLString + "/random"
        self.manager.request(url: url, parameters: parameters, expectedType: [Photo].self, completion: completion)
    }
    
    /// Get a random photo
    ///
    /// - Parameters:
    ///   - collectionIds: Array of collection ids
    ///   - featured: Featured
    ///   - username: Username
    ///   - query: Query (uncompatible with collectionIds)
    ///   - width: Width
    ///   - height: Height
    ///   - orientation: Orientation
    ///   - completion: Completion handler
    public func randomPhoto(collectionIds: [UInt32]? = nil, featured: Bool? = nil, username: String? = nil, query: String? = nil, width: UInt32? = nil, height: UInt32? = nil, orientation: Unsplash.Orientation? = nil, completion: @escaping (PhotoResult) -> Void) {
        var parameters: Parameters = [:]
        if let collectionIds = collectionIds {
            parameters["collections"] = collectionIds.map({ "\($0)" }).joined(separator: ",")
        }
        if let featured = featured {
            parameters["featured"] = featured
        }
        if let username = username {
            parameters["username"] = username
        }
        if let query = query, collectionIds == nil { // Can't use collections and query in the same request
            parameters["query"] = query
        }
        if let width = width {
            parameters["w"] = width
        }
        if let height = height {
            parameters["h"] = height
        }
        if let orientation = orientation {
            parameters["orientation"] = orientation.rawValue
        }
        let url = Unsplash.photosURLString + "/random"
        self.manager.request(url: url, parameters: parameters, expectedType: Photo.self, completion: completion)
    }
    
    /// Get a download link for a given photo
    ///
    /// - Parameters:
    ///   - photoId: Photo Identifier
    ///   - completion: Completion hanlder
    public func downloadLink(id: String, completion: @escaping (LinkResult) -> Void) {
        let url = Unsplash.photosURLString + "/\(id)" + "/download"
        self.manager.request(url: url, expectedType: Link.self, completion: completion)
    }
    
    // MARK: - Statistics
    
    /// Get photo statistics by id
    ///
    /// - Parameters:
    ///   - photoId: Photo Id
    ///   - resolution: Resolution
    ///   - quantity: Quantity
    ///   - completion: Completion handler
    public func statistics(photoId: String, resolution: Unsplash.StatisticsResolution? = nil, quantity: UInt32 = 30, completion: @escaping (StatisticsResult) -> Void) {
        var parameters: Parameters = [:]
        if let resolution = resolution {
            parameters["resolution"] = resolution
        }
        if 1...30 ~= quantity {
            parameters["quantity"] = quantity
        } else {
            completion(.failure(UnsplashError.wrongQuantityError))
        }
        let url = Unsplash.photosURLString + "/\(photoId)" + "/statistics"
        self.manager.request(url: url, parameters: parameters, expectedType: Statistics.self, completion: completion)
    }
    
}
