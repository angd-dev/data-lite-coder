import XCTest
import DataLiteCore

@testable import DLCDecoder

final class SingleValueContainerTests: XCTestCase {
    func testDecodeNil() {
        let nullContainer = SingleValueContainer(
            decoder: MockSingleValueDecoder(sqliteData: .null),
            codingPath: []
        )
        XCTAssertTrue(
            nullContainer.decodeNil(),
            "Expected decodeNil to return true for null value."
        )
        
        let nonNullContainer = SingleValueContainer(
            decoder: MockSingleValueDecoder(sqliteData: .int(42)),
            codingPath: []
        )
        XCTAssertFalse(
            nonNullContainer.decodeNil(),
            "Expected decodeNil to return false for non-null value."
        )
    }
    
    func testDecodeBool() {
        let container = SingleValueContainer(
            decoder: MockSingleValueDecoder(sqliteData: .int(1)),
            codingPath: []
        )
        XCTAssertTrue(
            try container.decode(Bool.self),
            "Expected decoded Bool to be true."
        )
    }
    
    func testDecodeString() {
        let container = SingleValueContainer(
            decoder: MockSingleValueDecoder(sqliteData: .text("Hello")),
            codingPath: []
        )
        XCTAssertEqual(
            try container.decode(String.self), "Hello",
            "Decoded String does not match expected value."
        )
    }
    
    func testDecodeDouble() {
        let container = SingleValueContainer(
            decoder: MockSingleValueDecoder(sqliteData: .real(3.14)),
            codingPath: []
        )
        XCTAssertEqual(
            try container.decode(Double.self), 3.14,
            "Decoded Double does not match expected value."
        )
    }
    
    func testDecodeFloat() {
        let container = SingleValueContainer(
            decoder: MockSingleValueDecoder(sqliteData: .real(2.5)),
            codingPath: []
        )
        XCTAssertEqual(
            try container.decode(Float.self), 2.5,
            "Decoded Float does not match expected value."
        )
    }
    
    func testDecodeInt() {
        let container = SingleValueContainer(
            decoder: MockSingleValueDecoder(sqliteData: .int(42)),
            codingPath: []
        )
        XCTAssertEqual(
            try container.decode(Int.self), 42,
            "Decoded Int does not match expected value."
        )
        XCTAssertEqual(
            try container.decode(Int8.self), 42,
            "Decoded Int8 does not match expected value."
        )
        XCTAssertEqual(
            try container.decode(Int16.self), 42,
            "Decoded Int16 does not match expected value."
        )
        XCTAssertEqual(
            try container.decode(Int32.self), 42,
            "Decoded Int32 does not match expected value."
        )
        XCTAssertEqual(
            try container.decode(Int64.self), 42,
            "Decoded Int64 does not match expected value."
        )
        XCTAssertEqual(
            try container.decode(UInt.self), 42,
            "Decoded UInt does not match expected value."
        )
        XCTAssertEqual(
            try container.decode(UInt8.self), 42,
            "Decoded UInt8 does not match expected value."
        )
        XCTAssertEqual(
            try container.decode(UInt16.self), 42,
            "Decoded UInt16 does not match expected value."
        )
        XCTAssertEqual(
            try container.decode(UInt32.self), 42,
            "Decoded UInt32 does not match expected value."
        )
        XCTAssertEqual(
            try container.decode(UInt64.self), 42,
            "Decoded UInt64 does not match expected value."
        )
    }
    
    func testDecodeDate() {
        let date = Date(timeIntervalSince1970: 123456789)
        let container = SingleValueContainer(
            decoder: MockSingleValueDecoder(sqliteData: .real(date.timeIntervalSince1970)),
            codingPath: []
        )
        XCTAssertEqual(
            try container.decode(Date.self), date,
            "Decoded Date does not match expected value."
        )
    }
    
    func testDecodeRawRepresentable() {
        let `case` = RawRepresentableEnum.test
        let container = SingleValueContainer(
            decoder: MockSingleValueDecoder(sqliteData: .text(`case`.rawValue)),
            codingPath: []
        )
        XCTAssertEqual(
            try container.decode(RawRepresentableEnum.self), `case`,
            "Decoded RawRepresentableEnum does not match expected value."
        )
    }
    
    func testDecodeDecodable() {
        let `case` = DecodableEnum.test
        let container = SingleValueContainer(
            decoder: MockSingleValueDecoder(sqliteData: .text(`case`.rawValue)),
            codingPath: []
        )
        XCTAssertEqual(
            try container.decode(DecodableEnum.self), `case`,
            "Decoded DecodableEnum does not match expected value."
        )
    }
}

private extension SingleValueContainerTests {
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
            try decoder.decode(Date.self)
        }
        
        func decode(
            from decoder: any RowDecoder,
            for key: any CodingKey
        ) throws -> Date {
            fatalError()
        }
    }
    
    final class MockSingleValueDecoder: ValueDecoder, SingleValueDecodingContainer {
        let sqliteData: SQLiteRawValue
        let dateDecoder: DateDecoder
        let codingPath: [any CodingKey]
        let userInfo: [CodingUserInfoKey: Any]
        
        init(
            sqliteData: SQLiteRawValue,
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
            sqliteData == .null
        }
        
        func decodeDate() throws -> Date {
            try dateDecoder.decode(from: self)
        }
        
        func decode<T: SQLiteRawRepresentable>(
            _ type: T.Type
        ) throws -> T {
            type.init(sqliteData)!
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
            String(sqliteData)!
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
