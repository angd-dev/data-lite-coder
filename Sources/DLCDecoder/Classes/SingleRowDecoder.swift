import Foundation
import DataLiteCore

private import DLCCommon

final class SingleRowDecoder: RowDecoder, KeyCheckingDecoder {
    // MARK: - Properties
    
    let dateDecoder: any DateDecoder
    let sqliteData: SQLiteRow
    let codingPath: [any CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    
    var count: Int? { sqliteData.count }
    
    // MARK: Inits
    
    init(
        dateDecoder: any DateDecoder,
        sqliteData: SQLiteRow,
        codingPath: [any CodingKey],
        userInfo: [CodingUserInfoKey: Any]
    ) {
        self.dateDecoder = dateDecoder
        self.sqliteData = sqliteData
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    // MARK: - Methods
    
    func contains(_ key: any CodingKey) -> Bool {
        sqliteData.contains(key)
    }
    
    func decodeNil(for key: any CodingKey) throws -> Bool {
        guard sqliteData.contains(key) else {
            let info = "No value associated with key \(key)."
            let context = DecodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: info
            )
            throw DecodingError.keyNotFound(key, context)
        }
        return sqliteData[key] == .null
    }
    
    func decodeDate(for key: any CodingKey) throws -> Date {
        try dateDecoder.decode(from: self, for: key)
    }
    
    func decode<T: SQLiteRawRepresentable>(
        _ type: T.Type,
        for key: any CodingKey
    ) throws -> T {
        guard let value = sqliteData[key] else {
            let info = "No value associated with key \(key)."
            let context = DecodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: info
            )
            throw DecodingError.keyNotFound(key, context)
        }
        
        guard value != .null else {
            let info = "Cannot get value of type \(T.self), found null value instead."
            let context = DecodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: info
            )
            throw DecodingError.valueNotFound(type, context)
        }
        
        guard let result = T(value) else {
            let info = "Expected to decode \(T.self) but found an \(value) instead."
            let context = DecodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: info
            )
            throw DecodingError.typeMismatch(type, context)
        }
        
        return result
    }
    
    func decoder(for key: any CodingKey) throws -> any Swift.Decoder {
        guard let data = sqliteData[key] else {
            let info = "No value associated with key \(key)."
            let context = DecodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: info
            )
            throw DecodingError.keyNotFound(key, context)
        }
        return SingleValueDecoder(
            dateDecoder: dateDecoder,
            sqliteData: data,
            codingPath: codingPath + [key],
            userInfo: userInfo
        )
    }
    
    func container<Key: CodingKey>(
        keyedBy type: Key.Type
    ) throws -> KeyedDecodingContainer<Key> {
        let allKeys = sqliteData.compactMap { (column, _) in
            Key(stringValue: column)
        }
        let container = KeyedContainer(
            decoder: self,
            codingPath: codingPath,
            allKeys: allKeys
        )
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        UnkeyedContainer(
            decoder: self,
            codingPath: codingPath
        )
    }
    
    func singleValueContainer() throws -> any SingleValueDecodingContainer {
        let info = "Expected a single value container, but found a row value."
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
