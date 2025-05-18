import Foundation
import DataLiteCore

private import DLCCommon

final class SingleValueEncoder: ValueEncoder {
    // MARK: - Properties
    
    let dateEncoder: any DateEncoder
    let codingPath: [any CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    
    private(set) var sqliteData: SQLiteRawValue?
    
    // MARK: - Inits
    
    init(
        dateEncoder: any DateEncoder,
        codingPath: [any CodingKey],
        userInfo: [CodingUserInfoKey: Any]
    ) {
        self.dateEncoder = dateEncoder
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    // MARK: - Methods
    
    func encodeNil() throws {
        sqliteData = .null
    }
    
    func encodeDate(_ date: Date) throws {
        try dateEncoder.encode(date, to: self)
    }
    
    func encode<T: SQLiteRawBindable>(_ value: T) throws {
        sqliteData = value.sqliteRawValue
    }
    
    func container<Key: CodingKey>(
        keyedBy type: Key.Type
    ) -> KeyedEncodingContainer<Key> {
        let container = FailedEncodingContainer<Key>(codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> any UnkeyedEncodingContainer {
        FailedEncodingContainer<RowCodingKey>(codingPath: codingPath)
    }
    
    func singleValueContainer() -> any SingleValueEncodingContainer {
        SingleValueContainer(encoder: self, codingPath: codingPath)
    }
}
