import Foundation
import DataLiteCore

public final class MultiRowDecoder: RowDecoder {
    // MARK: - Properties
    
    public let dateDecoder: any DateDecoder
    public let sqliteData: [SQLiteRow]
    public let codingPath: [any CodingKey]
    public let userInfo: [CodingUserInfoKey: Any]
    
    public var count: Int? { sqliteData.count }
    
    // MARK: Inits
    
    public init(
        dateDecoder: any DateDecoder,
        sqliteData: [SQLiteRow],
        codingPath: [any CodingKey],
        userInfo: [CodingUserInfoKey: Any]
    ) {
        self.dateDecoder = dateDecoder
        self.sqliteData = sqliteData
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    // MARK: Methods
    
    public func decodeNil(for key: any CodingKey) throws -> Bool {
        let info = "Attempted to decode nil, but it's not supported for an array of rows."
        let context = DecodingError.Context(
            codingPath: codingPath + [key],
            debugDescription: info
        )
        throw DecodingError.dataCorrupted(context)
    }
    
    public func decodeDate(for key: any CodingKey) throws -> Date {
        return try decode(Date.self, for: key)
    }
    
    public func decode<T: SQLiteRawRepresentable>(
        _ type: T.Type,
        for key: any CodingKey
    ) throws -> T {
        let info = "Expected a type of \(type), but found an array of rows."
        let context = DecodingError.Context(
            codingPath: codingPath + [key],
            debugDescription: info
        )
        throw DecodingError.typeMismatch(type, context)
    }
    
    public func decoder(for key: any CodingKey) throws -> any Decoder {
        guard let index = key.intValue else {
            let info = "Expected an integer key, but found a non-integer key."
            let context = DecodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: info
            )
            throw DecodingError.keyNotFound(key, context)
        }
        return SingleRowDecoder(
            dateDecoder: dateDecoder,
            sqliteData: sqliteData[index],
            codingPath: codingPath + [key],
            userInfo: userInfo
        )
    }
    
    public func container<Key: CodingKey>(
        keyedBy type: Key.Type
    ) throws -> KeyedDecodingContainer<Key> {
        let info = "Expected a keyed container, but found an array of rows."
        let context = DecodingError.Context(
            codingPath: codingPath,
            debugDescription: info
        )
        throw DecodingError.typeMismatch(
            KeyedDecodingContainer<Key>.self,
            context
        )
    }
    
    public func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        UnkeyedContainer(
            decoder: self,
            codingPath: codingPath
        )
    }
    
    public func singleValueContainer() throws -> any SingleValueDecodingContainer {
        let info = "Expected a single value container, but found an array of rows."
        let context = DecodingError.Context(
            codingPath: codingPath,
            debugDescription: info
        )
        throw DecodingError.typeMismatch(
            SingleValueDecodingContainer.self,
            context
        )
    }
}
