//
//  URLSessionSwizzer+Unswizzle.swift
//  DatadogTests_macOS
//
//  Created by Errol Cheong on 1/18/21.
//  Copyright © 2021 Datadog. All rights reserved.
//

import Foundation
@testable import Datadog

extension URLSessionSwizzler {
    func unswizzle() {
        dataTaskWithURL.unswizzle()
        dataTaskwithRequest.unswizzle()
        Self.resume.unswizzle()
        Self.resume = URLSessionSwizzler.Resume()
    }
}
