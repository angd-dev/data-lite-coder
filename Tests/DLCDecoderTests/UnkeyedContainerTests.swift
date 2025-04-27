import XCTest
import DataLiteCore
import DLCCommon

@testable import DLCDecoder

final class UnkeyedContainerTests: XCTestCase {
    func testDecodeNil() {
        XCTAssertThrowsError(try container().decodeNil()) {
            checkIsAtEnd($0, Optional<Any>.self)
        }
        
        let nilContainer = container(withData: .null)
        XCTAssertEqual(
            nilContainer.currentIndex, 0,
            "Expected index to be 0 before decoding nil"
        )
        XCTAssertTrue(
            try nilContainer.decodeNil(),
            "Expected decodeNil() to return true"
        )
        XCTAssertEqual(
            nilContainer.currentIndex, 1,
            "Expected index to increment after decoding nil"
        )
        
        let notNilContainer = container(withData: .text("value"))
        XCTAssertFalse(
            try notNilContainer.decodeNil(),
            "Expected decodeNil() to return false for non-nil value"
        )
        XCTAssertEqual(
            notNilContainer.currentIndex, 0,
            "Expected index to remain unchanged for non-nil value"
        )
    }
    
    func testDecodeBool() {
        XCTAssertThrowsError(try container().decode(Bool.self)) {
            checkIsAtEnd($0, Bool.self)
        }
        
        let trueContainer = container(withData: .int(1))
        XCTAssertEqual(
            trueContainer.currentIndex, 0,
            "Expected index to be 0 before decoding true"
        )
        XCTAssertTrue(
            try trueContainer.decode(Bool.self),
            "Expected decode(Bool.self) to return true"
        )
        XCTAssertEqual(
            trueContainer.currentIndex, 1,
            "Expected index to increment after decoding true"
        )
        
        let falseContainer = container(withData: .int(0))
        XCTAssertEqual(
            falseContainer.currentIndex, 0,
            "Expected index to be 0 before decoding false"
        )
        XCTAssertFalse(
            try falseContainer.decode(Bool.self),
            "Expected decode(Bool.self) to return false"
        )
        XCTAssertEqual(
            falseContainer.currentIndex, 1,
            "Expected index to increment after decoding false"
        )
    }
    
    func testDecodeString() {
        XCTAssertThrowsError(try container().decode(String.self)) {
            checkIsAtEnd($0, String.self)
        }
        
        let container = container(withData: .text("Hello, SQLite!"))
        XCTAssertEqual(
            container.currentIndex, 0,
            "Expected index to be 0 before decoding string"
        )
        XCTAssertEqual(
            try container.decode(String.self), "Hello, SQLite!",
            "Expected decoded value to match original string"
        )
        XCTAssertEqual(
            container.currentIndex, 1,
            "Expected index to increment after decoding string"
        )
    }
    
    func testDecodeDouble() {
        XCTAssertThrowsError(try container().decode(Double.self)) {
            checkIsAtEnd($0, Double.self)
        }
        
        let container = container(withData: .real(3.14))
        XCTAssertEqual(
            container.currentIndex, 0,
            "Expected index to be 0 before decoding double"
        )
        XCTAssertEqual(
            try container.decode(Double.self), 3.14,
            "Expected decoded value to match original double"
        )
        XCTAssertEqual(
            container.currentIndex, 1,
            "Expected index to increment after decoding double"
        )
    }
    
    func testDecodeFloat() {
        XCTAssertThrowsError(try container().decode(Float.self)) {
            checkIsAtEnd($0, Float.self)
        }
        
        let container = container(withData: .real(2.71))
        XCTAssertEqual(
            container.currentIndex, 0,
            "Expected index to be 0 before decoding float"
        )
        XCTAssertEqual(
            try container.decode(Float.self), 2.71,
            "Expected decoded value to match original float"
        )
        XCTAssertEqual(
            container.currentIndex, 1,
            "Expected index to increment after decoding float"
        )
    }
    
