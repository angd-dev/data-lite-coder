import XCTest
import DataLiteCore
import DLCCommon

@testable import DLCEncoder

final class KeyedContainerTests: XCTestCase {
    func testEncodeNil() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeNil(forKey: .key1)
        
        XCTAssertEqual(encoder.sqliteData.count, 1)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .null)
    }
    
    func testEncodeBool() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent(true, forKey: .key1)
        try container.encodeIfPresent(false, forKey: .key2)
        try container.encodeIfPresent(nil as Bool?, forKey: .key3)
        
        XCTAssertEqual(encoder.sqliteData.count, 3)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .int(1))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .int(0))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key3.stringValue], .null)
    }
    
    func testEncodeString() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent("test", forKey: .key1)
        try container.encodeIfPresent(nil as String?, forKey: .key2)
        
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .text("test"))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .null)
    }
    
    func testEncodeDouble() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent(Double(3.14), forKey: .key1)
        try container.encodeIfPresent(nil as Double?, forKey: .key2)
        
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .real(3.14))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .null)
    }
    
    func testEncodeFloat() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent(Float(3.14), forKey: .key1)
        try container.encodeIfPresent(nil as Float?, forKey: .key2)
        
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .real(Double(Float(3.14))))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .null)
    }
    
    func testEncodeInt() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent(Int(42), forKey: .key1)
        try container.encodeIfPresent(nil as Int?, forKey: .key2)
        
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .int(42))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .null)
    }
    
    func testEncodeInt8() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent(Int8(8), forKey: .key1)
        try container.encodeIfPresent(nil as Int8?, forKey: .key2)
        
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .int(Int64(8)))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .null)
    }
    
    func testEncodeInt16() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent(Int16(16), forKey: .key1)
        try container.encodeIfPresent(nil as Int16?, forKey: .key2)
        
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .int(Int64(16)))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .null)
    }
    
    func testEncodeInt32() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent(Int32(32), forKey: .key1)
        try container.encodeIfPresent(nil as Int32?, forKey: .key2)
        
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .int(Int64(32)))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .null)
    }
    
    func testEncodeInt64() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent(Int64(64), forKey: .key1)
        try container.encodeIfPresent(nil as Int64?, forKey: .key2)
        
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .int(64))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .null)
    }
    
    func testEncodeUInt() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent(UInt(42), forKey: .key1)
        try container.encodeIfPresent(nil as UInt?, forKey: .key2)
        
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .int(42))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .null)
    }
    
    func testEncodeUInt8() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent(UInt8(8), forKey: .key1)
        try container.encodeIfPresent(nil as UInt8?, forKey: .key2)
        
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .int(8))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .null)
    }
    
    func testEncodeUInt16() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent(UInt16(16), forKey: .key1)
        try container.encodeIfPresent(nil as UInt16?, forKey: .key2)
        
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .int(16))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .null)
    }
    
    func testEncodeUInt32() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent(UInt32(32), forKey: .key1)
        try container.encodeIfPresent(nil as UInt32?, forKey: .key2)
        
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .int(32))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .null)
    }
    
    func testEncodeUInt64() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent(UInt64(64), forKey: .key1)
        try container.encodeIfPresent(nil as UInt64?, forKey: .key2)
        
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .int(64))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .null)
    }
    
    func testEncodeDate() throws {
        let date = Date()
        let dateString = ISO8601DateFormatter().string(from: date)
        
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent(date, forKey: .key1)
        try container.encodeIfPresent(nil as Date?, forKey: .key2)
        
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .text(dateString))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .null)
    }
    
    func testEncodeRawRepresentable() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent(RawRepresentableModel.test, forKey: .key1)
        try container.encodeIfPresent(nil as RawRepresentableModel?, forKey: .key2)
        
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .text(RawRepresentableModel.test.rawValue))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .null)
    }
    
    func testEncodeEncodable() throws {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: []
            )
        )
        
        try container.encodeIfPresent(EncodableModel.test, forKey: .key1)
        try container.encodeIfPresent(nil as EncodableModel?, forKey: .key2)
        
        XCTAssertEqual(encoder.sqliteData.count, 2)
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key1.stringValue], .text(EncodableModel.test.rawValue))
        XCTAssertEqual(encoder.sqliteData[CodingKeys.key2.stringValue], .null)
    }
    
    func testNestedKeyedContainer() {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: [CodingKeys.key1]
            )
        )
        let nestedContainer = container.nestedContainer(
            keyedBy: CodingKeys.self, forKey: .key3
        )
        XCTAssertEqual(nestedContainer.codingPath as? [CodingKeys], [.key1, .key3])
    }
    
    func testNestedUnkeyedContainer() {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: [CodingKeys.key1]
            )
        )
        let nestedContainer = container.nestedUnkeyedContainer(forKey: .key3)
        XCTAssertTrue(nestedContainer is FailedEncodingContainer<RowCodingKey>)
        XCTAssertEqual(nestedContainer.codingPath as? [CodingKeys], [.key1, .key3])
    }
    
    func testSuperEncoder() {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: [CodingKeys.key1]
            )
        )
        let superEncoder = container.superEncoder()
        XCTAssertTrue(superEncoder is FailedEncoder)
        XCTAssertEqual(superEncoder.codingPath as? [CodingKeys], [.key1])
    }
    
    func testSuperEncoderForKey() {
        let encoder = MockSingleRowEncoder()
        var container = KeyedEncodingContainer(
            KeyedContainer<MockSingleRowEncoder, CodingKeys>(
                encoder: encoder, codingPath: [CodingKeys.key1]
            )
        )
        let superEncoder = container.superEncoder(forKey: .key3)
        XCTAssertTrue(superEncoder is FailedEncoder)
        XCTAssertEqual(superEncoder.codingPath as? [CodingKeys], [.key1, .key3])
    }
}

