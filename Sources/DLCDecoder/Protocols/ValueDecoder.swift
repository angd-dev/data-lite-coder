import Foundation
import DataLiteCore

package protocol ValueDecoder: Decoder {
    func decodeNil() -> Bool
    func decodeDate() throws -> Date
    func decode<T: SQLiteRepresentable>(_ type: T.Type) throws -> T
}