    func testDecodeInt() {
        XCTAssertThrowsError(try container().decode(Int.self)) {
            checkIsAtEnd($0, Int.self)
        }
        
        let container = container(withData: .int(42))
        XCTAssertEqual(
            container.currentIndex, 0,
            "Expected index to be 0 before decoding Int"
        )
        XCTAssertEqual(
            try container.decode(Int.self), 42,
            "Expected decoded value to match Int"
        )
        XCTAssertEqual(
            container.currentIndex, 1,
            "Expected index to increment after decoding Int"
        )
    }
    
    func testDecodeInt8() {
        XCTAssertThrowsError(try container().decode(Int8.self)) {
            checkIsAtEnd($0, Int8.self)
        }
        
        let container = container(withData: .int(127))
        XCTAssertEqual(
            container.currentIndex, 0,
            "Expected index to be 0 before decoding Int8"
        )
        XCTAssertEqual(
            try container.decode(Int8.self), 127,
            "Expected decoded value to match Int8"
        )
        XCTAssertEqual(
            container.currentIndex, 1,
            "Expected index to increment after decoding Int8"
        )
    }
    
    func testDecodeInt16() {
        XCTAssertThrowsError(try container().decode(Int16.self)) {
            checkIsAtEnd($0, Int16.self)
        }
        
        let container = container(withData: .int(32_000))
        XCTAssertEqual(
            container.currentIndex, 0,
            "Expected index to be 0 before decoding Int16"
        )
        XCTAssertEqual(
            try container.decode(Int16.self), 32_000,
            "Expected decoded value to match Int16"
        )
        XCTAssertEqual(
            container.currentIndex, 1,
            "Expected index to increment after decoding Int16"
        )
    }
    
    func testDecodeInt32() {
        XCTAssertThrowsError(try container().decode(Int32.self)) {
            checkIsAtEnd($0, Int32.self)
        }
        
        let container = container(withData: .int(2_147_483_647))
        XCTAssertEqual(
            container.currentIndex, 0,
            "Expected index to be 0 before decoding Int32"
        )
        XCTAssertEqual(
            try container.decode(Int32.self), 2_147_483_647,
            "Expected decoded value to match Int32"
        )
        XCTAssertEqual(
            container.currentIndex, 1,
            "Expected index to increment after decoding Int32"
        )
    }
    
    func testDecodeInt64() {
        XCTAssertThrowsError(try container().decode(Int64.self)) {
            checkIsAtEnd($0, Int64.self)
        }
        
        let container = container(withData: .int(9_223_372_036_854_775_807))
        XCTAssertEqual(
            container.currentIndex, 0,
            "Expected index to be 0 before decoding Int64"
        )
        XCTAssertEqual(
            try container.decode(Int64.self), 9_223_372_036_854_775_807,
            "Expected decoded value to match Int64"
        )
        XCTAssertEqual(
            container.currentIndex, 1,
            "Expected index to increment after decoding Int64"
        )
    }
    
    func testDecodeUInt() {
        XCTAssertThrowsError(try container().decode(UInt.self)) {
            checkIsAtEnd($0, UInt.self)
        }
        
        let container = container(withData: .int(42))
        XCTAssertEqual(
            container.currentIndex, 0,
            "Expected index to be 0 before decoding UInt"
        )
        XCTAssertEqual(
            try container.decode(UInt.self), 42,
            "Expected decoded value to match UInt"
        )
        XCTAssertEqual(
            container.currentIndex, 1,
            "Expected index to increment after decoding UInt"
        )
    }
    
    func testDecodeUInt8() {
        XCTAssertThrowsError(try container().decode(UInt8.self)) {
            checkIsAtEnd($0, UInt8.self)
        }
        
        let container = container(withData: .int(255))
        XCTAssertEqual(
            container.currentIndex, 0,
            "Expected index to be 0 before decoding UInt8"
        )
        XCTAssertEqual(
            try container.decode(UInt8.self), 255,
            "Expected decoded value to match UInt8"
        )
        XCTAssertEqual(
            container.currentIndex, 1,
            "Expected index to increment after decoding UInt8"
        )
    }
    
