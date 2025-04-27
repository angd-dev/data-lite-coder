import XCTest
import DataLiteCore
import DLCCommon

@testable import DLCEncoder

final class SingleValueEncoderTests: XCTestCase {
    func testEncodeNil() throws {
        let encoder = SingleValueEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: [],
            userInfo: [:]
        )
        try encoder.encodeNil()
        XCTAssertEqual(encoder.sqliteData, .null)
    }
    
    func testEncodeDate() throws {
        let date = Date()
        let dateEncoder = MockDateEncoder()
        let encoder = SingleValueEncoder(
            dateEncoder: dateEncoder,
            codingPath: [],
            userInfo: [:]
        )
        try encoder.encodeDate(date)
        XCTAssertEqual(encoder.sqliteData, date.sqliteRawValue)
        XCTAssertTrue(dateEncoder.didCallEncode)
    }
    
    func testEncodeValue() throws {
        let encoder = SingleValueEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: [],
            userInfo: [:]
        )
        try encoder.encode("Test String")
        XCTAssertEqual(encoder.sqliteData, .text("Test String"))
    }
    
    func testKeyedContainer() {
        let path = [
            RowCodingKey(intValue: 1),
            RowCodingKey(intValue: 2)
        ]
        let encoder = SingleValueEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: path,
            userInfo: [:]
        )
        let container = encoder.container(
            keyedBy: RowCodingKey.self
        )
        XCTAssertEqual(container.codingPath as? [RowCodingKey], path)
    }
    
    func testUnkeyedContainer() {
        let path = [
            RowCodingKey(intValue: 1),
            RowCodingKey(intValue: 2)
        ]
        let encoder = SingleValueEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: path,
            userInfo: [:]
        )
        let container = encoder.unkeyedContainer()
        XCTAssertTrue(container is FailedEncodingContainer<RowCodingKey>)
        XCTAssertEqual(container.codingPath as? [RowCodingKey], path)
    }
    
    func testSingleValueContainer() {
        let path = [
            RowCodingKey(intValue: 1),
            RowCodingKey(intValue: 2)
        ]
        let encoder = SingleValueEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: path,
            userInfo: [:]
        )
        let container = encoder.singleValueContainer()
        XCTAssertTrue(container is SingleValueContainer<SingleValueEncoder>)
        XCTAssertEqual(container.codingPath as? [RowCodingKey], path)
    }
}

private extension SingleValueEncoderTests {
    final class MockDateEncoder: DateEncoder {
        private(set) var didCallEncode = false
        
        func encode(
            _ date: Date,
            to encoder: any ValueEncoder
        ) throws {
            didCallEncode = true
            try encoder.encode(date)
        }
        
        func encode(
            _ date: Date,
            for key: any CodingKey,
            to encoder: any RowEncoder
        ) throws {
            fatalError()
        }
    }
}
