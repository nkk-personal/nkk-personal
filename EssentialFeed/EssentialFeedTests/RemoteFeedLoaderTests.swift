//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Naveen Keerthy on 12/28/21.
//

import XCTest
import EssentialFeed

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
        sut.load(completion: { _ in })
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURL() {
        let url = URL(string: "https://a-given.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load(completion: { _ in })
        sut.load{ _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnNo200Response() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            
            sut.load { error in
                capturedErrors.append(error)
            }
            client.complete(withStatus: code, at: index)
            XCTAssertEqual(capturedErrors, [.invalidDataError])
        }
        
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        var capturedErrors = [RemoteFeedLoader.Error]()
        
        sut.load { error in
            capturedErrors.append(error)
        }
        let clientError = NSError(domain: "test", code: 0, userInfo: nil)
        client.completeWithError(error: clientError)
        XCTAssertEqual(capturedErrors, [.connectivityError])
    }
    
    
    
    func makeSUT(url: URL = URL(string: "https://abc.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: httpClient)
        return (sut, httpClient)
    }
}

class HTTPClientSpy: HTTPClient {
    

    private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
    var requestedURLs: [URL] {
        return messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void){
        messages.append((url, completion))
    }
    
    func completeWithError(error: NSError, index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatus code: Int, at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index],
                                       statusCode: code,
                                       httpVersion: nil,
                                       headerFields: nil)!
        
        messages[index].completion(.success(response))
    }
}
