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
    
    init(session: URLSession) {
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
    func test_getFromURL_resumeDataTaskWithURL() {
        //setting/building
        let url = URL(string: "https://any.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session )
        
        //When
        sut.get(from: url) { result in
            
        }
        
        //Validation/Assertion
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://any.com")!
        let session = URLSessionSpy()
//        let task = URLSessionDataTaskSpy()
//        session.stub(url: url, task: task)
        let error = NSError(domain: "Some error", code: 1)
        session.stub(url: url, error: error )
        let sut = URLSessionHTTPClient(session: session )
        
        let exp = expectation(description: "wait for completion")
        
        //When
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

class URLSessionSpy: URLSession {
//    var receivedURLs = [URL]()
//    private var stubs = [URL: URLSessionDataTask]()
    private var stubs = [URL: Stub]()
    
    private struct Stub {
        let task: URLSessionDataTask
        let error: Error?
    }
    
    func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
        stubs[url] = Stub(task: task, error: error)
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
//        receivedURLs.append(url)
        guard let stub = stubs[url] else {
            fatalError("Couldn't ind stub for \(url)")
        }
        completionHandler(nil, nil, stub.error)
        return stub.task
    }
}

private class FakeURLSessionDataTask: URLSessionDataTask {
    override func resume() {}
}

private class URLSessionDataTaskSpy: URLSessionDataTask {
    var resumeCallCount = 0
    
    override func resume() {
        resumeCallCount+=1
    }
}

