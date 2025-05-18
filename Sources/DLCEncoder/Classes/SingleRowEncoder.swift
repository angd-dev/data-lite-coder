import Foundation
import DataLiteCore

private import DLCCommon

public final class SingleRowEncoder: RowEncoder {
    // MARK: - Properties
    
    public let dateEncoder: any DateEncoder
    public let codingPath: [any CodingKey]
    public let userInfo: [CodingUserInfoKey : Any]
    
    public private(set) var sqliteData = SQLiteRow()
    
    public var count: Int { sqliteData.count }
    
    // MARK: - Inits
    
    public init(
        dateEncoder: any DateEncoder,
        codingPath: [any CodingKey],
        userInfo: [CodingUserInfoKey : Any],
    ) {
        self.dateEncoder = dateEncoder
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    // MARK: - Methods
    
    public func set(_ value: Any, for key: any CodingKey) throws {
        guard let value = value as? SQLiteRawValue else {
            let info = "The value does not match \(SQLiteRawValue.self)"
            let context = EncodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: info
            )
            throw EncodingError.invalidValue(value, context)
        }
        sqliteData[key] = value
    }
    
    public func encodeNil(for key: any CodingKey) throws {
        sqliteData[key] = .null
    }
    
    public func encodeDate(_ date: Date, for key: any CodingKey) throws {
        try dateEncoder.encode(date, for: key, to: self)
    }
    
    public func encode<T: SQLiteRawBindable>(_ value: T, for key: any CodingKey) throws {
        sqliteData[key] = value.sqliteRawValue
    }
    
    public func encoder(for key: any CodingKey) throws -> any Encoder {
        SingleValueEncoder(
            dateEncoder: dateEncoder,
            codingPath: codingPath + [key],
            userInfo: userInfo
        )
    }
    
    public func container<Key: CodingKey>(
        keyedBy type: Key.Type
    ) -> KeyedEncodingContainer<Key> {
        let container = KeyedContainer<SingleRowEncoder, Key>(
            encoder: self, codingPath: codingPath
        )
        return KeyedEncodingContainer(container)
    }
    
    public func unkeyedContainer() -> any UnkeyedEncodingContainer {
        FailedEncodingContainer<RowCodingKey>(codingPath: codingPath)
    }
    
    public func singleValueContainer() -> any SingleValueEncodingContainer {
        FailedEncodingContainer<RowCodingKey>(codingPath: codingPath)
    }
}
