import XCTest
import DataLiteCore

@testable import DLCDecoder

final class SingleRowDecoderTests: XCTestCase {
    func testCount() {
        var row = SQLiteRow()
        row["key1"] = .null
        row["key2"] = .int(1)
        row["key3"] = .text("")
        let decoder = decoder(sqliteData: row)
        XCTAssertEqual(decoder.count, row.count)
    }
    
    func testContains() {
        var row = SQLiteRow()
        row["key1"] = .int(123)
        let decoder = decoder(sqliteData: row)
        XCTAssertTrue(decoder.contains(DummyKey(stringValue: "key1")))
        XCTAssertFalse(decoder.contains(DummyKey(stringValue: "key2")))
    }
    
    func testDecodeNil() {
        var row = SQLiteRow()
        row["key1"] = .null
        row["key2"] = .int(0)
        let decoder = decoder(sqliteData: row)
        XCTAssertTrue(try decoder.decodeNil(for: DummyKey(stringValue: "key1")))
        XCTAssertFalse(try decoder.decodeNil(for: DummyKey(stringValue: "key2")))
    }
    
    func testDecodeNilKeyNotFound() {
        let path = [DummyKey(stringValue: "rootKey")]
        let decoder = decoder(sqliteData: SQLiteRow(), codingPath: path)
        XCTAssertThrowsError(
            try decoder.decodeNil(for: DummyKey(stringValue: "key"))
        ) { error in
            guard case let DecodingError.keyNotFound(key, context) = error else {
                return XCTFail("Expected DecodingError.keyNotFound, but got: \(error).")
            }
            XCTAssertEqual(key as? DummyKey, DummyKey(stringValue: "key"))
            XCTAssertEqual(context.codingPath as? [DummyKey], path + [DummyKey(stringValue: "key")])
            XCTAssertEqual(context.debugDescription, "No value associated with key \(DummyKey(stringValue: "key")).")
        }
    }
    
    func testDecodeDate() {
        let expected = Date()
        let dateDecoder = MockDateDecoder(expectedDate: expected)
        let decoder = decoder(dateDecoder: dateDecoder, sqliteData: SQLiteRow())
        
        XCTAssertEqual(try decoder.decodeDate(for: DummyKey(stringValue: "key")), expected)
        XCTAssertTrue(dateDecoder.didCallDecode)
    }
    
    func testDecodeKeyNotFound() {
        let path = [DummyKey(stringValue: "rootKey")]
        let testKey = DummyKey(stringValue: "testKey")
        let decoder = decoder(sqliteData: SQLiteRow(), codingPath: path)
        XCTAssertThrowsError(
            try decoder.decode(Int.self, for: testKey)
        ) { error in
            guard case let DecodingError.keyNotFound(key, context) = error else {
                return XCTFail("Expected DecodingError.keyNotFound, but got: \(error).")
            }
            XCTAssertEqual(key as? DummyKey, testKey)
            XCTAssertEqual(context.codingPath as? [DummyKey], path + [testKey])
            XCTAssertEqual(context.debugDescription, "No value associated with key \(testKey).")
        }
    }
    
    func testDecodeWithNullValue() {
        let path = [DummyKey(stringValue: "rootKey")]
        let testKey = DummyKey(stringValue: "testKey")
        var row = SQLiteRow()
        row[testKey.stringValue] = .null
        let decoder = decoder(sqliteData: row, codingPath: path)
        XCTAssertThrowsError(
            try decoder.decode(Int.self, for: testKey)
        ) { error in
            guard case let DecodingError.valueNotFound(type, context) = error else {
                return XCTFail("Expected DecodingError.valueNotFound, but got: \(error).")
            }
            XCTAssertTrue(type == Int.self)
            XCTAssertEqual(context.codingPath as? [DummyKey], path + [testKey])
            XCTAssertEqual(context.debugDescription, "Cannot get value of type Int, found null value instead.")
        }
    }
    
    func testDecodeWithTypeMismatch() {
        let path = [DummyKey(stringValue: "rootKey")]
        let testKey = DummyKey(stringValue: "testKey")
        var row = SQLiteRow()
        row[testKey.stringValue] = .int(0)
        let decoder = decoder(sqliteData: row, codingPath: path)
        XCTAssertThrowsError(
            try decoder.decode(Data.self, for: testKey)
        ) { error in
            guard case let DecodingError.typeMismatch(type, context) = error else {
                return XCTFail("Expected DecodingError.typeMismatch, but got: \(error).")
            }
            XCTAssertTrue(type == Data.self)
            XCTAssertEqual(context.codingPath as? [DummyKey], path + [testKey])
            XCTAssertEqual(context.debugDescription, "Expected to decode Data but found an \(SQLiteRawValue.int(0)) instead.")
        }
    }
    
