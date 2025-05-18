import Foundation
import DataLiteCore

public protocol RowDecoder: Decoder {
    var count: Int? { get }
    
    func decodeNil(for key: CodingKey) throws -> Bool
    func decodeDate(for key: CodingKey) throws -> Date
    func decode<T: SQLiteRawRepresentable>(_ type: T.Type, for key: CodingKey) throws -> T
    func decoder(for key: CodingKey) throws -> any Decoder
}
