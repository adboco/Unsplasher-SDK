//
//  Statistics.swift
//  Unsplasher
//
//  Created by Adrián Bouza Correa on 21/2/18.
//  Copyright © 2018 adboco. All rights reserved.
//

import Foundation

public struct Statistics: Codable {
    
    public let id: String?
    public let username: String?
    public let downloads: Stat?
    public let views: Stat?
    public let likes: Stat?
    
}

public struct Stat: Codable {
    
    public let total: UInt32
    public let historical: Historical?
    
}

public struct Historical: Codable {
    
    public let change: UInt32
    public let resolution: String
    public let quantity: UInt32
    public let values: [HistoricalValue]?
    
}

public struct HistoricalValue: Codable {
    
    public let date: Date
    public let value: UInt32
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(UInt32.self, forKey: .value)
        
        let dateString = try container.decode(String.self, forKey: .date)
        let formatter = DateFormatter.yyyyMMdd
        if let decodedDate = formatter.date(from: dateString) {
            date = decodedDate
        } else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Date string does not match format expected by formatter.")
        }
    }
    
}
