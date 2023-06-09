/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import XCTest
@testable import Datadog

class W3CHTTPHeadersReaderTests: XCTestCase {
    func testW3CHTTPHeadersReaderreadsSingleHeader() {
        let w3cHTTPHeadersReader = W3CHTTPHeadersReader(httpHeaderFields: ["traceparent": "00-4d2-929-01"])
        w3cHTTPHeadersReader.use(baggageItemQueue: .main)

        let spanContext = w3cHTTPHeadersReader.extract()?.dd

        XCTAssertEqual(spanContext?.traceID, TracingUUID(rawValue: 1_234))
        XCTAssertEqual(spanContext?.spanID, TracingUUID(rawValue: 2_345))
        XCTAssertNil(spanContext?.parentSpanID)
    }

    func testW3CHTTPHeadersReaderreadsSingleHeaderWithSampling() {
        let w3cHTTPHeadersReader = W3CHTTPHeadersReader(httpHeaderFields: ["traceparent": "00-0-0-00"])
        w3cHTTPHeadersReader.use(baggageItemQueue: .main)

        let spanContext = w3cHTTPHeadersReader.extract()?.dd

        XCTAssertNil(spanContext?.traceID)
        XCTAssertNil(spanContext?.spanID)
        XCTAssertNil(spanContext?.parentSpanID)
    }
}
