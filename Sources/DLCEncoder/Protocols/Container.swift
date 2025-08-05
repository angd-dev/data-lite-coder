import Foundation

protocol Container {
    associatedtype Encoder: Swift.Encoder
    var encoder: Encoder { get }
}
