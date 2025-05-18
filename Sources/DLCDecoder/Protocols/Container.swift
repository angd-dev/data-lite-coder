import Foundation

protocol Container {
    associatedtype Decoder: Swift.Decoder
    var decoder: Decoder { get }
}
