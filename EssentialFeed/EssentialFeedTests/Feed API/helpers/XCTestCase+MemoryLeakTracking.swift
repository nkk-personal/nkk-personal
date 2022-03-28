//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Naveen Keerthy on 3/16/22.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
            addTeardownBlock { [weak instance] in
                //Below we are having a strong reference, so its better to make it weak
    //            XCTAssertNil(sut, "Instane should have been deallocatid. Potential memory leak.")
                //Will show the exact lines on where the error is happening.
                XCTAssertNil(instance, "Instane should have been deallocatid. Potential memory leak.", file: file, line: line)
        }
    }
}
