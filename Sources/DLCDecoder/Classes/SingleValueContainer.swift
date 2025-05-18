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
