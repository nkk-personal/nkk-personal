//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Naveen Keerthy on 1/13/22.
//

import Foundation

public final class RemoteFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivityError
        case invalidDataError
    }
    
    public enum Result: Equatable {
        case sucess([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response ):
                if let items = try?
                    FeedItemMapper.map(data, response) {
                    completion(.sucess(items))
                } else {
                    completion(.failure(.invalidDataError))
                }
            case .failure:
                completion(.failure(.connectivityError))
            }
            
        }
    }
}

private class FeedItemMapper {
    
    //can hide both the structs inside FeedItemMapper so no one can access or just leave it outside or even you can put it inside the static func (doesnt look good though) https://academy.essentialdeveloper.com/courses/447455/lectures/8732933 around 35.32
    private struct Root: Decodable {
        let items: [Item]
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidDataError
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map({ $0.item })
    }
}
