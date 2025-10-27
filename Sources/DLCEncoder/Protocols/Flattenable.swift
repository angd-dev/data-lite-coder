import Foundation

protocol Flattenable {
    func flattened() -> Any?
}

extension Optional: Flattenable {
    func flattened() -> Any? {
        switch self {
        case .some(let x as Flattenable): x.flattened()
        case .some(let x): x
        case .none: nil
        }
    }
}
