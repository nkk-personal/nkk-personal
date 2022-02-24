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
                let json = makeItemsJSON([])
                client.complete(withStatus: code, data: json, at: index)
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
        let item1 = makeItem(id: UUID(), imageURL: URL(string: "https:///a")!)
        
        let item2 = makeItem(id: UUID(),
							 description: "some description",
							 location: "some location",
							 imageURL: URL(string: "https:///b")!)

        let items = [item1.model, item2.model]
        expector(sut, toCompleteWith: .sucess(items)) {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatus: 200, data: json)
        }
        
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let json = ["id": id.uuidString,
                    "description": description,
                    "location": location,
                    "image": imageURL.absoluteString].reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value {
                acc[e.key] = value
            }
        }
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String:Any]]) -> Data {
        let json = ["items": items]
        return  try! JSONSerialization.data(withJSONObject: json)
    }
    
//    private func makeItemsJSON([[String:Any]]) -> Data {
//
//    }
    
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
    
    func complete(withStatus code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index],
                                       statusCode: code,
                                       httpVersion: nil,
                                       headerFields: nil)!
        
        messages[index].completion(.success(data, response))
    }
}
