//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Naveen Keerthy on 12/28/21.
//

import XCTest
import EssentialFeed

class HTTPClientSpy: HTTPClient {
    var requestedURLs = [URL]()
    var error: Error?
    func get(from url: URL, completion: @escaping (Error) -> Void){
        if let error = error {
            completion(error)
        }
        self.requestedURLs.append(url)
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    let client = HTTPClientSpy()
    let url = URL(string: "test")
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestedDataFromURL() {
        
        let url = URL(string: "https://keerthy.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURL() {
        let url = URL(string: "https://a-given.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        var capturedErrors = [RemoteFeedLoader.Error]()
        
        client.error = NSError(domain: "test", code: 0, userInfo: nil)

        sut.load { error in capturedErrors.append(error) }
        
        XCTAssertEqual(capturedErrors, [.connectivityError])
    }
    
    func makeSUT(url: URL = URL(string: "https://abc.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: httpClient)
        return (sut, httpClient)
    }
}
