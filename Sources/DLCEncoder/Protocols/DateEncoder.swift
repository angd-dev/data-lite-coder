import Foundation

public protocol DateEncoder {
    func encode(_ date: Date, to encoder: any ValueEncoder) throws
    func encode(_ date: Date, for key: any CodingKey, to encoder: any RowEncoder) throws
}
