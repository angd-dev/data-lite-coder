import XCTest
import DataLiteCore
import DLCDecoder

@testable import DataLiteCoder

final class DateDecoderTests: XCTestCase {
    func testDeferredToDate() {
        let date = Date(timeIntervalSince1970: 123456789)
        let dateDecoder = RowDecoder.DateDecoder(strategy: .deferredToDate)
        
        let singleDecoder = SingleValueDecoder(
            sqliteData: .real(date.timeIntervalSince1970)
        )
        
        XCTAssertEqual(try dateDecoder.decode(from: singleDecoder), date)
        
        var row = SQLiteRow()
        row[CodingKeys.key.stringValue] = .real(date.timeIntervalSince1970)
        let keyedDecoder = KeyedDecoder(sqliteData: row)
        
        XCTAssertEqual(try dateDecoder.decode(from: keyedDecoder, for: CodingKeys.key), date)
    }
    
    func testISO8601() throws {
        let dateDecoder = RowDecoder.DateDecoder(strategy: .iso8601)
        let formatter = ISO8601DateFormatter()
        let string = "2024-04-18T13:45:00Z"
        let date = formatter.date(from: string)!
        
        let single = SingleValueDecoder(sqliteData: .text(string))
        XCTAssertEqual(try dateDecoder.decode(from: single), date)
        
        var row = SQLiteRow()
        row[CodingKeys.key.stringValue] = .text(string)
        let keyed = KeyedDecoder(sqliteData: row)
        XCTAssertEqual(try dateDecoder.decode(from: keyed, for: CodingKeys.key), date)
    }
    
    func testFormatted() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let string = "2023-10-15 16:30:00"
        let date = formatter.date(from: string)!
        
        let dateDecoder = RowDecoder.DateDecoder(strategy: .formatted(formatter))
        
        let single = SingleValueDecoder(sqliteData: .text(string))
        XCTAssertEqual(try dateDecoder.decode(from: single), date)
        
        var row = SQLiteRow()
        row[CodingKeys.key.stringValue] = .text(string)
        let keyed = KeyedDecoder(sqliteData: row)
        XCTAssertEqual(try dateDecoder.decode(from: keyed, for: CodingKeys.key), date)
    }
    
    func testFormattedInvalidDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let invalidString = "not a date"
        
        let dateDecoder = RowDecoder.DateDecoder(strategy: .formatted(formatter))
        
        let single = SingleValueDecoder(sqliteData: .text(invalidString))
        XCTAssertThrowsError(try dateDecoder.decode(from: single))
        
        var row = SQLiteRow()
        row[CodingKeys.key.stringValue] = .text(invalidString)
        let keyed = KeyedDecoder(sqliteData: row)
        XCTAssertThrowsError(try dateDecoder.decode(from: keyed, for: CodingKeys.key))
    }
    
    func testMillisecondsSince1970Int() throws {
        let millis: Int64 = 1_600_000_000_000
        let date = Date(timeIntervalSince1970: Double(millis) / 1000)
        
        let dateDecoder = RowDecoder.DateDecoder(strategy: .millisecondsSince1970Int)
        
        let single = SingleValueDecoder(sqliteData: .int(millis))
        XCTAssertEqual(try dateDecoder.decode(from: single), date)
        
        var row = SQLiteRow()
        row[CodingKeys.key.stringValue] = .int(millis)
        let keyed = KeyedDecoder(sqliteData: row)
        XCTAssertEqual(try dateDecoder.decode(from: keyed, for: CodingKeys.key), date)
    }
    
    func testMillisecondsSince1970Double() throws {
        let millis: Double = 1_600_000_000_000.0
        let date = Date(timeIntervalSince1970: millis / 1000)
        
        let dateDecoder = RowDecoder.DateDecoder(strategy: .millisecondsSince1970Double)
        
        let single = SingleValueDecoder(sqliteData: .real(millis))
        XCTAssertEqual(try dateDecoder.decode(from: single), date)
        
        var row = SQLiteRow()
        row[CodingKeys.key.stringValue] = .real(millis)
        let keyed = KeyedDecoder(sqliteData: row)
        XCTAssertEqual(try dateDecoder.decode(from: keyed, for: CodingKeys.key), date)
    }
    
    func testSecondsSince1970Int() throws {
        let seconds: Int64 = 1_600_000_000
        let date = Date(timeIntervalSince1970: Double(seconds))
        
        let dateDecoder = RowDecoder.DateDecoder(strategy: .secondsSince1970Int)
        
        let single = SingleValueDecoder(sqliteData: .int(seconds))
        XCTAssertEqual(try dateDecoder.decode(from: single), date)
        
        var row = SQLiteRow()
        row[CodingKeys.key.stringValue] = .int(seconds)
        let keyed = KeyedDecoder(sqliteData: row)
        XCTAssertEqual(try dateDecoder.decode(from: keyed, for: CodingKeys.key), date)
    }
    
    func testSecondsSince1970Double() throws {
        let seconds: Double = 1_600_000_000.789
        let date = Date(timeIntervalSince1970: seconds)
        
        let dateDecoder = RowDecoder.DateDecoder(strategy: .secondsSince1970Double)
        
        let single = SingleValueDecoder(sqliteData: .real(seconds))
        XCTAssertEqual(try dateDecoder.decode(from: single), date)
        
        var row = SQLiteRow()
        row[CodingKeys.key.stringValue] = .real(seconds)
        let keyed = KeyedDecoder(sqliteData: row)
        XCTAssertEqual(try dateDecoder.decode(from: keyed, for: CodingKeys.key), date)
    }
}

private extension DateDecoderTests {
    enum CodingKeys: CodingKey {
        case key
    }
    
    final class SingleValueDecoder: DLCDecoder.ValueDecoder {
        let sqliteData: SQLiteRawValue
        let dateDecoder: DLCDecoder.DateDecoder
        let codingPath: [any CodingKey]
        let userInfo: [CodingUserInfoKey: Any]
        
        init(
            sqliteData: SQLiteRawValue,
            dateDecoder: DLCDecoder.DateDecoder = RowDecoder.DateDecoder(strategy: .deferredToDate),
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
        
        func decode<T: SQLiteRawRepresentable>(_ type: T.Type) throws -> T {
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
            fatalError()
        }
    }
    
    final class KeyedDecoder: DLCDecoder.RowDecoder {
        let sqliteData: SQLiteRow
        let dateDecoder: DLCDecoder.DateDecoder
        let codingPath: [any CodingKey]
        let userInfo: [CodingUserInfoKey: Any]
        
        var count: Int? { sqliteData.count }
        
        init(
            sqliteData: SQLiteRow,
            dateDecoder: DLCDecoder.DateDecoder = RowDecoder.DateDecoder(strategy: .deferredToDate),
            codingPath: [any CodingKey] = [],
            userInfo: [CodingUserInfoKey: Any] = [:]
        ) {
            self.sqliteData = sqliteData
            self.dateDecoder = dateDecoder
            self.codingPath = codingPath
            self.userInfo = userInfo
        }
        
        func contains(_ key: any CodingKey) -> Bool {
            fatalError()
        }
        
        func decodeNil(for key: any CodingKey) throws -> Bool {
            fatalError()
        }
        
        func decodeDate(for key: any CodingKey) throws -> Date {
            fatalError()
        }
        
        func decode<T: SQLiteRawRepresentable>(
            _ type: T.Type,
            for key: any CodingKey
        ) throws -> T {
            type.init(sqliteData[key.stringValue]!)!
        }
        
        func decoder(for key: any CodingKey) -> any Decoder {
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
            fatalError()
        }
    }
}
