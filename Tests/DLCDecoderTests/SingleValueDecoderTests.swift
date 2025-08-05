import XCTest
import DataLiteCore

@testable import DLCDecoder

final class SingleValueDecoderTests: XCTestCase {
    func testDecodeNil() {
        XCTAssertTrue(decoder(sqliteData: .null).decodeNil())
        XCTAssertFalse(decoder(sqliteData: .int(0)).decodeNil())
    }
    
    func testDecodeDate() {
        let expected = Date()
        let dateDecoder = MockDateDecoder(expectedDate: expected)
        let decoder = decoder(dateDecoder: dateDecoder, sqliteData: .int(0))
        
        XCTAssertEqual(try decoder.decodeDate(), expected)
        XCTAssertTrue(dateDecoder.didCallDecode)
    }
    
    func testDecodeWithNullValue() {
        let decoder = decoder(sqliteData: .null, codingPath: [DummyKey(stringValue: "test_key")])
        XCTAssertThrowsError(
            try decoder.decode(Int.self)
        ) { error in
            guard case let DecodingError.valueNotFound(type, context) = error else {
                return XCTFail("Expected DecodingError.valueNotFound, but got: \(error).")
            }
            XCTAssertTrue(type == Int.self)
            XCTAssertEqual(context.codingPath as? [DummyKey], decoder.codingPath as? [DummyKey])
            XCTAssertEqual(context.debugDescription, "Cannot get value of type Int, found null value instead.")
        }
    }
    
    func testDecodeWithTypeMismatch() {
        let decoder = decoder(sqliteData: .int(0), codingPath: [DummyKey(intValue: 1)])
        XCTAssertThrowsError(
            try decoder.decode(Data.self)
        ) { error in
            guard case let DecodingError.typeMismatch(type, context) = error else {
                return XCTFail("Expected DecodingError.typeMismatch, but got: \(error).")
            }
            XCTAssertTrue(type == Data.self)
            XCTAssertEqual(context.codingPath as? [DummyKey], decoder.codingPath as? [DummyKey])
            XCTAssertEqual(context.debugDescription, "Expected to decode Data but found an \(SQLiteRawValue.int(0)) instead.")
        }
    }
    
    func testDecodeWithCorrectValue() {
        let decoder = decoder(sqliteData: .text("test"))
        XCTAssertEqual(try decoder.decode(String.self), "test")
    }
    
    func testKeyedContainer() {
        let path: [DummyKey] = [DummyKey(stringValue: "root")]
        let decoder = decoder(sqliteData: .text("value"), codingPath: path)
        
        XCTAssertThrowsError(try decoder.container(keyedBy: DummyKey.self)) { error in
            guard case let DecodingError.typeMismatch(expectedType, context) = error else {
                return XCTFail("Expected DecodingError.typeMismatch")
            }
            
            XCTAssertTrue(expectedType == KeyedDecodingContainer<DummyKey>.self)
            XCTAssertEqual(context.codingPath as? [DummyKey], path)
            XCTAssertEqual(context.debugDescription, "Expected a keyed container, but found a single value.")
        }
    }
    
    func testUnkeyedContainer() {
        let path: [DummyKey] = [DummyKey(stringValue: "array_key")]
        let decoder = decoder(sqliteData: .int(42), codingPath: path)
        
        XCTAssertThrowsError(try decoder.unkeyedContainer()) { error in
            guard case let DecodingError.typeMismatch(expectedType, context) = error else {
                return XCTFail("Expected DecodingError.typeMismatch, but got: \(error)")
            }
            
            XCTAssertTrue(expectedType == UnkeyedDecodingContainer.self)
            XCTAssertEqual(context.codingPath as? [DummyKey], path)
            XCTAssertEqual(context.debugDescription, "Expected a unkeyed container, but found a single value.")
        }
    }
    
    func testSingleValueContainer() throws {
        let path: [DummyKey] = [DummyKey(stringValue: "test_key")]
        let decoder = decoder(sqliteData: .int(0), codingPath: path)
        
        let container = try decoder.singleValueContainer()
        
        guard let singleContainer = container as? SingleValueContainer<SingleValueDecoder> else {
            return XCTFail("Expected SingleValueContainer")
        }
        
        XCTAssertTrue(singleContainer.decoder === decoder)
        XCTAssertEqual(singleContainer.codingPath as? [DummyKey], path)
    }
}

private extension SingleValueDecoderTests {
    func decoder(
        dateDecoder: DateDecoder = MockDateDecoder(),
        sqliteData: SQLiteRawValue,
        codingPath: [any CodingKey] = []
    ) -> SingleValueDecoder {
        SingleValueDecoder(
            dateDecoder: dateDecoder,
            sqliteData: sqliteData,
            codingPath: codingPath,
            userInfo: [:]
        )
    }
}

private extension SingleValueDecoderTests {
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
            didCallDecode = true
            return expectedDate
        }
        
        func decode(
            from decoder: any RowDecoder,
            for key: any CodingKey
        ) throws -> Date {
            fatalError()
        }
    }
}
