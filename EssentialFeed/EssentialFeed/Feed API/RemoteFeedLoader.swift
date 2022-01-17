//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Naveen Keerthy on 1/13/22.
//

import Foundation


public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}

public final class RemoteFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivityError
        case invalidDataError
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { error, response in
            
            if response != nil {
                completion(.invalidDataError)
            } else {
                completion(.connectivityError)
            }
            
        }
    }
}
