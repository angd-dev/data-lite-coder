import XCTest
import DataLiteCore
import DLCCommon

@testable import DLCEncoder

final class SingleRowEncoderTests: XCTestCase {
    func testSetValueForKey() throws {
        let encoder = SingleRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: [],
            userInfo: [:]
        )
        try encoder.set(SQLiteRawValue.int(42), for: CodingKeys.key1)
        try encoder.set(SQLiteRawValue.real(3.14), for: CodingKeys.key2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1], .int(42))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2], .real(3.14))
        XCTAssertEqual(encoder.count, encoder.sqliteData.count)
    }
    
    func testSetInvalidValueForKey() {
        let value = "Test Value"
        let path = [CodingKeys.key1]
        let encoder = SingleRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: path,
            userInfo: [:]
        )
        XCTAssertThrowsError(
            try encoder.set(value, for: CodingKeys.key2)
        ) { error in
            guard case let EncodingError.invalidValue(thrownValue, context) = error else {
                return XCTFail("Expected EncodingError.invalidValue, got \(error)")
            }
            XCTAssertEqual(thrownValue as? String, value)
            XCTAssertEqual(context.codingPath as? [CodingKeys], path + [.key2])
            XCTAssertEqual(context.debugDescription, "The value does not match SQLiteRawValue")
        }
    }
    
    func testEncodeNilForKey() throws {
        let encoder = SingleRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: [],
            userInfo: [:]
        )
        try encoder.encodeNil(for: CodingKeys.key1)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1], .null)
        XCTAssertEqual(encoder.count, encoder.sqliteData.count)
    }
    
    func testEncodeDateForKey() throws {
        let date = Date()
        let mockDateEncoder = MockDateEncoder()
        let encoder = SingleRowEncoder(
            dateEncoder: mockDateEncoder,
            codingPath: [],
            userInfo: [:]
        )
        
        try encoder.encodeDate(date, for: CodingKeys.key1)
        
        XCTAssertTrue(mockDateEncoder.didCallEncode)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1], date.sqliteRawValue)
        XCTAssertEqual(encoder.count, encoder.sqliteData.count)
    }
    
    func testEncodeValueForKey() throws {
        let encoder = SingleRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: [],
            userInfo: [:]
        )
        
        try encoder.encode(123, for: CodingKeys.key1)
        try encoder.encode(3.14, for: CodingKeys.key2)
        try encoder.encode("Hello", for: CodingKeys.key3)
        
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1], .int(123))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2], .real(3.14))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key3], .text("Hello"))
        XCTAssertEqual(encoder.count, encoder.sqliteData.count)
    }
    
    func testEncoderForKey() throws {
        let path = [CodingKeys.key1]
        let encoder = SingleRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: path,
            userInfo: [:]
        )
        
        let key = CodingKeys.key2
        let nestedEncoder = try encoder.encoder(for: key)
        
        XCTAssertTrue(nestedEncoder is SingleValueEncoder)
        XCTAssertEqual(nestedEncoder.codingPath as? [CodingKeys], path + [key])
    }
    
    func testKeyedContainer() {
        let path = [CodingKeys.key1]
        let encoder = SingleRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: path,
            userInfo: [:]
        )
        let container = encoder.container(keyedBy: CodingKeys.self)
        XCTAssertEqual(container.codingPath as? [CodingKeys], path)
    }
    
    func testUnkeyedContainer() {
        let path = [CodingKeys.key1]
        let encoder = SingleRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: path,
            userInfo: [:]
        )
        let container = encoder.unkeyedContainer()
        
        XCTAssertTrue(container is FailedEncodingContainer<RowCodingKey>)
        XCTAssertEqual(container.codingPath as? [CodingKeys], path)
    }

    func testSingleValueContainer() {
        let path = [CodingKeys.key1]
        let encoder = SingleRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: path,
            userInfo: [:]
        )
        let container = encoder.singleValueContainer()
        
        XCTAssertTrue(container is FailedEncodingContainer<RowCodingKey>)
        XCTAssertEqual(container.codingPath as? [CodingKeys], path)
    }
}

private extension SingleRowEncoderTests {
    enum CodingKeys: CodingKey {
        case key1
        case key2
        case key3
    }
    
    final class MockDateEncoder: DateEncoder {
        private(set) var didCallEncode = false
        
        func encode(
            _ date: Date,
            to encoder: any ValueEncoder
        ) throws {
            fatalError()
        }
        
        func encode(
            _ date: Date,
            for key: any CodingKey,
            to encoder: any RowEncoder
        ) throws {
            didCallEncode = true
            try encoder.encode(date, for: key)
        }
    }
}