    func testDecodeWithCorrectValue() {
        let testKey = DummyKey(stringValue: "testKey")
        var row = SQLiteRow()
        row[testKey.stringValue] = .text("test")
        let decoder = decoder(sqliteData: row)
        XCTAssertEqual(try decoder.decode(String.self, for: testKey), "test")
    }
    
    func testDecoderKeyNotFound() {
        let path = [DummyKey(stringValue: "rootKey")]
        let testKey = DummyKey(stringValue: "testKey")
        let decoder = decoder(sqliteData: SQLiteRow(), codingPath: path)
        
        XCTAssertThrowsError(
            try decoder.decoder(for: testKey)
        ) { error in
            guard case let DecodingError.keyNotFound(key, context) = error else {
                return XCTFail("Expected DecodingError.keyNotFound, but got: \(error).")
            }
            XCTAssertEqual(key as? DummyKey, testKey)
            XCTAssertEqual(context.codingPath as? [DummyKey], path + [testKey])
            XCTAssertEqual(context.debugDescription, "No value associated with key \(testKey).")
        }
    }
    
    func testDecoderWithValidData() throws {
        var row = SQLiteRow()
        let testKey = DummyKey(stringValue: "testKey")
        row[testKey.stringValue] = .int(42)
        
        let decoder = decoder(sqliteData: row)
        let valueDecoder = try decoder.decoder(for: testKey)
        
        guard let singleValueDecoder = valueDecoder as? SingleValueDecoder else {
            return XCTFail("Expected SingleValueDecoder, but got: \(type(of: valueDecoder)).")
        }
        
        XCTAssertEqual(singleValueDecoder.sqliteData, .int(42))
        XCTAssertEqual(singleValueDecoder.codingPath as? [DummyKey], [testKey])
    }
    
    func testKeyedContainer() throws {
        let path = [DummyKey(stringValue: "rootKey")]
        let expectedKeys = [
            DummyKey(stringValue: "key1"),
            DummyKey(stringValue: "key2"),
            DummyKey(stringValue: "key3")
        ]
        
        var row = SQLiteRow()
        row[expectedKeys[0].stringValue] = .int(123)
        row[expectedKeys[1].stringValue] = .text("str")
        row[expectedKeys[2].stringValue] = .null
        
        let decoder = decoder(sqliteData: row, codingPath: path)
        let container = try decoder.container(keyedBy: DummyKey.self)
        
        XCTAssertEqual(container.codingPath as? [DummyKey], decoder.codingPath as? [DummyKey])
        XCTAssertEqual(container.allKeys, expectedKeys)
    }
    
    func testUnkeyedContainer() throws {
        let path = [DummyKey(stringValue: "rootKey")]
        let decoder = decoder(sqliteData: SQLiteRow(), codingPath: path)
        
        let container = try decoder.unkeyedContainer()
        
        guard let unkeyed = container as? UnkeyedContainer<SingleRowDecoder> else {
            return XCTFail("Expected UnkeyedContainer, got: \(type(of: container))")
        }
        
        XCTAssertTrue(unkeyed.decoder === decoder)
        XCTAssertEqual(unkeyed.codingPath as? [DummyKey], path)
    }
    
    func testSingleValueContainer() {
        let path = [DummyKey(stringValue: "rootKey")]
        let decoder = decoder(sqliteData: SQLiteRow(), codingPath: path)
        
        XCTAssertThrowsError(
            try decoder.singleValueContainer()
        ) { error in
            guard case let DecodingError.typeMismatch(type, context) = error else {
                return XCTFail("Expected DecodingError.typeMismatch, but got: \(error).")
            }
            
            XCTAssertTrue(type == SingleValueDecodingContainer.self)
            XCTAssertEqual(context.codingPath as? [DummyKey], path)
            XCTAssertEqual(context.debugDescription, "Expected a single value container, but found a row value.")
        }
    }
}

private extension SingleRowDecoderTests {
    func decoder(
        dateDecoder: DateDecoder = MockDateDecoder(),
        sqliteData: SQLiteRow,
        codingPath: [any CodingKey] = []
    ) -> SingleRowDecoder {
        SingleRowDecoder(
            dateDecoder: dateDecoder,
            sqliteData: sqliteData,
            codingPath: codingPath,
            userInfo: [:]
        )
    }
}

private extension SingleRowDecoderTests {
    struct DummyKey: CodingKey, Equatable {
        var stringValue: String
        var intValue: Int?
        
        init(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        init(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
    
    final class MockDateDecoder: DateDecoder {
        let expectedDate: Date
        private(set) var didCallDecode = false
        
        init(expectedDate: Date = Date()) {
            self.expectedDate = expectedDate
        }
        
        func decode(
            from decoder: any ValueDecoder
        ) throws -> Date {
            fatalError()
        }
        
        func decode(
            from decoder: any RowDecoder,
            for key: any CodingKey
        ) throws -> Date {
            didCallDecode = true
            return expectedDate
        }
    }
}
