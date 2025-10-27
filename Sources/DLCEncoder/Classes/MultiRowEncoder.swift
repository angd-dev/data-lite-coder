import Foundation
import DataLiteCore

private import DLCCommon

package final class MultiRowEncoder: RowEncoder {
    // MARK: - Properties
    
    package let dateEncoder: any DateEncoder
    package let codingPath: [any CodingKey]
    package let userInfo: [CodingUserInfoKey : Any]
    
    package private(set) var sqliteData = [SQLiteRow]()
    
    package var count: Int { sqliteData.count }
    
    // MARK: - Inits
    
    package init(
        dateEncoder: any DateEncoder,
        codingPath: [any CodingKey],
        userInfo: [CodingUserInfoKey : Any]
    ) {
        self.dateEncoder = dateEncoder
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    // MARK: - Methods
    
    package func set(_ value: Any, for key: any CodingKey) throws {
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
    
    package func encodeNil(for key: any CodingKey) throws {
        let value = Optional<Any>.none as Any
        let info = "Attempted to encode nil, but it's not supported."
        let context = EncodingError.Context(
            codingPath: codingPath + [key],
            debugDescription: info
        )
        throw EncodingError.invalidValue(value, context)
    }
    
    package func encodeDate(_ date: Date, for key: any CodingKey) throws {
        let info = "Attempted to encode Date, but it's not supported."
        let context = EncodingError.Context(
            codingPath: codingPath + [key],
            debugDescription: info
        )
        throw EncodingError.invalidValue(date, context)
    }
    
    package func encode<T: SQLiteBindable>(_ value: T, for key: any CodingKey) throws {
        let info = "Attempted to encode \(T.self), but it's not supported."
        let context = EncodingError.Context(
            codingPath: codingPath + [key],
            debugDescription: info
        )
        throw EncodingError.invalidValue(value, context)
    }
    
    package func encoder(for key: any CodingKey) throws -> any Encoder {
        SingleRowEncoder(
            dateEncoder: dateEncoder,
            codingPath: codingPath + [key],
            userInfo: userInfo
        )
    }
    
    package func container<Key: CodingKey>(
        keyedBy type: Key.Type
    ) -> KeyedEncodingContainer<Key> {
        let container = FailedEncodingContainer<Key>(
            codingPath: codingPath
        )
        return KeyedEncodingContainer(container)
    }
    
    package func unkeyedContainer() -> any UnkeyedEncodingContainer {
        UnkeyedContainer(encoder: self, codingPath: codingPath)
    }
    
    package func singleValueContainer() -> any SingleValueEncodingContainer {
        FailedEncodingContainer<RowCodingKey>(codingPath: codingPath)
    }
}
