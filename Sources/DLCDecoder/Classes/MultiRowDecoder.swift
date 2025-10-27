import Foundation
import DataLiteCore

package final class MultiRowDecoder: RowDecoder {
    // MARK: - Properties
    
    package let dateDecoder: any DateDecoder
    package let sqliteData: [SQLiteRow]
    package let codingPath: [any CodingKey]
    package let userInfo: [CodingUserInfoKey: Any]
    
    package var count: Int? { sqliteData.count }
    
    // MARK: Inits
    
    package init(
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
    
    package func decodeNil(for key: any CodingKey) throws -> Bool {
        let info = "Attempted to decode nil, but it's not supported for an array of rows."
        let context = DecodingError.Context(
            codingPath: codingPath + [key],
            debugDescription: info
        )
        throw DecodingError.dataCorrupted(context)
    }
    
    package func decodeDate(for key: any CodingKey) throws -> Date {
        return try decode(Date.self, for: key)
    }
    
    package func decode<T: SQLiteRepresentable>(
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
    
    package func decoder(for key: any CodingKey) throws -> any Decoder {
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
    
    package func container<Key: CodingKey>(
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
    
    package func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        UnkeyedContainer(
            decoder: self,
            codingPath: codingPath
        )
    }
    
    package func singleValueContainer() throws -> any SingleValueDecodingContainer {
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
