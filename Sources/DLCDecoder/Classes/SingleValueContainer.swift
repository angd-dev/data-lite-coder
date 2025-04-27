import Foundation
import DataLiteCore

final class SingleValueContainer<Decoder: ValueDecoder>: Container, SingleValueDecodingContainer {
    // MARK: - Properties
    
    let decoder: Decoder
    let codingPath: [any CodingKey]
    
    // MARK: - Inits
    
    init(
        decoder: Decoder,
        codingPath: [any CodingKey]
    ) {
        self.decoder = decoder
        self.codingPath = codingPath
    }
    
    // MARK: - Container Methods
    
    func decodeNil() -> Bool {
        decoder.decodeNil()
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        try decoder.decode(type)
    }
    
    func decode(_ type: String.Type) throws -> String {
        try decoder.decode(type)
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        try decoder.decode(type)
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        try decoder.decode(type)
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        try decoder.decode(type)
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        try decoder.decode(type)
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        try decoder.decode(type)
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        try decoder.decode(type)
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        try decoder.decode(type)
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        try decoder.decode(type)
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try decoder.decode(type)
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try decoder.decode(type)
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try decoder.decode(type)
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try decoder.decode(type)
    }
    
    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        switch type {
        case is Date.Type:
            try decoder.decodeDate() as! T
        case let type as SQLiteRawRepresentable.Type:
            try decoder.decode(type) as! T
        default:
            try T(from: decoder)
        }
    }
}
