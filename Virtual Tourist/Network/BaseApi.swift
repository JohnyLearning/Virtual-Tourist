//
//  BaseApi.swift
//  On The Map
//
//  Created by Ivan Hadzhiiliev on 2020-02-15.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class BaseApi {
    
    @discardableResult
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(nil, error)
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ApiError.self, from: data) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, needCleanup: Bool = true, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            logResponse(data: data)
            let range = 5..<data.count
            let newData = needCleanup ? data.subdata(in: range) : data
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ApiError.self, from: newData) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    private class func logResponse(data: Data) {
        if let responseString = String(bytes: data, encoding: .utf8) {
            // The response body seems to be a valid UTF-8 string, so print that.
            print(responseString)
        } else {
            // Otherwise print a hex dump of the body.
            print(data as NSData)
        }
    }
    
}
