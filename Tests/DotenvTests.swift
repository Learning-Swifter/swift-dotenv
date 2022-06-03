//
//  DotenvTests.swift
//  SwiftDotenvTests
//
//  Created by Brendan Conron on 10/17/21.
//

import SwiftDotenv
import XCTest

final class DotenvTests: XCTestCase {
    
    private static var temporarySaveLocation: String {
        "\(NSTemporaryDirectory())swift-dotenv/"
    }
    
    override func setUpWithError() throws {
        try FileManager.default.createDirectory(
            at: URL(fileURLWithPath: Self.temporarySaveLocation),
            withIntermediateDirectories: true, attributes: nil
        )
    }
    
    override func tearDownWithError() throws {
        if FileManager.default.fileExists(atPath: Self.temporarySaveLocation) {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: Self.temporarySaveLocation))
        }
    }
    
    func testLoadingEnvironment() throws {
        guard let path = Bundle.module.path(forResource: "fixture", ofType: "env") else {
            XCTFail("unable to find env file")
            return
        }
        let env = try Dotenv.load(path: path)
        print(env.values)
        XCTAssertEqual(env.apiKey, .string("some-value"))
        XCTAssertEqual(env.buildNumber, .integer(5))
        XCTAssertEqual(env.identifier, .string("com.app.example"))
        XCTAssertEqual(env.mailTemplate, .string("The \"Quoted\" Title"))
        XCTAssertEqual(env.dbPassphrase, .string("1qaz?#@\"' wsx$"))
        XCTAssertNil(env.nonExistentValue)
    }
    
    func testSavingEnvironment() throws {
        let env = try Environment(values: [
            "apiKey": .string("some-secret"),
            "onboardingEnabled": .boolean(true),
            "networkRetries": .integer(3),
            "networkTimeout": .double(10.5)
        ])
        
        let filePath = Self.temporarySaveLocation + "/test.env"
        try Dotenv.save(environment: env, toPath: filePath)
        
        let stringValue = try String(contentsOf: URL(fileURLWithPath: filePath))
        
        XCTAssertEqual(stringValue, "apiKey=some-secret\nonboardingEnabled=true\nnetworkRetries=3\nnetworkTimeout=10.5\n")
    }
}
