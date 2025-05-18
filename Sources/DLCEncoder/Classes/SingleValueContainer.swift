import Foundation
import DataLiteCore

final class SingleValueContainer<Encoder: ValueEncoder>: Container, SingleValueEncodingContainer {
    // MARK: - Properties
    
    let encoder: Encoder
    let codingPath: [any CodingKey]
    
    // MARK: - Inits
    
    init(
        encoder: Encoder,
        codingPath: [any CodingKey]
    ) {
        self.encoder = encoder
        self.codingPath = codingPath
    }
    
    // MARK: - Container Methods
    
    func encodeNil() throws {
        try encoder.encodeNil()
    }
    
    func encode<T: Encodable>(_ value: T) throws {
        switch value {
        case let value as Date:
            try encoder.encodeDate(value)
        case let value as SQLiteRawBindable:
            try encoder.encode(value)
        default:
            try value.encode(to: encoder)
        }
    }
}
