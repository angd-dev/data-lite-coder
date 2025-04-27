import Foundation
internal import DLCDecoder

extension RowDecoder {
    class DateDecoder: DLCDecoder.DateDecoder {
        typealias ValueDecoder = DLCDecoder.ValueDecoder
        typealias RowDecoder = DLCDecoder.RowDecoder
        
        let strategy: DateDecodingStrategy
        
        init(strategy: DateDecodingStrategy) {
            self.strategy = strategy
        }
        
        func decode(
            from decoder: any ValueDecoder
        ) throws -> Date {
            try decode(from: decoder) { decoder in
                try decoder.decode(Date.self)
            } _: { decoder in
                try decoder.decode(String.self)
            } _: { decoder in
                try decoder.decode(Int64.self)
            } _: { decoder in
                try decoder.decode(Double.self)
            }
        }
        
        func decode(
            from decoder: any RowDecoder,
            for key: any CodingKey
        ) throws -> Date {
            try decode(from: decoder) { decoder in
                try decoder.decode(Date.self, for: key)
            } _: { decoder in
                try decoder.decode(String.self, for: key)
            } _: { decoder in
                try decoder.decode(Int64.self, for: key)
            } _: { decoder in
                try decoder.decode(Double.self, for: key)
            }
        }
        
        private func decode<D: Decoder>(
            from decoder: D,
            _ date: (D) throws -> Date,
            _ string: (D) throws -> String,
            _ int: (D) throws -> Int64,
            _ double: (D) throws -> Double
        ) throws -> Date {
            switch strategy {
            case .deferredToDate:
                return try date(decoder)
            case .formatted(let dateFormatter):
                guard
                    let date = dateFormatter.date(
                        from: try string(decoder)
                    )
                else {
                    let info = "Date string does not match format expected by formatter."
                    let context = DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: info
                    )
                    throw DecodingError.dataCorrupted(context)
                }
                return date
            case .millisecondsSince1970Int:
                let milliseconds = Double(try int(decoder))
                return Date(timeIntervalSince1970: milliseconds / 1000)
            case .millisecondsSince1970Double:
                let milliseconds = try double(decoder)
                return Date(timeIntervalSince1970: milliseconds / 1000)
            case .secondsSince1970Int:
                let seconds = Double(try int(decoder))
                return Date(timeIntervalSince1970: seconds)
            case .secondsSince1970Double:
                let seconds = try double(decoder)
                return Date(timeIntervalSince1970: seconds)
            }
        }
    }
}
