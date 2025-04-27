import Foundation
import DataLiteCore

private import DLCCommon

final class UnkeyedContainer<Encoder: RowEncoder>: Container, UnkeyedEncodingContainer {
    // MARK: - Properties
    
    let encoder: Encoder
    let codingPath: [any CodingKey]
    var count: Int { encoder.count }
    
    private var currentKey: CodingKey {
        RowCodingKey(intValue: count)
    }
    
    // MARK: - Inits
    
    init(encoder: Encoder, codingPath: [any CodingKey]) {
        self.encoder = encoder
        self.codingPath = codingPath
    }
    
    // MARK: - Container Methods
    
    func encodeNil() throws {
    }
    
    func encode<T: Encodable>(_ value: T) throws {
        if let value = value as? Flattenable {
            if let value = value.flattened() as? Encodable {
                try encode(value)
            } else {
                try encodeNil()
            }
        } else {
            let valueEncoder = try encoder.encoder(for: currentKey)
            try value.encode(to: valueEncoder)
            try encoder.set(valueEncoder.sqliteData, for: currentKey)
        }
    }
    
    func nestedContainer<NestedKey: CodingKey>(
        keyedBy keyType: NestedKey.Type
    ) -> KeyedEncodingContainer<NestedKey> {
        let container = FailedEncodingContainer<NestedKey>(
            codingPath: codingPath
        )
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
        FailedEncodingContainer<RowCodingKey>(codingPath: codingPath)
    }
    
    func superEncoder() -> any Swift.Encoder {
        FailedEncoder(codingPath: codingPath)
    }
}