    func testDecodeUInt16() {
        XCTAssertThrowsError(try container().decode(UInt16.self)) {
            checkIsAtEnd($0, UInt16.self)
        }
        
        let container = container(withData: .int(32_000))
        XCTAssertEqual(
            container.currentIndex, 0,
            "Expected index to be 0 before decoding UInt16"
        )
        XCTAssertEqual(
            try container.decode(UInt16.self), 32_000,
            "Expected decoded value to match UInt16"
        )
        XCTAssertEqual(
            container.currentIndex, 1,
            "Expected index to increment after decoding UInt16"
        )
    }
    
    func testDecodeUInt32() {
        XCTAssertThrowsError(try container().decode(UInt32.self)) {
            checkIsAtEnd($0, UInt32.self)
        }
        
        let container = container(withData: .int(4_294_967_295))
        XCTAssertEqual(
            container.currentIndex, 0,
            "Expected index to be 0 before decoding UInt32"
        )
        XCTAssertEqual(
            try container.decode(UInt32.self), 4_294_967_295,
            "Expected decoded value to match UInt32"
        )
        XCTAssertEqual(
            container.currentIndex, 1,
            "Expected index to increment after decoding UInt32"
        )
    }
    
    func testDecodeUInt64() {
        XCTAssertThrowsError(try container().decode(UInt64.self)) {
            checkIsAtEnd($0, UInt64.self)
        }
        
        let container = container(withData: .int(9_223_372_036_854_775_807))
        XCTAssertEqual(
            container.currentIndex, 0,
            "Expected index to be 0 before decoding UInt64"
        )
        XCTAssertEqual(
            try container.decode(UInt64.self), 9_223_372_036_854_775_807,
            "Expected decoded value to match UInt64"
        )
        XCTAssertEqual(
            container.currentIndex, 1,
            "Expected index to increment after decoding UInt64"
        )
    }
    
    func testDecodeDate() {
        XCTAssertThrowsError(try container().decode(Date.self)) {
            checkIsAtEnd($0, Date.self)
        }
        
        let date = Date(timeIntervalSince1970: 12345)
        let container = container(withData: .real(date.timeIntervalSince1970))
        
        XCTAssertEqual(
            container.currentIndex, 0,
            "Expected index to be 0 before decoding Date"
        )
        XCTAssertEqual(
            try container.decode(Date.self), date,
            "Expected decoded value to match Date"
        )
        XCTAssertEqual(
            container.currentIndex, 1,
            "Expected index to increment after decoding Date"
        )
    }
    
    func testDecodeRawRepresentable() {
        XCTAssertThrowsError(try container().decode(RawRepresentableEnum.self)) {
            checkIsAtEnd($0, RawRepresentableEnum.self)
        }
        
        let `case` = RawRepresentableEnum.test
        let container = container(withData: .text(`case`.rawValue))
        
        XCTAssertEqual(
            container.currentIndex, 0,
            "Expected index to be 0 before decoding RawRepresentableEnum"
        )
        XCTAssertEqual(
            try container.decode(RawRepresentableEnum.self), `case`,
            "Expected decoded value to match RawRepresentableEnum"
        )
        XCTAssertEqual(
            container.currentIndex, 1,
            "Expected index to increment after decoding RawRepresentableEnum"
        )
    }
    
    func testDecodeDecodable() {
        XCTAssertThrowsError(try container().decode(DecodableEnum.self)) {
            checkIsAtEnd($0, DecodableEnum.self)
        }
        
        let `case` = DecodableEnum.test
        let container = container(withData: .text(`case`.rawValue))
        
        XCTAssertEqual(
            container.currentIndex, 0,
            "Expected index to be 0 before decoding DecodableEnum"
        )
        XCTAssertEqual(
            try container.decode(DecodableEnum.self), `case`,
            "Expected decoded value to match DecodableEnum"
        )
        XCTAssertEqual(
            container.currentIndex, 1,
            "Expected index to increment after decoding DecodableEnum"
        )
    }
    
    func testNestedContainerKeyedBy() {
        XCTAssertThrowsError(
            try container().nestedContainer(keyedBy: RowCodingKey.self)
        ) { error in
            guard case let DecodingError.typeMismatch(type, context) = error else {
                XCTFail("Expected .typeMismatch, but got: \(error).")
                return
            }
            
            XCTAssertTrue(
                type == KeyedDecodingContainer<RowCodingKey>.self,
                "Expected KeyedDecodingContainer type."
            )
            
            XCTAssertEqual(
                context.codingPath as? [RowCodingKey], [.init(intValue: 0)],
                "Incorrect coding path in decoding error."
            )
            
            XCTAssertEqual(
                context.debugDescription,
                """
                Attempted to decode a nested keyed container,
                but the value cannot be represented as a keyed container.
                """,
                "Unexpected debug description in decoding error."
            )
        }
    }
    
