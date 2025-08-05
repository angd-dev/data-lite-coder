import Foundation
import DataLiteCore

public protocol ValueEncoder: Encoder {
    func encodeNil() throws
    func encodeDate(_ date: Date) throws
    func encode<T: SQLiteRawBindable>(_ value: T) throws
}
