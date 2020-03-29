//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Ivan Hadzhiiliev on 2020-03-16.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Photo]
}

struct Photo: Codable {
    
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    let thumbnailUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case ispublic
        case isfriend
        case isfamily
        case thumbnailUrl = "url_q"
    }
    
}
