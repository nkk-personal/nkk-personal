//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Naveen Keerthy on 3/4/22.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
            
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
//    func test_getFromURL_createsDataTaskWithURL() {
//        //setting/building
//        let url = URL(string: "https://any.com")!
//        let session = URLSessionSpy()
//
//        let sut = URLSessionHTTPClient(session: session )
//
//        //When
//        sut.get(from: url) { result in
//
//        }
//
//        //Validation/Assertion
//        XCTAssertEqual(session.receivedURLs, [url])
//    }
//
//    func test_getFromURL_resumeDataTaskWithURL() {
//        //setting/building
//        let url = URL(string: "https://any.com")!
//        let session = HTTPSessionSpy()
//        let task = URLSessionDataTaskSpy()
//        session.stub(url: url, task: task)
//        let sut = URLSessionHTTPClient(session: session )
//
//        //When
//        sut.get(from: url) { result in
//
//        }
//
//        //Validation/Assertion
//        XCTAssertEqual(task.resumeCallCount, 1)
//    }
//
    
    func test_getFromURL_failsOnRequestError() {
        URLProtocolsStub.startInterceptingRequests()
//        URLProtocol.registerClass(URLProtocolsStub.self)
        let url = URL(string: "https://any.com")!
//        let session = HTTP()
//        let task = URLSessionDataTaskSpy()
//        session.stub(url: url, task: task)
        let error = NSError(domain: "Some error", code: 1)
        URLProtocolsStub.stub(data: nil, response: nil, error: error )
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "wait for completion")
        
        //When
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertNotNil(receivedError)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
//        URLProtocol.unregisterClass(URLProtocolsStub.self)
        URLProtocolsStub.stopInterceptingRequests()
    }
}

class URLProtocolsStub: URLProtocol {
//    var receivedURLs = [URL]()
//    private var stubs = [URL: URLSessionDataTask]()
//    private static var stubs = [URL: Stub]()
    private static var stub: Stub?
    
    private struct Stub {
//        let task: HTTPSessionTask
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
        stub = Stub(data: data, response: response, error: error)
    }
    
//    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
////        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
////        receivedURLs.append(url)
//        guard let stub = stubs[url] else {
//            fatalError("Couldn't ind stub for \(url)")
//        }
//        completionHandler(nil, nil, stub.error)
//        return stub.task
//    }
    
//    But going with ProtocolsStup approach, we still need to implement few MTLLinkedFunctions
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolsStub.self)
    }
    
    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolsStub.self)
        stub = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
//        guard let url = request.url else {
//            return false
//        }
//        return URLProtocolsStub.stubs[url] != nil
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
//        guard let url = request.url, let stub = URLProtocolsStub.stubs[url] else { return }
        
        if let data = URLProtocolsStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        if let response = URLProtocolsStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = URLProtocolsStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
    }
}

//private class FakeURLSessionDataTask: HTTPSessionTask {
//    func resume() {}
//}
//
//private class URLSessionDataTaskSpy: HTTPSessionTask {
//    var resumeCallCount = 0
//
//    func resume() {
//        resumeCallCount+=1
//    }
//}

