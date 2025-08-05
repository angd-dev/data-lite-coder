import Foundation

public protocol DateDecoder {
    func decode(from decoder: any ValueDecoder) throws -> Date
    func decode(from decoder: any RowDecoder, for key: any CodingKey) throws -> Date
}
