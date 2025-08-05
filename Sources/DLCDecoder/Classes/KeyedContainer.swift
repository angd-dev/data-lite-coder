import Foundation
import DataLiteCore

final class KeyedContainer<Decoder: RowDecoder & KeyCheckingDecoder, Key: CodingKey>: Container, KeyedDecodingContainerProtocol {
    // MARK: - Properties
    
    let decoder: Decoder
    let codingPath: [any CodingKey]
    let allKeys: [Key]
    
    // MARK: - Inits
    
    init(
        decoder: Decoder,
        codingPath: [any CodingKey],
        allKeys: [Key]
    ) {
        self.decoder = decoder
        self.codingPath = codingPath
        self.allKeys = allKeys
    }
    
    // MARK: - Container Methods
    
    func contains(_ key: Key) -> Bool {
        decoder.contains(key)
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        try decoder.decodeNil(for: key)
    }
    
    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        switch type {
        case is Date.Type:
            try decoder.decodeDate(for: key) as! T
        case let type as SQLiteRawRepresentable.Type:
            try decoder.decode(type, for: key) as! T
        default:
            try T(from: decoder.decoder(for: key))
        }
    }
    
    func nestedContainer<NestedKey: CodingKey>(
        keyedBy type: NestedKey.Type,
        forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> {
        let info = """
            Attempted to decode a nested keyed container for key '\(key.stringValue)',
            but the value cannot be represented as a keyed container.
            """
        let context = DecodingError.Context(
            codingPath: codingPath + [key],
            debugDescription: info
        )
        throw DecodingError.typeMismatch(
            KeyedDecodingContainer<NestedKey>.self,
            context
        )
    }
    
    func nestedUnkeyedContainer(
        forKey key: Key
    ) throws -> any UnkeyedDecodingContainer {
        let info = """
            Attempted to decode a nested unkeyed container for key '\(key.stringValue)',
            but the value cannot be represented as an unkeyed container.
            """
        let context = DecodingError.Context(
            codingPath: codingPath + [key],
            debugDescription: info
        )
        throw DecodingError.typeMismatch(
            UnkeyedDecodingContainer.self,
            context
        )
    }
    
    func superDecoder() throws -> any Swift.Decoder {
        let info = """
            Attempted to get a superDecoder,
            but SQLiteRowDecoder does not support superDecoding.
            """
        let context = DecodingError.Context(
            codingPath: codingPath,
            debugDescription: info
        )
        throw DecodingError.typeMismatch(Swift.Decoder.self, context)
    }
    
    func superDecoder(forKey key: Key) throws -> any Swift.Decoder {
        let info = """
            Attempted to get a superDecoder for key '\(key.stringValue)',
            but SQLiteRowDecoder does not support nested structures.
            """
        let context = DecodingError.Context(
            codingPath: codingPath + [key],
            debugDescription: info
        )
        throw DecodingError.typeMismatch(Swift.Decoder.self, context)
    }
}