private extension KeyedContainerTests {
    enum CodingKeys: CodingKey {
        case key1
        case key2
        case key3
    }
    
    enum RawRepresentableModel: String, Encodable, SQLiteRawRepresentable {
        case test
    }
    
    enum EncodableModel: String, Encodable {
        case test
    }
    
    final class MockDateEncoder: DateEncoder {
        func encode(_ date: Date, to encoder: any ValueEncoder) throws {
            fatalError()
        }
        
        func encode(_ date: Date, for key: any CodingKey, to encoder: any RowEncoder) throws {
            let formatter = ISO8601DateFormatter()
            let dateString = formatter.string(from: date)
            try encoder.encode(dateString, for: key)
        }
    }
    
    final class MockSingleRowEncoder: RowEncoder {
        private(set) var sqliteData: SQLiteRow
        let dateEncoder: any DateEncoder
        let codingPath: [any CodingKey]
        let userInfo: [CodingUserInfoKey: Any]
        var count: Int { sqliteData.count }
        
        init(
            sqliteData: SQLiteRow = SQLiteRow(),
            dateEncoder: any DateEncoder = MockDateEncoder(),
            codingPath: [any CodingKey] = [],
            userInfo: [CodingUserInfoKey: Any] = [:]
        ) {
            self.sqliteData = sqliteData
            self.dateEncoder = dateEncoder
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
        
        func set(_ value: Any, for key: any CodingKey) throws {
            guard let value = value as? SQLiteRawValue else {
                fatalError()
            }
            sqliteData[key.stringValue] = value
        }
        
        func encodeNil(for key: any CodingKey) throws {
            sqliteData[key.stringValue] = .null
        }
        
        func encodeDate(_ date: Date, for key: any CodingKey) throws {
            try dateEncoder.encode(date, for: key, to: self)
        }
        
        func encode<T: SQLiteRawBindable>(_ value: T, for key: any CodingKey) throws {
            sqliteData[key.stringValue] = value.sqliteRawValue
        }
        
        func encoder(for key: any CodingKey) throws -> any Encoder {
            MockSingleValueEncoder()
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
            MockSingleValueContainer(encoder: self, codingPath: [])
        }
    }
    
    final class MockSingleValueContainer<Encoder: ValueEncoder>: Container, SingleValueEncodingContainer {
        let encoder: Encoder
        let codingPath: [any CodingKey]
        
        init(
            encoder: Encoder,
            codingPath: [any CodingKey]
        ) {
            self.encoder = encoder
            self.codingPath = codingPath
        }
        
        func encodeNil() throws {
            try encoder.encodeNil()
        }
        
        func encode<T: Encodable>(_ value: T) throws {
            switch value {
            case let value as Date:
                try encoder.encodeDate(value)
            case let value as SQLiteRawRepresentable:
                try encoder.encode(value)
            default:
                try value.encode(to: encoder)
            }
        }
    }
}
