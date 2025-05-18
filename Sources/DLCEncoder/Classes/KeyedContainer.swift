import Foundation
import DataLiteCore

private import DLCCommon

final class KeyedContainer<Encoder: RowEncoder, Key: CodingKey>: Container, KeyedEncodingContainerProtocol {
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
    
    func encodeNil(forKey key: Key) throws {
        try encoder.encodeNil(for: key)
    }
    
    func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        switch value {
        case let value as Date:
            try encoder.encodeDate(value, for: key)
        case let value as SQLiteRawBindable:
            try encoder.encode(value, for: key)
        default:
            let valueEncoder = try encoder.encoder(for: key)
            try value.encode(to: valueEncoder)
            try encoder.set(valueEncoder.sqliteData, for: key)
        }
    }
    
    func encodeIfPresent(_ value: Bool?, forKey key: Key) throws {
        switch value {
        case .some(let value):
            try encode(value, forKey: key)
        case .none:
            try encodeNil(forKey: key)
        }
    }
    
    func encodeIfPresent(_ value: String?, forKey key: Key) throws {
        switch value {
        case .some(let value):
            try encode(value, forKey: key)
        case .none:
            try encodeNil(forKey: key)
        }
    }
    
    func encodeIfPresent(_ value: Double?, forKey key: Key) throws {
        switch value {
        case .some(let value):
            try encode(value, forKey: key)
        case .none:
            try encodeNil(forKey: key)
        }
    }
    
    func encodeIfPresent(_ value: Float?, forKey key: Key) throws {
        switch value {
        case .some(let value):
            try encode(value, forKey: key)
        case .none:
            try encodeNil(forKey: key)
        }
    }
    
    func encodeIfPresent(_ value: Int?, forKey key: Key) throws {
        switch value {
        case .some(let value):
            try encode(value, forKey: key)
        case .none:
            try encodeNil(forKey: key)
        }
    }
    
    func encodeIfPresent(_ value: Int8?, forKey key: Key) throws {
        switch value {
        case .some(let value):
            try encode(value, forKey: key)
        case .none:
            try encodeNil(forKey: key)
        }
    }
    
    func encodeIfPresent(_ value: Int16?, forKey key: Key) throws {
        switch value {
        case .some(let value):
            try encode(value, forKey: key)
        case .none:
            try encodeNil(forKey: key)
        }
    }
    
    func encodeIfPresent(_ value: Int32?, forKey key: Key) throws {
        switch value {
        case .some(let value):
            try encode(value, forKey: key)
        case .none:
            try encodeNil(forKey: key)
        }
    }
    
    func encodeIfPresent(_ value: Int64?, forKey key: Key) throws {
        switch value {
        case .some(let value):
            try encode(value, forKey: key)
        case .none:
            try encodeNil(forKey: key)
        }
    }
    
    func encodeIfPresent(_ value: UInt?, forKey key: Key) throws {
        switch value {
        case .some(let value):
            try encode(value, forKey: key)
        case .none:
            try encodeNil(forKey: key)
        }
    }
    
    func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws {
        switch value {
        case .some(let value):
            try encode(value, forKey: key)
        case .none:
            try encodeNil(forKey: key)
        }
    }
    
    func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws {
        switch value {
        case .some(let value):
            try encode(value, forKey: key)
        case .none:
            try encodeNil(forKey: key)
        }
    }
    
    func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws {
        switch value {
        case .some(let value):
            try encode(value, forKey: key)
        case .none:
            try encodeNil(forKey: key)
        }
    }
    
    func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws {
        switch value {
        case .some(let value):
            try encode(value, forKey: key)
        case .none:
            try encodeNil(forKey: key)
        }
    }
    
    func encodeIfPresent<T: Encodable>(_ value: T?, forKey key: Key) throws {
        switch value {
        case .some(let value):
            try encode(value, forKey: key)
        case .none:
            try encodeNil(forKey: key)
        }
    }
    
    func nestedContainer<NestedKey: CodingKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey> {
        let container = FailedEncodingContainer<NestedKey>(
            codingPath: codingPath + [key]
        )
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer(
        forKey key: Key
    ) -> any UnkeyedEncodingContainer {
        FailedEncodingContainer<RowCodingKey>(
            codingPath: codingPath + [key]
        )
    }
    
    func superEncoder() -> any Swift.Encoder {
        FailedEncoder(codingPath: codingPath)
    }
    
    func superEncoder(forKey key: Key) -> any Swift.Encoder {
        FailedEncoder(codingPath: codingPath + [key])
    }
}
