import XCTest
import DataLiteCore

@testable import DLCEncoder

final class SingleValueContainerTests: XCTestCase {
    func testEncodeNil() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encodeNil()
        XCTAssertEqual(encoder.sqliteData, .null)
    }
    
    func testEncodeBool() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        
        try container.encode(true)
        XCTAssertEqual(encoder.sqliteData, .int(1))
        
        try container.encode(false)
        XCTAssertEqual(encoder.sqliteData, .int(0))
    }
    
    func testEncodeString() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encode("test string")
        XCTAssertEqual(encoder.sqliteData, .text("test string"))
    }
    
    func testEncodeDouble() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encode(Double(3.14))
        XCTAssertEqual(encoder.sqliteData, .real(3.14))
    }
    
    func testEncodeFloat() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encode(Float(3.14))
        XCTAssertEqual(encoder.sqliteData, .real(Double(Float(3.14))))
    }
    
    func testEncodeInt() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encode(Int(42))
        XCTAssertEqual(encoder.sqliteData, .int(42))
    }
    
    func testEncodeInt8() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encode(Int8(8))
        XCTAssertEqual(encoder.sqliteData, .int(Int64(8)))
    }
    
    func testEncodeInt16() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encode(Int16(16))
        XCTAssertEqual(encoder.sqliteData, .int(Int64(16)))
    }
    
    func testEncodeInt32() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encode(Int32(32))
        XCTAssertEqual(encoder.sqliteData, .int(Int64(32)))
    }
    
    func testEncodeInt64() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encode(Int64(64))
        XCTAssertEqual(encoder.sqliteData, .int(64))
    }
    
    func testEncodeUInt() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encode(UInt(42))
        XCTAssertEqual(encoder.sqliteData, .int(42))
    }
    
    func testEncodeUInt8() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encode(UInt8(8))
        XCTAssertEqual(encoder.sqliteData, .int(8))
    }
    
    func testEncodeUInt16() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encode(UInt16(16))
        XCTAssertEqual(encoder.sqliteData, .int(16))
    }
    
    func testEncodeUInt32() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encode(UInt32(32))
        XCTAssertEqual(encoder.sqliteData, .int(32))
    }
    
    func testEncodeUInt64() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encode(UInt64(64))
        XCTAssertEqual(encoder.sqliteData, .int(64))
    }
    
    func testEncodeDate() throws {
        let date = Date()
        let dateString = ISO8601DateFormatter().string(from: date)
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encode(date)
        XCTAssertEqual(encoder.sqliteData, .text(dateString))
    }
    
    func testEncodeRawRepresentable() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encode(RawRepresentableModel.test)
        XCTAssertEqual(encoder.sqliteData, .text(RawRepresentableModel.test.rawValue))
    }
    
    func testEncodeEncodable() throws {
        let encoder = MockSingleValueEncoder()
        let container = SingleValueContainer(encoder: encoder, codingPath: [])
        try container.encode(EncodableModel.test)
        XCTAssertEqual(encoder.sqliteData, .text(EncodableModel.test.rawValue))
    }
}

private extension SingleValueContainerTests {
    enum RawRepresentableModel: String, Encodable, SQLiteRawRepresentable {
        case test
    }
    
    enum EncodableModel: String, Encodable {
        case test
    }
    
    final class MockDateEncoder: DateEncoder {
        func encode(_ date: Date, to encoder: any ValueEncoder) throws {
            let formatter = ISO8601DateFormatter()
            let dateString = formatter.string(from: date)
            try encoder.encode(dateString)
        }
        
        func encode(_ date: Date, for key: any CodingKey, to encoder: any RowEncoder) throws {
            fatalError()
        }
    }
    
    final class MockSingleValueEncoder: ValueEncoder {
        private(set) var sqliteData: SQLiteRawValue?
        let dateEncoder: any DateEncoder
        let codingPath: [any CodingKey]
        let userInfo: [CodingUserInfoKey: Any]
        
        init(
            sqliteData: SQLiteRawValue? = nil,
            dateEncoder: any DateEncoder = MockDateEncoder(),
            codingPath: [any CodingKey] = [],
            userInfo: [CodingUserInfoKey: Any] = [:]
        ) {
            self.sqliteData = sqliteData
            self.dateEncoder = dateEncoder
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
        
        func encodeNil() throws {
            sqliteData = .null
        }
        
        func encodeDate(_ date: Date) throws {
            try dateEncoder.encode(date, to: self)
        }
        
        func encode<T: SQLiteRawBindable>(_ value: T) throws {
            sqliteData = value.sqliteRawValue
        }
        
        func container<Key: CodingKey>(
            keyedBy type: Key.Type
        ) -> KeyedEncodingContainer<Key> {
            fatalError()
        }
        
        func unkeyedContainer() -> any UnkeyedEncodingContainer {
            fatalError()
        }
        
        func singleValueContainer() -> any SingleValueEncodingContainer {
            SingleValueContainer(encoder: self, codingPath: codingPath)
        }
    }
}
