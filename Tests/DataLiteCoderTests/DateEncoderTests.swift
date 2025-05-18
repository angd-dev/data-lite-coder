import XCTest
import DataLiteCore
import DLCEncoder
import DLCCommon

@testable import DataLiteCoder

final class DateEncoderTests: XCTestCase {
    func testDeferredToDate() throws {
        let date = Date(timeIntervalSince1970: 1234567890)
        
        let dateEncoder = RowEncoder.DateEncoder(strategy: .deferredToDate)
        let singleEncoder = SingleValueEncoder(dateEncoder: dateEncoder)
        let keyedEncoder = KeyedEncoder(dateEncoder: dateEncoder)
        let key = RowCodingKey(stringValue: "key1")
        
        try dateEncoder.encode(date, to: singleEncoder)
        try dateEncoder.encode(date, for: key, to: keyedEncoder)
        
        XCTAssertEqual(singleEncoder.sqliteData, date.sqliteRawValue)
        XCTAssertEqual(keyedEncoder.sqliteData[key], date.sqliteRawValue)
    }
    
    func testISO8601() throws {
        let formatter = ISO8601DateFormatter()
        let string = "2024-04-18T13:45:00Z"
        let date = formatter.date(from: string)!
        
        let dateEncoder = RowEncoder.DateEncoder(strategy: .iso8601)
        let singleEncoder = SingleValueEncoder(dateEncoder: dateEncoder)
        let keyedEncoder = KeyedEncoder(dateEncoder: dateEncoder)
        let key = RowCodingKey(stringValue: "key1")
        
        try dateEncoder.encode(date, to: singleEncoder)
        try dateEncoder.encode(date, for: key, to: keyedEncoder)
        
        XCTAssertEqual(singleEncoder.sqliteData, .text(string))
        XCTAssertEqual(keyedEncoder.sqliteData[key], .text(string))
    }
    
    func testFormatted() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let string = "2023-10-15 16:30:00"
        let date = formatter.date(from: string)!
        
        let dateEncoder = RowEncoder.DateEncoder(strategy: .formatted(formatter))
        let singleEncoder = SingleValueEncoder(dateEncoder: dateEncoder)
        let keyedEncoder = KeyedEncoder(dateEncoder: dateEncoder)
        let key = RowCodingKey(stringValue: "key1")
        
        try dateEncoder.encode(date, to: singleEncoder)
        try dateEncoder.encode(date, for: key, to: keyedEncoder)
        
        XCTAssertEqual(singleEncoder.sqliteData, .text(string))
        XCTAssertEqual(keyedEncoder.sqliteData[key], .text(string))
    }
    
    func testMillisecondsSince1970Int() throws {
        let millis: Int64 = 1_600_000_000_000
        let date = Date(timeIntervalSince1970: Double(millis) / 1000)
        
        let dateEncoder = RowEncoder.DateEncoder(strategy: .millisecondsSince1970Int)
        let singleEncoder = SingleValueEncoder(dateEncoder: dateEncoder)
        let keyedEncoder = KeyedEncoder(dateEncoder: dateEncoder)
        let key = RowCodingKey(stringValue: "key1")
        
        try dateEncoder.encode(date, to: singleEncoder)
        try dateEncoder.encode(date, for: key, to: keyedEncoder)
        
        XCTAssertEqual(singleEncoder.sqliteData, .int(millis))
        XCTAssertEqual(keyedEncoder.sqliteData[key], .int(millis))
    }
    
    func testMillisecondsSince1970Double() throws {
        let millis: Double = 1_600_000_000_000
        let date = Date(timeIntervalSince1970: millis / 1000)
        
        let dateEncoder = RowEncoder.DateEncoder(strategy: .millisecondsSince1970Double)
        let singleEncoder = SingleValueEncoder(dateEncoder: dateEncoder)
        let keyedEncoder = KeyedEncoder(dateEncoder: dateEncoder)
        let key = RowCodingKey(stringValue: "key1")
        
        try dateEncoder.encode(date, to: singleEncoder)
        try dateEncoder.encode(date, for: key, to: keyedEncoder)
        
        XCTAssertEqual(singleEncoder.sqliteData, .real(millis))
        XCTAssertEqual(keyedEncoder.sqliteData[key], .real(millis))
    }
    
    func testSecondsSince1970Int() throws {
        let seconds: Int64 = 1_600_000_000
        let date = Date(timeIntervalSince1970: Double(seconds))
        
        let dateEncoder = RowEncoder.DateEncoder(strategy: .secondsSince1970Int)
        let singleEncoder = SingleValueEncoder(dateEncoder: dateEncoder)
        let keyedEncoder = KeyedEncoder(dateEncoder: dateEncoder)
        let key = RowCodingKey(stringValue: "key1")
        
        try dateEncoder.encode(date, to: singleEncoder)
        try dateEncoder.encode(date, for: key, to: keyedEncoder)
        
        XCTAssertEqual(singleEncoder.sqliteData, .int(seconds))
        XCTAssertEqual(keyedEncoder.sqliteData[key], .int(seconds))
    }
    
    func testSecondsSince1970Double() throws {
        let seconds: Double = 1_600_000_000
        let date = Date(timeIntervalSince1970: seconds)
        
        let dateEncoder = RowEncoder.DateEncoder(strategy: .secondsSince1970Double)
        let singleEncoder = SingleValueEncoder(dateEncoder: dateEncoder)
        let keyedEncoder = KeyedEncoder(dateEncoder: dateEncoder)
        let key = RowCodingKey(stringValue: "key1")
        
        try dateEncoder.encode(date, to: singleEncoder)
        try dateEncoder.encode(date, for: key, to: keyedEncoder)
        
        XCTAssertEqual(singleEncoder.sqliteData, .real(seconds))
        XCTAssertEqual(keyedEncoder.sqliteData[key], .real(seconds))
    }
}

private extension DateEncoderTests {
    final class SingleValueEncoder: DLCEncoder.ValueEncoder {
        let dateEncoder: any DateEncoder
        let codingPath: [any CodingKey]
        let userInfo: [CodingUserInfoKey : Any]
        
        private(set) var sqliteData: SQLiteRawValue?
        
        init(
            dateEncoder: any DateEncoder,
            codingPath: [any CodingKey] = [],
            userInfo: [CodingUserInfoKey : Any] = [:]
        ) {
            self.dateEncoder = dateEncoder
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
        
        func encodeNil() throws {
            fatalError()
        }
        
        func encodeDate(_ date: Date) throws {
            fatalError()
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
            fatalError()
        }
    }
    
    final class KeyedEncoder: DLCEncoder.RowEncoder {
        let dateEncoder: any DateEncoder
        let codingPath: [any CodingKey]
        let userInfo: [CodingUserInfoKey : Any]
        
        private(set) var sqliteData = SQLiteRow()
        
        var count: Int { fatalError() }
        
        init(
            dateEncoder: any DateEncoder,
            codingPath: [any CodingKey] = [],
            userInfo: [CodingUserInfoKey : Any] = [:]
        ) {
            self.dateEncoder = dateEncoder
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
        
        func set(_ value: Any, for key: any CodingKey) throws {
            fatalError()
        }
        
        func encodeNil(for key: any CodingKey) throws {
            fatalError()
        }
        
        func encodeDate(_ date: Date, for key: any CodingKey) throws {
            fatalError()
        }
        
        func encode<T: SQLiteRawBindable>(_ value: T, for key: any CodingKey) throws {
            sqliteData[key] = value.sqliteRawValue
        }
        
        func encoder(for key: any CodingKey) throws -> any Encoder {
            fatalError()
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
}
