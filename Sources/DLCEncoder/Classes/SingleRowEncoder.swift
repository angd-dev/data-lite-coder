import Foundation
import DataLiteCore

private import DLCCommon

final class SingleRowEncoder: RowEncoder {
    // MARK: - Properties
    
    let dateEncoder: any DateEncoder
    let codingPath: [any CodingKey]
    let userInfo: [CodingUserInfoKey : Any]
    
    private(set) var sqliteData = SQLiteRow()
    
    var count: Int { sqliteData.count }
    
    // MARK: - Inits
    
    init(
        dateEncoder: any DateEncoder,
        codingPath: [any CodingKey],
        userInfo: [CodingUserInfoKey : Any],
    ) {
        self.dateEncoder = dateEncoder
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    // MARK: - Methods
    
    func set(_ value: Any, for key: any CodingKey) throws {
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
    
    func encodeNil(for key: any CodingKey) throws {
        sqliteData[key] = .null
    }
    
    func encodeDate(_ date: Date, for key: any CodingKey) throws {
        try dateEncoder.encode(date, for: key, to: self)
    }
    
    func encode<T: SQLiteRawBindable>(_ value: T, for key: any CodingKey) throws {
        sqliteData[key] = value.sqliteRawValue
    }
    
    func encoder(for key: any CodingKey) throws -> any Encoder {
        SingleValueEncoder(
            dateEncoder: dateEncoder,
            codingPath: codingPath + [key],
            userInfo: userInfo
        )
    }
    
    func container<Key: CodingKey>(
        keyedBy type: Key.Type
    ) -> KeyedEncodingContainer<Key> {
        let container = KeyedContainer<SingleRowEncoder, Key>(
            encoder: self, codingPath: codingPath
        )
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> any UnkeyedEncodingContainer {
        FailedEncodingContainer<RowCodingKey>(codingPath: codingPath)
    }
    
    func singleValueContainer() -> any SingleValueEncodingContainer {
        FailedEncodingContainer<RowCodingKey>(codingPath: codingPath)
    }
}
