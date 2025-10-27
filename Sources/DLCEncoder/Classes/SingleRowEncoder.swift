import Foundation
import DataLiteCore

private import DLCCommon

package final class SingleRowEncoder: RowEncoder {
    // MARK: - Properties
    
    package let dateEncoder: any DateEncoder
    package let codingPath: [any CodingKey]
    package let userInfo: [CodingUserInfoKey : Any]
    
    package private(set) var sqliteData = SQLiteRow()
    
    package var count: Int { sqliteData.count }
    
    // MARK: - Inits
    
    package init(
        dateEncoder: any DateEncoder,
        codingPath: [any CodingKey],
        userInfo: [CodingUserInfoKey : Any],
    ) {
        self.dateEncoder = dateEncoder
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    // MARK: - Methods
    
    package func set(_ value: Any, for key: any CodingKey) throws {
        guard let value = value as? SQLiteValue else {
            let info = "The value does not match \(SQLiteValue.self)"
            let context = EncodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: info
            )
            throw EncodingError.invalidValue(value, context)
        }
        sqliteData[key] = value
    }
    
    package func encodeNil(for key: any CodingKey) throws {
        sqliteData[key] = .null
    }
    
    package func encodeDate(_ date: Date, for key: any CodingKey) throws {
        try dateEncoder.encode(date, for: key, to: self)
    }
    
    package func encode<T: SQLiteBindable>(_ value: T, for key: any CodingKey) throws {
        sqliteData[key] = value.sqliteValue
    }
    
    package func encoder(for key: any CodingKey) throws -> any Encoder {
        SingleValueEncoder(
            dateEncoder: dateEncoder,
            codingPath: codingPath + [key],
            userInfo: userInfo
        )
    }
    
    package func container<Key: CodingKey>(
        keyedBy type: Key.Type
    ) -> KeyedEncodingContainer<Key> {
        let container = KeyedContainer<SingleRowEncoder, Key>(
            encoder: self, codingPath: codingPath
        )
        return KeyedEncodingContainer(container)
    }
    
    package func unkeyedContainer() -> any UnkeyedEncodingContainer {
        FailedEncodingContainer<RowCodingKey>(codingPath: codingPath)
    }
    
    package func singleValueContainer() -> any SingleValueEncodingContainer {
        FailedEncodingContainer<RowCodingKey>(codingPath: codingPath)
    }
}
