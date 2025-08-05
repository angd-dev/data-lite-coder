import Foundation
import DataLiteCore

public protocol RowEncoder: Encoder {
    var count: Int { get }
    
    func set(_ value: Any, for key: CodingKey) throws
    func encodeNil(for key: CodingKey) throws
    func encodeDate(_ date: Date, for key: CodingKey) throws
    func encode<T: SQLiteRawBindable>(_ value: T, for key: CodingKey) throws
    func encoder(for key: CodingKey) throws -> any Encoder
}
