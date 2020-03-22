//
//  UdacityError.swift
//  On The Map
//
//  Created by Ivan Hadzhiiliev on 2020-02-16.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

struct ApiError: Codable {
    let status: Int
    let error: String
}

extension ApiError: LocalizedError {
    var errorDescription: String? {
        return error
    }
}
