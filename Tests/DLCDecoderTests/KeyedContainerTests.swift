import XCTest
import DataLiteCore

@testable import DLCDecoder

final class KeyedContainerTests: XCTestCase {
    func testContains() {
        var row = SQLiteRow()
        row[CodingKeys.key1.stringValue] = .int(0)
        
        let container = KeyedContainer(
            decoder: MockKeyedDecoder(sqliteData: row),
            codingPath: [],
            allKeys: [CodingKeys.key1]
        )
        
        XCTAssertTrue(container.contains(.key1))
        XCTAssertFalse(container.contains(.key2))
    }
    
    func testDecodeNil() {
        var row = SQLiteRow()
        row[CodingKeys.key1.stringValue] = .int(0)
        row[CodingKeys.key2.stringValue] = .null
        
        let container = KeyedContainer(
            decoder: MockKeyedDecoder(sqliteData: row),
            codingPath: [],
            allKeys: [CodingKeys.key1, .key2]
        )
        
        XCTAssertFalse(try container.decodeNil(forKey: .key1))
        XCTAssertTrue(try container.decodeNil(forKey: .key2))
    }
    
    func testDecodeBool() {
        var row = SQLiteRow()
        row[CodingKeys.key1.stringValue] = .int(0)
        row[CodingKeys.key2.stringValue] = .int(1)
        
        let container = KeyedContainer(
            decoder: MockKeyedDecoder(sqliteData: row),
            codingPath: [],
            allKeys: [CodingKeys.key1, .key2]
        )
        
        XCTAssertFalse(try container.decode(Bool.self, forKey: .key1))
        XCTAssertTrue(try container.decode(Bool.self, forKey: .key2))
        XCTAssertNil(try container.decodeIfPresent(Bool.self, forKey: .key3))
    }
    
    func testDecodeString() {
        let string = "Test string"
        var row = SQLiteRow()
        row[CodingKeys.key1.stringValue] = .text(string)
        
        let container = KeyedContainer(
            decoder: MockKeyedDecoder(sqliteData: row),
            codingPath: [],
            allKeys: [CodingKeys.key1]
        )
        
        XCTAssertEqual(try container.decode(String.self, forKey: .key1), string)
        XCTAssertNil(try container.decodeIfPresent(String.self, forKey: .key2))
    }
    
    func testDecodeRealNumber() {
        var row = SQLiteRow()
        row[CodingKeys.key1.stringValue] = .real(3.14)
        row[CodingKeys.key2.stringValue] = .real(2.55)
        
        let container = KeyedContainer(
            decoder: MockKeyedDecoder(sqliteData: row),
            codingPath: [],
            allKeys: [CodingKeys.key1, .key2]
        )
        
        XCTAssertEqual(try container.decode(Double.self, forKey: .key1), 3.14)
        XCTAssertEqual(try container.decode(Float.self, forKey: .key2), 2.55)
        XCTAssertNil(try container.decodeIfPresent(Double.self, forKey: .key3))
        XCTAssertNil(try container.decodeIfPresent(Float.self, forKey: .key3))
    }
    
    func testDecodeIntNumber() {
        var row = SQLiteRow()
        row[CodingKeys.key1.stringValue] = .int(42)
        
        let container = KeyedContainer(
            decoder: MockKeyedDecoder(sqliteData: row),
            codingPath: [],
            allKeys: [CodingKeys.key1]
        )
        
        XCTAssertEqual(try container.decode(Int.self, forKey: .key1), 42)
        XCTAssertEqual(try container.decode(Int8.self, forKey: .key1), 42)
        XCTAssertEqual(try container.decode(Int16.self, forKey: .key1), 42)
        XCTAssertEqual(try container.decode(Int32.self, forKey: .key1), 42)
        XCTAssertEqual(try container.decode(Int64.self, forKey: .key1), 42)
        XCTAssertEqual(try container.decode(UInt.self, forKey: .key1), 42)
        XCTAssertEqual(try container.decode(UInt8.self, forKey: .key1), 42)
        XCTAssertEqual(try container.decode(UInt16.self, forKey: .key1), 42)
        XCTAssertEqual(try container.decode(UInt32.self, forKey: .key1), 42)
        XCTAssertEqual(try container.decode(UInt64.self, forKey: .key1), 42)
        XCTAssertNil(try container.decodeIfPresent(Int.self, forKey: .key2))
    }
    
    func testDecodeDate() {
        let date = Date(timeIntervalSince1970: 123456789)
        var row = SQLiteRow()
        row[CodingKeys.key1.stringValue] = .real(date.timeIntervalSince1970)
        
        let container = KeyedContainer(
            decoder: MockKeyedDecoder(sqliteData: row),
            codingPath: [],
            allKeys: [CodingKeys.key1]
        )
        
        XCTAssertEqual(try container.decode(Date.self, forKey: .key1), date)
        XCTAssertNil(try container.decodeIfPresent(Date.self, forKey: .key2))
    }
    
