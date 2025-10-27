import Foundation
import DataLiteCore

package protocol ValueEncoder: Encoder {
    func encodeNil() throws
    func encodeDate(_ date: Date) throws
    func encode<T: SQLiteBindable>(_ value: T) throws
}
