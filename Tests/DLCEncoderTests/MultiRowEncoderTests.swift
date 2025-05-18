import XCTest
import DataLiteCore
import DLCCommon

@testable import DLCEncoder

final class MultiRowEncoderTests: XCTestCase {
    func testSetValueForKey() throws {
        let encoder = MultiRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: [],
            userInfo: [:]
        )
        try encoder.set(SQLiteRow(), for: RowCodingKey(intValue: 0))
        try encoder.set(SQLiteRow(), for: RowCodingKey(intValue: 1))
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.count, encoder.sqliteData.count)
    }
    
    func testSetInvalidValueForKey() {
        let value = "Test Value"
        let path = [RowCodingKey(intValue: 0)]
        let key = RowCodingKey(intValue: 1)
        let encoder = MultiRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: path,
            userInfo: [:]
        )
        XCTAssertThrowsError(
            try encoder.set(value, for: key)
        ) { error in
            guard case let EncodingError.invalidValue(thrownValue, context) = error else {
                return XCTFail("Expected EncodingError.invalidValue, got \(error)")
            }
            XCTAssertEqual(thrownValue as? String, value)
            XCTAssertEqual(context.codingPath as? [RowCodingKey], path + [key])
            XCTAssertEqual(context.debugDescription, "Expected value of type SQLiteRow")
        }
    }
    
    func testEncodeNilThrows() {
        let key = RowCodingKey(intValue: 1)
        let path = [RowCodingKey(intValue: 0)]
        let encoder = MultiRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: path,
            userInfo: [:]
        )
        
        XCTAssertThrowsError(try encoder.encodeNil(for: key)) { error in
            guard case let EncodingError.invalidValue(_, context) = error else {
                return XCTFail("Expected EncodingError.invalidValue, got \(error)")
            }
            XCTAssertEqual(context.codingPath as? [RowCodingKey], path + [key])
            XCTAssertEqual(context.debugDescription, "Attempted to encode nil, but it's not supported.")
        }
    }
    
    func testEncodeDateThrows() {
        let key = RowCodingKey(intValue: 2)
        let path = [RowCodingKey(intValue: 0)]
        let encoder = MultiRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: path,
            userInfo: [:]
        )
        let date = Date()
        
        XCTAssertThrowsError(try encoder.encodeDate(date, for: key)) { error in
            guard case let EncodingError.invalidValue(thrownValue, context) = error else {
                return XCTFail("Expected EncodingError.invalidValue, got \(error)")
            }
            XCTAssertEqual(thrownValue as? Date, date)
            XCTAssertEqual(context.codingPath as? [RowCodingKey], path + [key])
            XCTAssertEqual(context.debugDescription, "Attempted to encode Date, but it's not supported.")
        }
    }
    
    func testEncodeRawBindableThrows() {
        let value = "Test Value"
        let path = [RowCodingKey(intValue: 0)]
        let key = RowCodingKey(intValue: 1)
        let encoder = MultiRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: path,
            userInfo: [:]
        )
        
        XCTAssertThrowsError(try encoder.encode(value, for: key)) { error in
            guard case let EncodingError.invalidValue(thrownValue, context) = error else {
                return XCTFail("Expected EncodingError.invalidValue, got \(error)")
            }
            XCTAssertEqual(thrownValue as? String, value)
            XCTAssertEqual(context.codingPath as? [RowCodingKey], path + [key])
            XCTAssertEqual(
                context.debugDescription,
                "Attempted to encode \(type(of: value)), but it's not supported."
            )
        }
    }
    
    func testEncoderForKey() throws {
        let path = [RowCodingKey(intValue: 0)]
        let key = RowCodingKey(intValue: 1)
        let encoder = MultiRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: path,
            userInfo: [:]
        )
        
        let nestedEncoder = try encoder.encoder(for: key)
        
        XCTAssertTrue(nestedEncoder is SingleRowEncoder)
        XCTAssertEqual(nestedEncoder.codingPath as? [RowCodingKey], path + [key])
    }
    
    func testKeyedContainer() {
        let path = [RowCodingKey(intValue: 0)]
        let encoder = MultiRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: path,
            userInfo: [:]
        )
        let container = encoder.container(keyedBy: RowCodingKey.self)
        XCTAssertEqual(container.codingPath as? [RowCodingKey], path)
    }
    
    func testUnkeyedContainer() {
        let path = [RowCodingKey(intValue: 0)]
        let encoder = MultiRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: path,
            userInfo: [:]
        )
        let container = encoder.unkeyedContainer()
        
        XCTAssertTrue(container is UnkeyedContainer<MultiRowEncoder>)
        XCTAssertEqual(container.codingPath as? [RowCodingKey], path)
    }

    func testSingleValueContainer() {
        let path = [RowCodingKey(intValue: 0)]
        let encoder = MultiRowEncoder(
            dateEncoder: MockDateEncoder(),
            codingPath: path,
            userInfo: [:]
        )
        let container = encoder.singleValueContainer()
        
        XCTAssertTrue(container is FailedEncodingContainer<RowCodingKey>)
        XCTAssertEqual(container.codingPath as? [RowCodingKey], path)
    }
}

private extension MultiRowEncoderTests {
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
            fatalError()
        }
    }
}
