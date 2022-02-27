//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Naveen Keerthy on 12/28/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
