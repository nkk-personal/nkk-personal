//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Naveen Keerthy on 12/28/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
