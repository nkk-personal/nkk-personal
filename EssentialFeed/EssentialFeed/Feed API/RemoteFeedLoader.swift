//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Naveen Keerthy on 1/13/22.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivityError
        case invalidDataError
    }
    public typealias Result = LoadFeedResult<Error>
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else {return}
            switch result {
            case let .success(data, response ):
                completion(FeedItemMapper.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivityError))
            }
        }
    }
}
