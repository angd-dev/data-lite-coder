import XCTest
import DataLiteCore
import DLCCommon

@testable import DLCEncoder

final class UnkeyedContainerTests: XCTestCase {
    func testEncodeNil() throws {
        let encoder = MockMultiRowEncoder()
        let container = UnkeyedContainer<MockMultiRowEncoder>(
            encoder: encoder,
            codingPath: []
        )
        try container.encodeNil()
        XCTAssertTrue(encoder.sqliteData.isEmpty)
    }
    
    func testEncodeModel() throws {
        let encoder = MockMultiRowEncoder()
        let container = UnkeyedContainer<MockMultiRowEncoder>(
            encoder: encoder,
            codingPath: []
        )
        
        try container.encode(TestModel(id: 1, name: "John"))
        
        XCTAssertEqual(encoder.sqliteData.count, 1)
        XCTAssertEqual(encoder.sqliteData.first?.count, 2)
        XCTAssertEqual(encoder.sqliteData.first?["id"], .int(1))
        XCTAssertEqual(encoder.sqliteData.first?["name"], .text("John"))
    }
    
    func testEncodeOptionalModel() throws {
        let encoder = MockMultiRowEncoder()
        let container = UnkeyedContainer<MockMultiRowEncoder>(
            encoder: encoder,
            codingPath: []
        )
        
        try container.encode(TestModel(id: 1, name: "John") as TestModel?)
        
        XCTAssertEqual(encoder.sqliteData.count, 1)
        XCTAssertEqual(encoder.sqliteData.first?.count, 2)
        XCTAssertEqual(encoder.sqliteData.first?["id"], .int(1))
        XCTAssertEqual(encoder.sqliteData.first?["name"], .text("John"))
    }
    
    func testEncodeNilModel() throws {
        let encoder = MockMultiRowEncoder()
        let container = UnkeyedContainer<MockMultiRowEncoder>(
            encoder: encoder,
            codingPath: []
        )
        
        try container.encode(nil as TestModel?)
        
        XCTAssertTrue(encoder.sqliteData.isEmpty)
    }
    
    func testNestedKeyedContainer() {
        let path = [RowCodingKey(intValue: 123)]
        let encoder = MockMultiRowEncoder()
        let container = UnkeyedContainer<MockMultiRowEncoder>(
            encoder: encoder,
            codingPath: path
        )
        let nestedContainer = container.nestedContainer(
            keyedBy: RowCodingKey.self
        )
        XCTAssertEqual(nestedContainer.codingPath as? [RowCodingKey], path)
    }
    
    func testNestedUnkeyedContainer() {
        let path = [RowCodingKey(intValue: 123)]
        let encoder = MockMultiRowEncoder()
        let container = UnkeyedContainer<MockMultiRowEncoder>(
            encoder: encoder,
            codingPath: path
        )
        let nestedContainer = container.nestedUnkeyedContainer()
        XCTAssertTrue(nestedContainer is FailedEncodingContainer<RowCodingKey>)
        XCTAssertEqual(nestedContainer.codingPath as? [RowCodingKey], path)
    }
    
    func testSuperEncoder() {
        let path = [RowCodingKey(intValue: 123)]
        let encoder = MockMultiRowEncoder()
        let container = UnkeyedContainer<MockMultiRowEncoder>(
            encoder: encoder,
            codingPath: path
        )
        let superEncoder = container.superEncoder()
        XCTAssertTrue(superEncoder is FailedEncoder)
        XCTAssertEqual(superEncoder.codingPath as? [RowCodingKey], path)
    }
}

private extension UnkeyedContainerTests {
    struct TestModel: Encodable {
        let id: Int
        let name: String
    }
    
    final class MockDateEncoder: DateEncoder {
        func encode(_ date: Date, to encoder: any ValueEncoder) throws {
            fatalError()
        }
        
        func encode(_ date: Date, for key: any CodingKey, to encoder: any RowEncoder) throws {
            fatalError()
        }
    }
    
    final class MockMultiRowEncoder: RowEncoder {
        private(set) var sqliteData: [SQLiteRow]
        let dateEncoder: any DateEncoder
        let codingPath: [any CodingKey]
        let userInfo: [CodingUserInfoKey: Any]
        var count: Int { sqliteData.count }
        
        init(
            sqliteData: [SQLiteRow] = [],
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
            guard let value = value as? SQLiteRow else {
                fatalError()
            }
            sqliteData.append(value)
        }
        
        func encodeNil(for key: any CodingKey) throws {
            fatalError()
        }
        
        func encodeDate(_ date: Date, for key: any CodingKey) throws {
            fatalError()
        }
        
        func encode<T: SQLiteRawBindable>(_ value: T, for key: any CodingKey) throws {
            fatalError()
        }
        
        func encoder(for key: any CodingKey) throws -> any Encoder {
            MockSingleRowEncoder()
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
            fatalError()
        }
        
        func container<Key: CodingKey>(
            keyedBy type: Key.Type
        ) -> KeyedEncodingContainer<Key> {
            let container = MockKeyedContainer<MockSingleRowEncoder, Key>(
                encoder: self, codingPath: []
            )
            return KeyedEncodingContainer(container)
        }
        
        func unkeyedContainer() -> any UnkeyedEncodingContainer {
            fatalError()
        }
        
        func singleValueContainer() -> any SingleValueEncodingContainer {
            fatalError()
        }
    }
    
    final class MockKeyedContainer<Encoder: RowEncoder, Key: CodingKey>: Container, KeyedEncodingContainerProtocol {
        // MARK: - Properties
        
        let encoder: Encoder
        let codingPath: [any CodingKey]
        
        // MARK: - Inits
        
        init(
            encoder: Encoder,
            codingPath: [any CodingKey]
        ) {
            self.encoder = encoder
            self.codingPath = codingPath
        }
        
        // MARK: - Container Methods
        
        func encodeNil(forKey key: Key) throws {
            try encoder.encodeNil(for: key)
        }
        
        func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
            switch value {
            case let value as Date:
                try encoder.encodeDate(value, for: key)
            case let value as SQLiteRawRepresentable:
                try encoder.encode(value, for: key)
            default:
                let valueEncoder = try encoder.encoder(for: key)
                try value.encode(to: valueEncoder)
                try encoder.set(valueEncoder.sqliteData, for: key)
            }
        }
        
        func encodeIfPresent<T: Encodable>(_ value: T?, forKey key: Key) throws {
            switch value {
            case .some(let value):
                try encode(value, forKey: key)
            case .none:
                try encodeNil(forKey: key)
            }
        }
        
        func nestedContainer<NestedKey: CodingKey>(
            keyedBy keyType: NestedKey.Type,
            forKey key: Key
        ) -> KeyedEncodingContainer<NestedKey> {
            fatalError()
        }
        
        func nestedUnkeyedContainer(
            forKey key: Key
        ) -> any UnkeyedEncodingContainer {
            fatalError()
        }
        
        func superEncoder() -> any Swift.Encoder {
            fatalError()
        }
        
        func superEncoder(forKey key: Key) -> any Swift.Encoder {
            fatalError()
        }
    }
}
