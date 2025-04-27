import Foundation

protocol Decoder: Swift.Decoder {
    associatedtype SQLiteData
    var dateDecoder: any DateDecoder { get }
    var sqliteData: SQLiteData { get }
}
