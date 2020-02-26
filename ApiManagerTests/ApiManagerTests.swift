//
//  ApiManagerTests.swift
//  ApiManagerTests
//
//  Created by Don on 2/5/20.
//  Copyright © 2020 Don. All rights reserved.
//

import XCTest
@testable import ApiManager


class ApiManagerTests: XCTestCase {

	var baseURL = "http://185.55.226.129:3000/"
	var manager: ApiManager!
    override func setUp() {
		super.setUp()
		manager = ApiManager(baseURL)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
	func test_doesSetBaseURL() {

		XCTAssertEqual(manager.baseURL, baseURL, "wrong base URL")
	}
}
