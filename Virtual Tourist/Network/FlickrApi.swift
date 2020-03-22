//
//  UdacityApi.swift
//  On The Map
//
//  Created by Ivan Hadzhiiliev on 2020-02-15.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class FlickrApi: BaseApi {
    
    static let apiKey = "b4e04ccf95fc8a45be0ec2552ce78816"
    static let SearchLatRange = (-90.0, 90.0)
    static let SearchLonRange = (-180.0, 180.0)
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest?api_key=\(FlickrApi.apiKey)&format=json&nojsoncallback=1&extras=url_q&per_page=24"
        static let apiKeyParam = ""
        
        case search(Double, Double)
        case downloadImage(String)
        
        var stringValue: String {
            switch self {
            case .search(let longitude, let latitude): return Endpoints.base + Endpoints.apiKeyParam + "&method=flickr.photos.search&bbox=\(bboxString(longitude: longitude, latitude: latitude))"
            case .downloadImage(let url): return url
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
    private class func bboxString(longitude: Double, latitude: Double) -> String {
        let minLongitude = max(longitude - 0.5, FlickrApi.SearchLonRange.0)
        let minLatitude = max(latitude - 0.5, FlickrApi.SearchLatRange.0)
        let maxLongitude = min(longitude + 0.5, FlickrApi.SearchLonRange.1)
        let maxLatitude = min(latitude + 0.5, FlickrApi.SearchLatRange.1)
        return "\(minLongitude),\(minLatitude),\(maxLongitude),\(maxLatitude)"
    }
    
    class func searchPhotos(longitude: Double, latitude: Double, completion: @escaping (SearchResponse?, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.search(longitude, latitude).url, responseType: SearchResponse.self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
class func downloadImage(imageUrl: String, completion: @escaping (_ result: NSData?, _ error: Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.downloadImage(imageUrl).url) { data, response, error in
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299, let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completion(data as NSData, nil)
            }
        }
        task.resume()
    }
    
}
