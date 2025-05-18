import Foundation

private import DLCCommon

final class FailedEncoder: Swift.Encoder {
    // MARK: - Properties
    
    let codingPath: [any CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    
    // MARK: - Inits
    
    init(
        codingPath: [any CodingKey],
        userInfo: [CodingUserInfoKey: Any] = [:]
    ) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    // MARK: - Methods
    
    func container<Key: CodingKey>(
        keyedBy type: Key.Type
    ) -> KeyedEncodingContainer<Key> {
        let container = FailedEncodingContainer<Key>(codingPath: codingPath)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> any UnkeyedEncodingContainer {
        FailedEncodingContainer<RowCodingKey>(codingPath: codingPath)
    }
    
    func singleValueContainer() -> any SingleValueEncodingContainer {
        FailedEncodingContainer<RowCodingKey>(codingPath: codingPath)
    }
}
