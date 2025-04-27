import Foundation
import DataLiteCore

private import DLCCommon

final class UnkeyedContainer<Decoder: RowDecoder>: Container, UnkeyedDecodingContainer {
    // MARK: - Properties
    
    let decoder: Decoder
    let codingPath: [any CodingKey]
    
    var count: Int? {
        decoder.count
    }
    
    var isAtEnd: Bool {
        currentIndex >= count ?? 0
    }
    
    private(set) var currentIndex: Int = 0
    
    private var currentKey: CodingKey {
        RowCodingKey(intValue: currentIndex)
    }
    
    // MARK: - Inits
    
    init(
        decoder: Decoder,
        codingPath: [any CodingKey]
    ) {
        self.decoder = decoder
        self.codingPath = codingPath
    }
    
    // MARK: - Container Methods
    
    func decodeNil() throws -> Bool {
        try checkIsAtEnd(Optional<Any>.self)
        if try decoder.decodeNil(for: currentKey) {
            currentIndex += 1
            return true
        } else {
            return false
        }
    }
    
    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try checkIsAtEnd(type)
        defer { currentIndex += 1 }
        
        switch type {
        case is Date.Type:
            return try decoder.decodeDate(for: currentKey) as! T
        case let type as SQLiteRawRepresentable.Type:
            return try decoder.decode(type, for: currentKey) as! T
        default:
            return try T(from: decoder.decoder(for: currentKey))
        }
    }
    
    func nestedContainer<NestedKey: CodingKey>(
        keyedBy type: NestedKey.Type
    ) throws -> KeyedDecodingContainer<NestedKey> {
        let info = """
            Attempted to decode a nested keyed container,
            but the value cannot be represented as a keyed container.
            """
        let context = DecodingError.Context(
            codingPath: codingPath + [currentKey],
            debugDescription: info
        )
        throw DecodingError.typeMismatch(
            KeyedDecodingContainer<NestedKey>.self,
            context
        )
    }
    
    func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
        let info = """
            Attempted to decode a nested unkeyed container,
            but the value cannot be represented as an unkeyed container.
            """
        let context = DecodingError.Context(
            codingPath: codingPath + [currentKey],
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
            codingPath: codingPath + [currentKey],
            debugDescription: info
        )
        throw DecodingError.typeMismatch(Swift.Decoder.self, context)
    }
}

// MARK: - Private Methods

private extension UnkeyedContainer {
    @inline(__always)
    func checkIsAtEnd<T>(_ type: T.Type) throws {
        guard !isAtEnd else {
            let info = "Unkeyed container is at end."
            let context = DecodingError.Context(
                codingPath: codingPath + [currentKey],
                debugDescription: info
            )
            throw DecodingError.valueNotFound(type, context)
        }
    }
}
