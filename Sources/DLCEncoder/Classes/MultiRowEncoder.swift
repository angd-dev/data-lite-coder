import Foundation
import DataLiteCore

private import DLCCommon

public final class MultiRowEncoder: RowEncoder {
    // MARK: - Properties
    
    public let dateEncoder: any DateEncoder
    public let codingPath: [any CodingKey]
    public let userInfo: [CodingUserInfoKey : Any]
    
    public private(set) var sqliteData = [SQLiteRow]()
    
    public var count: Int { sqliteData.count }
    
    // MARK: - Inits
    
    public init(
        dateEncoder: any DateEncoder,
        codingPath: [any CodingKey],
        userInfo: [CodingUserInfoKey : Any]
    ) {
        self.dateEncoder = dateEncoder
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    // MARK: - Methods
    
    public func set(_ value: Any, for key: any CodingKey) throws {
        guard let value = value as? SQLiteRow else {
            let info = "Expected value of type \(SQLiteRow.self)"
            let context = EncodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: info
            )
            throw EncodingError.invalidValue(value, context)
        }
        sqliteData.append(value)
    }
    
    public func encodeNil(for key: any CodingKey) throws {
        let value = Optional<Any>.none as Any
        let info = "Attempted to encode nil, but it's not supported."
        let context = EncodingError.Context(
            codingPath: codingPath + [key],
            debugDescription: info
        )
        throw EncodingError.invalidValue(value, context)
    }
    
    public func encodeDate(_ date: Date, for key: any CodingKey) throws {
        let info = "Attempted to encode Date, but it's not supported."
        let context = EncodingError.Context(
            codingPath: codingPath + [key],
            debugDescription: info
        )
        throw EncodingError.invalidValue(date, context)
    }
    
    public func encode<T: SQLiteRawBindable>(_ value: T, for key: any CodingKey) throws {
        let info = "Attempted to encode \(T.self), but it's not supported."
        let context = EncodingError.Context(
            codingPath: codingPath + [key],
            debugDescription: info
        )
        throw EncodingError.invalidValue(value, context)
    }
    
    public func encoder(for key: any CodingKey) throws -> any Encoder {
        SingleRowEncoder(
            dateEncoder: dateEncoder,
            codingPath: codingPath + [key],
            userInfo: userInfo
        )
    }
    
    public func container<Key: CodingKey>(
        keyedBy type: Key.Type
    ) -> KeyedEncodingContainer<Key> {
        let container = FailedEncodingContainer<Key>(
            codingPath: codingPath
        )
        return KeyedEncodingContainer(container)
    }
    
    public func unkeyedContainer() -> any UnkeyedEncodingContainer {
        UnkeyedContainer(encoder: self, codingPath: codingPath)
    }
    
    public func singleValueContainer() -> any SingleValueEncodingContainer {
        FailedEncodingContainer<RowCodingKey>(codingPath: codingPath)
    }
}
