import Foundation
private import DLCCommon

final class FailedEncodingContainer<Key: CodingKey>: SingleValueEncodingContainer, UnkeyedEncodingContainer, KeyedEncodingContainerProtocol {
    // MARK: - Properties
    
    let codingPath: [any CodingKey]
    let count: Int = 0
    
    // MARK: - Inits
    
    init(codingPath: [any CodingKey]) {
        self.codingPath = codingPath
    }
    
    // MARK: - Methods
    
    func encodeNil() throws {
        throw encodingError(codingPath: codingPath)
    }
    
    func encodeNil(forKey key: Key) throws {
        throw encodingError(codingPath: codingPath + [key])
    }
    
    func encode<T: Encodable>(_ value: T) throws {
        throw encodingError(codingPath: codingPath)
    }
    
    func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        throw encodingError(codingPath: codingPath + [key])
    }
    
    func nestedContainer<NestedKey: CodingKey>(
        keyedBy keyType: NestedKey.Type
    ) -> KeyedEncodingContainer<NestedKey> {
        let container = FailedEncodingContainer<NestedKey>(
            codingPath: codingPath
        )
        return KeyedEncodingContainer(container)
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
    
    func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
        FailedEncodingContainer<RowCodingKey>(codingPath: codingPath)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
        FailedEncodingContainer<RowCodingKey>(codingPath: codingPath + [key])
    }
    
    func superEncoder() -> any Swift.Encoder {
        FailedEncoder(codingPath: codingPath)
    }
    
    func superEncoder(forKey key: Key) -> any Swift.Encoder {
        FailedEncoder(codingPath: codingPath + [key])
    }
}

// MARK: - Private

private extension FailedEncodingContainer {
    func encodingError(
        _ function: String = #function,
        codingPath: [any CodingKey]
    ) -> Error {
        let info = "\(function) is not supported for this encoding path."
        let context = EncodingError.Context(
            codingPath: codingPath,
            debugDescription: info
        )
        return EncodingError.invalidValue((), context)
    }
}
