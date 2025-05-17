import Foundation
import DataLiteCore

internal import DLCEncoder

extension RowEncoder {
    class DateEncoder: DLCEncoder.DateEncoder {
        typealias ValueEncoder = DLCEncoder.ValueEncoder
        typealias RowEncoder = DLCEncoder.RowEncoder
        
        let strategy: DateEncodingStrategy
        
        init(strategy: DateEncodingStrategy) {
            self.strategy = strategy
        }
        
        func encode(
            _ date: Date,
            to encoder: any ValueEncoder
        ) throws {
            let value = encodeValue(from: date)
            try encoder.encode(value)
        }
        
        func encode(
            _ date: Date,
            for key: any CodingKey,
            to encoder: any RowEncoder
        ) throws {
            let value = encodeValue(from: date)
            try encoder.encode(value, for: key)
        }
        
        private func encodeValue(from date: Date) -> SQLiteRawBindable {
            switch strategy {
            case .deferredToDate:
                date
            case .formatted(let dateFormatter):
                dateFormatter.string(from: date)
            case .millisecondsSince1970Int:
                Int64(date.timeIntervalSince1970 * 1000)
            case .millisecondsSince1970Double:
                date.timeIntervalSince1970 * 1000
            case .secondsSince1970Int:
                Int64(date.timeIntervalSince1970)
            case .secondsSince1970Double:
                date.timeIntervalSince1970
            }
        }
    }
}