    func testDecodeRawRepresentable() {
        let `case` = RawRepresentableEnum.test
        var row = SQLiteRow()
        row[CodingKeys.key1.stringValue] = .text(`case`.rawValue)
        
        let container = KeyedContainer(
            decoder: MockKeyedDecoder(sqliteData: row),
            codingPath: [],
            allKeys: [CodingKeys.key1]
        )
        
        XCTAssertEqual(try container.decode(RawRepresentableEnum.self, forKey: .key1), `case`)
        XCTAssertNil(try container.decodeIfPresent(RawRepresentableEnum.self, forKey: .key2))
    }
    
    func testDecodeDecodable() {
        let `case` = DecodableEnum.test
        var row = SQLiteRow()
        row[CodingKeys.key1.stringValue] = .text(`case`.rawValue)
        
        let container = KeyedContainer(
            decoder: MockKeyedDecoder(sqliteData: row),
            codingPath: [],
            allKeys: [CodingKeys.key1]
        )
        
        XCTAssertEqual(try container.decode(DecodableEnum.self, forKey: .key1), `case`)
        XCTAssertNil(try container.decodeIfPresent(DecodableEnum.self, forKey: .key2))
    }
    
    func testNestedContainerKeyedBy() {
        let container = KeyedContainer(
            decoder: MockKeyedDecoder(sqliteData: .init()),
            codingPath: [CodingKeys.key1],
            allKeys: [CodingKeys]()
        )
        
        XCTAssertThrowsError(
            try container.nestedContainer(
                keyedBy: CodingKeys.self,
                forKey: .key2
            )
        ) { error in
            guard case let DecodingError.typeMismatch(type, context) = error else {
                XCTFail("Expected DecodingError.typeMismatch, but got: \(error).")
                return
            }
            XCTAssertTrue(
                type == KeyedDecodingContainer<CodingKeys>.self,
                "Mismatched type in decoding error. Expected \(KeyedDecodingContainer<CodingKeys>.self)."
            )
            XCTAssertEqual(
                context.codingPath as? [CodingKeys], [.key1, .key2],
                "Incorrect coding path in decoding error."
            )
            XCTAssertEqual(
                context.debugDescription,
                """
                Attempted to decode a nested keyed container for key '\(CodingKeys.key2.stringValue)',
                but the value cannot be represented as a keyed container.
                """,
                "Unexpected debug description in decoding error."
            )
        }
    }
    
    func testNestedUnkeyedContainer() {
        let container = KeyedContainer(
            decoder: MockKeyedDecoder(sqliteData: .init()),
            codingPath: [CodingKeys.key1],
            allKeys: [CodingKeys]()
        )
        
        XCTAssertThrowsError(
            try container.nestedUnkeyedContainer(forKey: .key2)
        ) { error in
            guard case let DecodingError.typeMismatch(type, context) = error else {
                XCTFail("Expected DecodingError.typeMismatch, but got: \(error).")
                return
            }
            XCTAssertTrue(
                type == UnkeyedDecodingContainer.self,
                "Mismatched type in decoding error. Expected \(UnkeyedDecodingContainer.self)."
            )
            XCTAssertEqual(
                context.codingPath as? [CodingKeys], [.key1, .key2],
                "Incorrect coding path in decoding error."
            )
            XCTAssertEqual(
                context.debugDescription,
                """
                Attempted to decode a nested unkeyed container for key '\(CodingKeys.key2.stringValue)',
                but the value cannot be represented as an unkeyed container.
                """,
                "Unexpected debug description in decoding error."
            )
        }
    }
    
    func testSuperDecoder() {
        let container = KeyedContainer(
            decoder: MockKeyedDecoder(sqliteData: .init()),
            codingPath: [CodingKeys.key1],
            allKeys: [CodingKeys]()
        )
        
        XCTAssertThrowsError(
            try container.superDecoder()
        ) { error in
            guard case let DecodingError.typeMismatch(type, context) = error else {
                XCTFail("Expected DecodingError.typeMismatch, but got: \(error).")
                return
            }
            XCTAssertTrue(
                type == Swift.Decoder.self,
                "Mismatched type in decoding error. Expected \(Swift.Decoder.self)."
            )
            XCTAssertEqual(
                context.codingPath as? [CodingKeys], [.key1],
                "Incorrect coding path in decoding error."
            )
            XCTAssertEqual(
                context.debugDescription,
                """
                Attempted to get a superDecoder,
                but SQLiteRowDecoder does not support superDecoding.
                """,
                "Unexpected debug description in decoding error."
            )
        }
    }
    
