import Foundation
import DataLiteCore

protocol ValueDecoder: Decoder {
    func decodeNil() -> Bool
    func decodeDate() throws -> Date
    func decode<T: SQLiteRawRepresentable>(_ type: T.Type) throws -> T
}