    func testNestedUnkeyedContainer() {
        XCTAssertThrowsError(
            try container().nestedUnkeyedContainer()
        ) { error in
            guard case let DecodingError.typeMismatch(type, context) = error else {
                XCTFail("Expected .typeMismatch, but got: \(error).")
                return
            }
            
            XCTAssertTrue(
                type == UnkeyedDecodingContainer.self,
                "Expected UnkeyedDecodingContainer type."
            )
            
            XCTAssertEqual(
                context.codingPath as? [RowCodingKey], [.init(intValue: 0)],
                "Incorrect coding path in decoding error."
            )
            
            XCTAssertEqual(
                context.debugDescription,
                """
                Attempted to decode a nested unkeyed container,
                but the value cannot be represented as an unkeyed container.
                """,
                "Unexpected debug description in decoding error."
            )
        }
    }
    
    func testSuperDecoder() {
        XCTAssertThrowsError(
            try container().superDecoder()
        ) { error in
            guard case let DecodingError.typeMismatch(type, context) = error else {
                XCTFail("Expected .typeMismatch, but got: \(error).")
                return
            }
            
            XCTAssertTrue(
                type == Swift.Decoder.self,
                "Expected Swift.Decoder type."
            )
            
            XCTAssertEqual(
                context.codingPath as? [RowCodingKey], [.init(intValue: 0)],
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
}

private extension UnkeyedContainerTests {
    func container(
        withData data: SQLiteRawValue,
        codingPath: [any CodingKey] = []
    ) -> UnkeyedContainer<MockKeyedDecoder> {
        var row = SQLiteRow()
        row["key"] = data
        return container(
            withData: row,
            codingPath: codingPath
        )
    }
    
    func container(
        withData data: SQLiteRow = .init(),
        codingPath: [any CodingKey] = []
    ) -> UnkeyedContainer<MockKeyedDecoder> {
        UnkeyedContainer(
            decoder: MockKeyedDecoder(sqliteData: data),
            codingPath: codingPath
        )
    }
    
    func checkIsAtEnd(_ error: any Error, _ expectedType: Any.Type) {
        guard case let DecodingError.valueNotFound(type, context) = error else {
            XCTFail("Expected .valueNotFound, got: \(error)")
            return
        }
        
        XCTAssertTrue(
            type == expectedType,
            "Expected type: \(expectedType), got: \(type)"
        )
        
        XCTAssertEqual(
            context.codingPath as? [RowCodingKey],
            [RowCodingKey(intValue: 0)],
            "Invalid codingPath: \(context.codingPath)"
        )
        
        XCTAssertEqual(
            context.debugDescription,
            "Unkeyed container is at end.",
            "Invalid debugDescription: \(context.debugDescription)"
        )
    }
}

private extension UnkeyedContainerTests {
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
    
    final class MockKeyedDecoder: RowDecoder {
        typealias SQLiteData = SQLiteRow
        
        let sqliteData: SQLiteData
        let dateDecoder: DateDecoder
        let codingPath: [any CodingKey]
        let userInfo: [CodingUserInfoKey: Any]
        
        var count: Int? {
            sqliteData.isEmpty ? nil : sqliteData.count
        }
        
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
            sqliteData[key.intValue!].value == .null
        }
        
        func decodeDate(for key: any CodingKey) throws -> Date {
            try dateDecoder.decode(from: self, for: key)
        }
        
        func decode<T: SQLiteRawRepresentable>(
            _ type: T.Type,
            for key: any CodingKey
        ) throws -> T {
            type.init(sqliteData[key.intValue!].value)!
        }
        
        func decoder(for key: any CodingKey) -> any Decoder {
            MockValueDecoder(sqliteData: sqliteData[key.intValue!].value)
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