    func testSuperDecoderForKey() {
        let container = KeyedContainer(
            decoder: MockKeyedDecoder(sqliteData: .init()),
            codingPath: [CodingKeys.key1],
            allKeys: [CodingKeys]()
        )
        
        XCTAssertThrowsError(
            try container.superDecoder(forKey: .key2)
        ) { error in
            guard case let DecodingError.typeMismatch(type, context) = error else {
                XCTFail("Expected DecodingError.typeMismatch, but got: \(error).")
                return
            }
            XCTAssertTrue(
                type == Swift.Decoder.self,
                "Unexpected type in decoding error. Expected \(Swift.Decoder.self)."
            )
            XCTAssertEqual(
                context.codingPath as? [CodingKeys], [.key1, .key2],
                "Incorrect coding path in decoding error."
            )
            XCTAssertEqual(
                context.debugDescription,
                """
                Attempted to get a superDecoder for key '\(CodingKeys.key2.stringValue)',
                but SQLiteRowDecoder does not support nested structures.
                """,
                "Unexpected debug description in decoding error."
            )
        }
    }
}

private extension KeyedContainerTests {
    enum CodingKeys: CodingKey {
        case key1
        case key2
        case key3
    }
    
    enum RawRepresentableEnum: String, Decodable, SQLiteRawRepresentable {
        case test
    }
    
    enum DecodableEnum: String, Decodable {
        case test
    }
    
    final class MockDateDecoder: DateDecoder {
        func decode(
            from decoder: any ValueDecoder
        ) throws -> Date {
            fatalError()
        }
        
        func decode(
            from decoder: any RowDecoder,
            for key: any CodingKey
        ) throws -> Date {
            try decoder.decode(Date.self, for: key)
        }
    }
    
    final class MockKeyedDecoder: RowDecoder, KeyCheckingDecoder {
        typealias SQLiteData = SQLiteRow
        
        let sqliteData: SQLiteData
        let dateDecoder: DateDecoder
        let codingPath: [any CodingKey]
        let userInfo: [CodingUserInfoKey: Any]
        
        var count: Int? { sqliteData.count }
        
        init(
            sqliteData: SQLiteData,
            dateDecoder: DateDecoder = MockDateDecoder(),
            codingPath: [any CodingKey] = [],
            userInfo: [CodingUserInfoKey: Any] = [:]
        ) {
            self.sqliteData = sqliteData
            self.dateDecoder = dateDecoder
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
        
        func contains(_ key: any CodingKey) -> Bool {
            sqliteData.contains(key.stringValue)
        }
        
        func decodeNil(
            for key: any CodingKey
        ) throws -> Bool {
            sqliteData[key.stringValue] == .null
        }
        
        func decodeDate(for key: any CodingKey) throws -> Date {
            try dateDecoder.decode(from: self, for: key)
        }
        
        func decode<T: SQLiteRawRepresentable>(
            _ type: T.Type,
            for key: any CodingKey
        ) throws -> T {
            type.init(sqliteData[key.stringValue]!)!
        }
        
        func decoder(for key: any CodingKey) -> any Decoder {
            MockValueDecoder(sqliteData: sqliteData[key.stringValue]!)
        }
        
        func container<Key: CodingKey>(
            keyedBy type: Key.Type
        ) throws -> KeyedDecodingContainer<Key> {
            fatalError()
        }
        
        func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
            fatalError()
        }
        
        func singleValueContainer() throws -> any SingleValueDecodingContainer {
            fatalError()
        }
    }
    
    final class MockValueDecoder: ValueDecoder, SingleValueDecodingContainer {
        typealias SQLiteData = SQLiteRawValue
        
        let sqliteData: SQLiteData
        var dateDecoder: DateDecoder
        var codingPath: [any CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        
        init(
            sqliteData: SQLiteData,
            dateDecoder: DateDecoder = MockDateDecoder(),
            codingPath: [any CodingKey] = [],
            userInfo: [CodingUserInfoKey: Any] = [:]
        ) {
            self.sqliteData = sqliteData
            self.dateDecoder = dateDecoder
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
        
        func decodeNil() -> Bool {
            fatalError()
        }
        
        func decodeDate() throws -> Date {
            fatalError()
        }
        
        func decode<T: SQLiteRawRepresentable>(
            _ type: T.Type
        ) throws -> T {
            fatalError()
        }
        
        func container<Key: CodingKey>(
            keyedBy type: Key.Type
        ) throws -> KeyedDecodingContainer<Key> {
            fatalError()
        }
        
        func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
            fatalError()
        }
        
        func singleValueContainer() throws -> any SingleValueDecodingContainer {
            self
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            fatalError()
        }
        
        func decode(_ type: String.Type) throws -> String {
            type.init(sqliteData)!
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            fatalError()
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            fatalError()
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            fatalError()
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            fatalError()
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            fatalError()
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            fatalError()
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            fatalError()
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            fatalError()
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            fatalError()
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            fatalError()
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            fatalError()
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            fatalError()
        }
        
        func decode<T: Decodable>(_ type: T.Type) throws -> T {
            fatalError()
        }
    }
}
