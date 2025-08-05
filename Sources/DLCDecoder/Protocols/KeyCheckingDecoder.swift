import Foundation

public protocol KeyCheckingDecoder: Decoder {
    func contains(_ key: CodingKey) -> Bool
}
