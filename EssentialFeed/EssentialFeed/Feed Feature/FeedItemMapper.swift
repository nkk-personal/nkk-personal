//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Naveen Keerthy on 2/26/22.
//

import Foundation

internal class FeedItemMapper {
    
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
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidDataError
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map({ $0.item })
    }
}
