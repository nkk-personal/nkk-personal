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
    
    struct UnexpectedValuesRepresentationError: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValuesRepresentationError()))
            }
            
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolsStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolsStub.stopInterceptingRequests()
    }
    //Given / When / Then
    func test_getFromURL_performGETRequestWithURL() {
        
//        Given
        let url = anyUrl()
        
        let expectation = expectation(description: "Wait until the request completes")
        URLProtocolsStub.observeRequest{ request in
//            Then
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            expectation.fulfill()
        }
        
//        When
        makeSUT().get(from: url) { _ in
            
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = NSError(domain: "Some error", code: 1)
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        XCTAssertEqual(receivedError as NSError?, requestError)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data:nil, response:nil, error:nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: nil ))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil ))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError() ))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyError() ))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyError() ))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyError() ))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyError() ))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil ))
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func anyUrl() -> URL {
        return URL(string: "https://any.com")!
    }
    
    private func anyData() -> Data {
        return Data("anyData".utf8)
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyUrl(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        URLProtocolsStub.stub(data: data, response: response, error: error )
        
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "wait for completion")
        
        var receivedError: Error?
        sut.get(from: anyUrl()) { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure with error, got \(result) instead", file: file, line: line )
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
}

class URLProtocolsStub: URLProtocol {
//    var receivedURLs = [URL]()
//    private var stubs = [URL: URLSessionDataTask]()
//    private static var stubs = [URL: Stub]()
    private static var stub: Stub?
    private static var requestObserver:((URLRequest) -> Void)?
    
    private struct Stub {
//        let task: HTTPSessionTask
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
        stub = Stub(data: data, response: response, error: error)
    }
    
    static func observeRequest(observer: @escaping (URLRequest) -> Void) {
        requestObserver = observer
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
        requestObserver = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
//        guard let url = request.url else {
//            return false
//        }
//        return URLProtocolsStub.stubs[url] != nil
        requestObserver?(request)
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

