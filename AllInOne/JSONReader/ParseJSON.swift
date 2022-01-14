//
//  ParseJSON.swift
//  JSONReader
//
//  Created by Naveen Keerthy on 1/12/22.
//

import Foundation

// MARK: - Models
struct Todo: Codable {
    var userID: Int?
    var id: Int?
    var title: String?
    var completed: Bool?
}

// MARK: Errors

enum TodoErrors: Error {
    case invalidRequest
    case failedToDecode
    case custom(error: Error)
}


// MARK: Todo Service

struct TodoService {
    
    let url = URL(string: "https://jsonplaceholder.typicode.com/todo")!
    
    func fetch(completion: @escaping (Result<[Todo],Error>) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(TodoErrors.custom(error: error)))
                    return
                }
                if let response = response as?  HTTPURLResponse, response.statusCode == 200 {
                    guard let data = data, let decodeData = try? JSONDecoder().decode([Todo].self, from: data) else {
                        completion(.failure(TodoErrors.failedToDecode))
                        return
                    }
                    completion(.success(decodeData))
                } else {
                    completion(.failure(TodoErrors.invalidRequest))
                }
            }
        }.resume()
    }
    
    func fetchWIthAsynAwait(completion: @escaping (Result<[Todo], Error>) -> Void) -> Void {
    }
    
}
