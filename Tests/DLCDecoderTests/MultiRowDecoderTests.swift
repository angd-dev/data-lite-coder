import XCTest
import DataLiteCore

@testable import DLCDecoder

final class MultiRowDecoderTests: XCTestCase {
    func testCount() {
        let rows = [SQLiteRow](repeating: .init(), count: 5)
        let decoder = decoder(sqliteData: rows)
        XCTAssertEqual(decoder.count, rows.count)
    }
    
    func testDecodeNil() {
        let path = [DummyKey(stringValue: "rootKey")]
        let testKey = DummyKey(intValue: 0)
        let decoder = decoder(sqliteData: [], codingPath: path)
        
        XCTAssertThrowsError(
            try decoder.decodeNil(for: testKey)
        ) { error in
            guard case let DecodingError.dataCorrupted(context) = error else {
                return XCTFail("Expected DecodingError.dataCorrupted, but got: \(error).")
            }
            
            XCTAssertEqual(context.codingPath as? [DummyKey], path + [testKey])
            XCTAssertEqual(context.debugDescription, "Attempted to decode nil, but it's not supported for an array of rows.")
        }
    }
    
    func testDecodeDate() {
        let path = [DummyKey(stringValue: "root")]
        let key = DummyKey(stringValue: "date")
        let decoder = decoder(sqliteData: [], codingPath: path)
        
        XCTAssertThrowsError(
            try decoder.decodeDate(for: key)
        ) { error in
            guard case let DecodingError.typeMismatch(type, context) = error else {
                return XCTFail("Expected DecodingError.typeMismatch, but got: \(error)")
            }
            
            XCTAssert(type == Date.self)
            XCTAssertEqual(context.codingPath as? [DummyKey], path + [key])
            XCTAssertEqual(context.debugDescription, "Expected a type of \(Date.self), but found an array of rows.")
        }
    }
    
    func testDecodeForKey() {
        let path = [DummyKey(stringValue: "user")]
        let key = DummyKey(stringValue: "id")
        let decoder = decoder(sqliteData: [], codingPath: path)
        
        XCTAssertThrowsError(
            try decoder.decode(String.self, for: key)
        ) { error in
            guard case let DecodingError.typeMismatch(type, context) = error else {
                return XCTFail("Expected DecodingError.typeMismatch, but got: \(error)")
            }
            
            XCTAssertTrue(type == String.self)
            XCTAssertEqual(context.codingPath as? [DummyKey], path + [key])
            XCTAssertEqual(
                context.debugDescription,
                "Expected a type of \(String.self), but found an array of rows."
            )
        }
    }
    
    func testDecoderForKey() throws {
        let path = [DummyKey(stringValue: "rootKey")]
        let key = DummyKey(intValue: 0)
        let rows = [SQLiteRow()]
        let decoder = decoder(sqliteData: rows, codingPath: path)
        let nestedDecoder = try decoder.decoder(for: key)
        
        guard let rowDecoder = nestedDecoder as? SingleRowDecoder else {
            return XCTFail("Expected SingleRowDecoder, but got: \(type(of: nestedDecoder)).")
        }
        
        XCTAssertTrue(rowDecoder.dateDecoder as? MockDateDecoder === decoder.dateDecoder as? MockDateDecoder)
        XCTAssertEqual(rowDecoder.codingPath as? [DummyKey], path + [key])
    }
    
    func testDecoderWithInvalidKey() {
        let path = [DummyKey(stringValue: "rootKey")]
        let testKey = DummyKey(stringValue: "invalidKey")
        let decoder = decoder(sqliteData: [], codingPath: path)
        
        XCTAssertThrowsError(
            try decoder.decoder(for: testKey)
        ) { error in
            guard case let DecodingError.keyNotFound(key, context) = error else {
                return XCTFail("Expected DecodingError.keyNotFound, but got: \(error).")
            }
            
            XCTAssertEqual(key as? DummyKey, testKey)
            XCTAssertEqual(context.codingPath as? [DummyKey], path + [testKey])
            XCTAssertEqual(context.debugDescription, "Expected an integer key, but found a non-integer key.")
        }
    }
    
    func testKeyedContainer() {
        let path: [DummyKey] = [DummyKey(stringValue: "root")]
        let decoder = decoder(sqliteData: [], codingPath: path)
        
        XCTAssertThrowsError(try decoder.container(keyedBy: DummyKey.self)) { error in
            guard case let DecodingError.typeMismatch(expectedType, context) = error else {
                return XCTFail("Expected DecodingError.typeMismatch")
            }
            
            XCTAssertTrue(expectedType == KeyedDecodingContainer<DummyKey>.self)
            XCTAssertEqual(context.codingPath as? [DummyKey], path)
            XCTAssertEqual(context.debugDescription, "Expected a keyed container, but found an array of rows.")
        }
    }
    
    func testUnkeyedContainer() throws {
        let path = [DummyKey(stringValue: "rootKey")]
        let decoder = decoder(sqliteData: [SQLiteRow()], codingPath: path)
        
        let container = try decoder.unkeyedContainer()
        
        guard let unkeyed = container as? UnkeyedContainer<MultiRowDecoder> else {
            return XCTFail("Expected UnkeyedContainer, got: \(type(of: container))")
        }
        
        XCTAssertTrue(unkeyed.decoder === decoder)
        XCTAssertEqual(unkeyed.codingPath as? [DummyKey], path)
    }
    
    func testSingleValueContainer() {
        let path = [DummyKey(stringValue: "rootKey")]
        let decoder = decoder(sqliteData: [], codingPath: path)
        
        XCTAssertThrowsError(
            try decoder.singleValueContainer()
        ) { error in
            guard case let DecodingError.typeMismatch(type, context) = error else {
                return XCTFail("Expected DecodingError.typeMismatch, but got: \(error).")
            }
            
            XCTAssertTrue(type == SingleValueDecodingContainer.self)
            XCTAssertEqual(context.codingPath as? [DummyKey], path)
            XCTAssertEqual(context.debugDescription, "Expected a single value container, but found an array of rows.")
        }
    }
}

private extension MultiRowDecoderTests {
    func decoder(
        sqliteData: [SQLiteRow],
        codingPath: [any CodingKey] = []
    ) -> MultiRowDecoder {
        MultiRowDecoder(
            dateDecoder: MockDateDecoder(),
            sqliteData: sqliteData,
            codingPath: codingPath,
            userInfo: [:]
        )
    }
}

private extension MultiRowDecoderTests {
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
        func decode(
            from decoder: any ValueDecoder
        ) throws -> Date {
            fatalError()
        }
        
        func decode(
            from decoder: any RowDecoder,
            for key: any CodingKey
        ) throws -> Date {
            fatalError()
        }
    }
}
