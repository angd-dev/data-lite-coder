import Foundation
import DataLiteCore

final class SingleValueDecoder: ValueDecoder {
    // MARK: - Properties
    
    let dateDecoder: any DateDecoder
    let sqliteData: SQLiteRawValue
    let codingPath: [any CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    
    // MARK: - Inits
    
    init(
        dateDecoder: any DateDecoder,
        sqliteData: SQLiteRawValue,
        codingPath: [any CodingKey],
        userInfo: [CodingUserInfoKey: Any]
    ) {
        self.dateDecoder = dateDecoder
        self.sqliteData = sqliteData
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    // MARK: - Methods
    
    func decodeNil() -> Bool {
        sqliteData == .null
    }
    
    func decodeDate() throws -> Date {
        try dateDecoder.decode(from: self)
    }
    
    func decode<T: SQLiteRawRepresentable>(_ type: T.Type) throws -> T {
        guard sqliteData != .null else {
            let info = "Cannot get value of type \(T.self), found null value instead."
            let context = DecodingError.Context(
                codingPath: codingPath,
                debugDescription: info
            )
            throw DecodingError.valueNotFound(type, context)
        }
        
        guard let result = type.init(sqliteData) else {
            let info = "Expected to decode \(T.self) but found an \(sqliteData) instead."
            let context = DecodingError.Context(
                codingPath: codingPath,
                debugDescription: info
            )
            throw DecodingError.typeMismatch(type, context)
        }
        
        return result
    }
    
    func container<Key: CodingKey>(
        keyedBy type: Key.Type
    ) throws -> KeyedDecodingContainer<Key> {
        let info = "Expected a keyed container, but found a single value."
        let context = DecodingError.Context(
            codingPath: codingPath,
            debugDescription: info
        )
        throw DecodingError.typeMismatch(
            KeyedDecodingContainer<Key>.self,
            context
        )
    }
    
    func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        let info = "Expected a unkeyed container, but found a single value."
        let context = DecodingError.Context(
            codingPath: codingPath,
            debugDescription: info
        )
        throw DecodingError.typeMismatch(
            UnkeyedDecodingContainer.self,
            context
        )
    }
    
    func singleValueContainer() throws -> any SingleValueDecodingContainer {
        SingleValueContainer(decoder: self, codingPath: codingPath)
    }
}
