/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import Foundation

extension JSONEncoder {
    static func `default`() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            let formatted = iso8601DateFormatter.string(from: date)
            try container.encode(formatted)
        }
//        if #available(OSX 10.10, *) {
//            encoder.dateEncodingStrategy = dateEncodingStrategyMacOS()
//        }
        if #available(iOS 13.0, OSX 10.15, *) {
            encoder.outputFormatting = [.withoutEscapingSlashes]
        }
        return encoder
    }

//    private static func dateEncodingStrategyMacOS() -> JSONEncoder.DateEncodingStrategy {
//        let formatter: DateFormatterType
//        if #available(OSX 10.12, *) {
//            let isoformatter = ISO8601DateFormatter()
//            if #available(OSX 10.14, *) {
//                isoformatter.formatOptions.insert(.withFractionalSeconds)
//            }
//            formatter = isoformatter
//        } else {
//            formatter = iso8601DateFormatterMacOS()
//        }
//        return .custom { date, encoder in
//            var container = encoder.singleValueContainer()
//            let formatted = formatter.string(from: date)
//            try container.encode(formatted)
//        }
//    }
//    // Fallback for older macOS versions
//    private static func iso8601DateFormatterMacOS() -> DateFormatterType {
//        let formatter = DateFormatter()
//        formatter.calendar = Calendar(identifier: .iso8601)
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
//        return formatter
//    }
}
