import Foundation

protocol KeyCheckingDecoder: Decoder {
    func contains(_ key: CodingKey) -> Bool
}
