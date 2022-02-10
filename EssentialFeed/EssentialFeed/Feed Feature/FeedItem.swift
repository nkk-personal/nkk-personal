//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Naveen Keerthy on 12/28/21.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
