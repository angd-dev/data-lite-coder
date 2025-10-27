import Foundation

package protocol KeyCheckingDecoder: Decoder {
    func contains(_ key: CodingKey) -> Bool
}
