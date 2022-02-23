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
    
    func makeSUT(url: URL = URL(string: "https://abc.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: httpClient)
        return (sut, httpClient)
    }
    
    private func expector(_ sut: RemoteFeedLoader, toCompleteWith result: RemoteFeedLoader.Result, when action: ()-> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { result in
            capturedResults.append(result)
        }
        
       action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
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
            expector(sut, toCompleteWith: .failure(.invalidDataError)) {
                client.complete(withStatus: code, at: index)
            }
        }
        
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expector(sut, toCompleteWith: .failure(.connectivityError)) {
            let clientError = NSError(domain: "test", code: 0, userInfo: nil)
            client.completeWithError(error: clientError)
        }
    }
    
    func test_load_delivers200WithInvalidJSONError() {
        let (sut, client) = makeSUT()
        let invalidJSON = Data("IncorrectJSON".utf8)
        expector(sut, toCompleteWith: .failure(.invalidDataError)) {
            client.complete(withStatus: 200, data: invalidJSON)
        }
    }
    
    
    func test_load_delivers200WithEmptyJSONList() {
        let (sut, client) = makeSUT()
        let emptyJSON = Data("{\"items\": []}".utf8)
        
        expector(sut, toCompleteWith: .sucess([])) {
            client.complete(withStatus: 200, data: emptyJSON)
        }
    }
    
    func test_load_delivers200WithJSONList() {
        let (sut, client) = makeSUT()
        let item1 = FeedItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https:///a")!)
        
        let item1JSON = [
            "id": item1.id.uuidString,
            "image": item1.imageURL.absoluteString
		]
        
        let item2 = FeedItem(id: UUID(),
							 description: "some description",
							 location: "some location",
							 imageURL: URL(string: "https:///b")!)
        
        let item2JSON = [
            "id": item2.id.uuidString,
            "description": item2.description,
            "location": item2.location,
            "image": item2.imageURL.absoluteString
		]
        
		let itemsJSON = ["items": [item1JSON, item2JSON]]
        
        expector(sut, toCompleteWith: .sucess([item1, item2])) {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
            client.complete(withStatus: 200, data: json)
        }
        
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
    
    func complete(withStatus code: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index],
                                       statusCode: code,
                                       httpVersion: nil,
                                       headerFields: nil)!
        
        messages[index].completion(.success(data, response))
    }
}
