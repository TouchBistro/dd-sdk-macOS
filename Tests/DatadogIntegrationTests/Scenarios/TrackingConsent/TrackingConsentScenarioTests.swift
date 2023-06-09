/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import HTTPServerMock
import XCTest

private class TSHomeScreen: XCUIApplication {
    func tapTestLogging() {
        buttons["Test Logging"].tap()
    }

    func tapTestTracing() {
        buttons["Test Tracing"].tap()
    }

    func tapTestRUM() -> TSPictureScreen {
        buttons["Test RUM"].tap()
        return TSPictureScreen()
    }

    func tapChangeConsent() -> TSConsentSettingsScreen {
        buttons["CHANGE"].tap()
        return TSConsentSettingsScreen()
    }
}

private class TSPictureScreen: XCUIApplication {
    func tapDownloadImage() {
        buttons["Download image"].tap()
    }

    func waitForImageBeingDownloaded() {
        _ = staticTexts["☑️"].waitForExistence(timeout: 10)
    }

    func tapBack() -> TSHomeScreen {
        navigationBars["Example.TSPictureView"].buttons["Back"].tap()
        return TSHomeScreen()
    }
}

private class TSConsentSettingsScreen: XCUIApplication {
    func selectConsent(value: String) {
        buttons[value].safeTap()
    }

    func tapClose() -> TSHomeScreen {
        buttons["close"].tap()
        return TSHomeScreen()
    }
}

class TrackingConsentScenarioTests: IntegrationTests, LoggingCommonAsserts, TracingCommonAsserts, RUMCommonAsserts {
    func testStartWithPendingConsent_thenPlayScenario_thenChangeConsentToGranted() throws {
        let loggingServerSession = server.obtainUniqueRecordingSession()
        let tracingServerSession = server.obtainUniqueRecordingSession()
        let rumServerSession = server.obtainUniqueRecordingSession()

        let app = ExampleApplication()
        app.launchWith(
            testScenarioClassName: "TrackingConsentStartPendingScenario",
            serverConfiguration: HTTPServerMockConfiguration(
                logsEndpoint: loggingServerSession.recordingURL,
                tracesEndpoint: tracingServerSession.recordingURL,
                rumEndpoint: rumServerSession.recordingURL
            )
        )

        playScenarioWithChangingConsent(to: "granted")

        try assertLoggingDataWasCollected(withConsent: "pending", andSentTo: loggingServerSession)
        try assertTracingDataWasCollected(withConsent: "pending", andSentTo: tracingServerSession)
        try assertRUMDataWasCollected(withConsent: "pending", andSentTo: rumServerSession)
    }

    func testStartWithGrantedConsent_thenPlayScenario_thenChangeConsentToPending() throws {
        let loggingServerSession = server.obtainUniqueRecordingSession()
        let tracingServerSession = server.obtainUniqueRecordingSession()
        let rumServerSession = server.obtainUniqueRecordingSession()

        let app = ExampleApplication()
        app.launchWith(
            testScenarioClassName: "TrackingConsentStartGrantedScenario",
            serverConfiguration: HTTPServerMockConfiguration(
                logsEndpoint: loggingServerSession.recordingURL,
                tracesEndpoint: tracingServerSession.recordingURL,
                rumEndpoint: rumServerSession.recordingURL
            )
        )

        playScenarioWithChangingConsent(to: "pending")

        try assertLoggingDataWasCollected(withConsent: "granted", andSentTo: loggingServerSession)
        try assertTracingDataWasCollected(withConsent: "granted", andSentTo: tracingServerSession)
        try assertRUMDataWasCollected(withConsent: "granted", andSentTo: rumServerSession)
    }

    func testStartWithPendingConsent_thenPlayScenario_thenChangeConsentToNotGranted() throws {
        let loggingServerSession = server.obtainUniqueRecordingSession()
        let tracingServerSession = server.obtainUniqueRecordingSession()
        let rumServerSession = server.obtainUniqueRecordingSession()

        let app = ExampleApplication()
        app.launchWith(
            testScenarioClassName: "TrackingConsentStartPendingScenario",
            serverConfiguration: HTTPServerMockConfiguration(
                logsEndpoint: loggingServerSession.recordingURL,
                tracesEndpoint: tracingServerSession.recordingURL,
                rumEndpoint: rumServerSession.recordingURL
            )
        )

        playScenarioWithChangingConsent(to: "not granted")

        Thread.sleep(forTimeInterval: dataDeliveryTimeout)

        let recordedLoggingRequests = try loggingServerSession.getRecordedRequests()
        XCTAssertEqual(recordedLoggingRequests.count, 0, "No logging data should be send.")
        let recordedTracingRequests = try loggingServerSession.getRecordedRequests()
        XCTAssertEqual(recordedTracingRequests.count, 0, "No tracing data should be send.")
        let recordedRUMRequests = try rumServerSession.getRecordedRequests()
        XCTAssertEqual(recordedRUMRequests.count, 0, "No RUM data should be send.")
    }

    func testStartWithGrantedConsent_thenPlayScenario_thenRestartTheAppWithConsentPending() throws {
        let loggingServerSession = server.obtainUniqueRecordingSession()
        let tracingServerSession = server.obtainUniqueRecordingSession()
        let rumServerSession = server.obtainUniqueRecordingSession()

        let app = ExampleApplication()
        app.launchWith(
            testScenarioClassName: "TrackingConsentStartGrantedScenario",
            serverConfiguration: HTTPServerMockConfiguration(
                logsEndpoint: loggingServerSession.recordingURL,
                tracesEndpoint: tracingServerSession.recordingURL,
                rumEndpoint: rumServerSession.recordingURL
            )
        )

        playScenarioWithChangingConsent(to: "pending")

        app.terminate()

        app.launchWith(
            testScenarioClassName: "TrackingConsentStartPendingScenario",
            serverConfiguration: HTTPServerMockConfiguration(
                logsEndpoint: loggingServerSession.recordingURL,
                tracesEndpoint: tracingServerSession.recordingURL,
                rumEndpoint: rumServerSession.recordingURL
            ),
            clearPersistentData: false // do not clear data from previous session
        )

        try assertLoggingDataWasCollected(withConsent: "granted", andSentTo: loggingServerSession)
        try assertTracingDataWasCollected(withConsent: "granted", andSentTo: tracingServerSession)
        try assertRUMDataWasCollected(withConsent: "granted", andSentTo: rumServerSession)
    }

    func testStartWithPendingConsent_thenPlayScenario_thenRestartTheAppWithConsentGranted() throws {
        let loggingServerSession = server.obtainUniqueRecordingSession()
        let tracingServerSession = server.obtainUniqueRecordingSession()
        let rumServerSession = server.obtainUniqueRecordingSession()

        let app = ExampleApplication()
        app.launchWith(
            testScenarioClassName: "TrackingConsentStartPendingScenario",
            serverConfiguration: HTTPServerMockConfiguration(
                logsEndpoint: loggingServerSession.recordingURL,
                tracesEndpoint: tracingServerSession.recordingURL,
                rumEndpoint: rumServerSession.recordingURL
            )
        )

        playScenarioWithChangingConsent(to: "pending")

        app.terminate()

        app.launchWith(
            testScenarioClassName: "TrackingConsentStartGrantedScenario",
            serverConfiguration: HTTPServerMockConfiguration(
                logsEndpoint: loggingServerSession.recordingURL,
                tracesEndpoint: tracingServerSession.recordingURL,
                rumEndpoint: rumServerSession.recordingURL
            ),
            clearPersistentData: false // do not clear data from previous session
        )

        // Because the app was restarted with consent `.granted`, we expect data
        // from this session to be send, but no RUM, Logging nor Tracing events from the first
        // session should be recorded.
        let recordedRUMRequests = try rumServerSession.pullRecordedRequests(timeout: dataDeliveryTimeout) { requests in
            try RUMSessionMatcher.singleSession(from: requests)?.viewVisits.count == 1
        }

        assertRUM(requests: recordedRUMRequests)

        let session = try XCTUnwrap(RUMSessionMatcher.singleSession(from: recordedRUMRequests))
        XCTAssertEqual(session.viewVisits.count, 1)
        XCTAssertEqual(session.viewVisits[0].path, "Example.TSHomeViewController")

        try recordedRUMRequests
            .flatMap { request in try RUMEventMatcher.fromNewlineSeparatedJSONObjectsData(request.httpBody) }
            .filter { event in try event.eventType() != "telemetry" }
            .forEach { event in
                XCTAssertEqual(
                    try event.attribute(forKeyPath: "usr.current-consent-value"),
                    "GRANTED"
                )
            }

        let recordedLoggingRequests = try loggingServerSession.getRecordedRequests()
        XCTAssertEqual(recordedLoggingRequests.count, 0)
        let recordedTracingRequests = try loggingServerSession.getRecordedRequests()
        XCTAssertEqual(recordedTracingRequests.count, 0)
    }

    /// Plays following scenario for started application:
    /// * sends log and trace from home screen,
    /// * goes to picture screen and downloads the image,
    /// * goes back to the home screen,
    /// * goes to the consent settings screen,
    /// * changes the consent to given `value`,
    private func playScenarioWithChangingConsent(to value: String) {
        var homeScreen = TSHomeScreen()
        homeScreen.tapTestLogging()
        homeScreen.tapTestTracing()
        let pictureScreen = homeScreen.tapTestRUM()
        pictureScreen.tapDownloadImage()
        pictureScreen.waitForImageBeingDownloaded()
        homeScreen = pictureScreen.tapBack()
        let consentSettingsScreen = homeScreen.tapChangeConsent()
        consentSettingsScreen.selectConsent(value: value)
    }

    // MARK: - Data assertions

    private func assertLoggingDataWasCollected(
        withConsent expectedConsentValue: String,
        andSentTo serverSession: ServerSession
    ) throws {
        let recordedRequests = try serverSession.pullRecordedRequests(timeout: dataDeliveryTimeout) { requests in
            try LogMatcher.from(requests: requests).count == 1
        }

        assertLogging(requests: recordedRequests)

        let logMatchers = try LogMatcher.from(requests: recordedRequests)
        XCTAssertEqual(logMatchers.count, 1)
        let logMatcher = logMatchers[0]
        logMatcher.assertMessage(equals: "test message")
        logMatcher.assertStatus(equals: "info")

        XCTAssertEqual(
            try logMatcher.value(forKeyPath: "usr.current-consent-value"),
            expectedConsentValue.uppercased()
        )
    }

    private func assertTracingDataWasCollected(
        withConsent expectedConsentValue: String,
        andSentTo serverSession: ServerSession
    ) throws {
        let recordedRequests = try serverSession.pullRecordedRequests(timeout: dataDeliveryTimeout) { requests in
            try SpanMatcher.from(requests: requests).count == 1
        }

        assertTracing(requests: recordedRequests)

        let spanMatchers = try SpanMatcher.from(requests: recordedRequests)
        XCTAssertEqual(spanMatchers.count, 1)
        let spanMatcher = spanMatchers[0]
        XCTAssertEqual(try spanMatcher.operationName(), "test span")

        XCTAssertEqual(
            try spanMatcher.meta.custom(keyPath: "meta.usr.current-consent-value"),
            expectedConsentValue.uppercased()
        )
    }

    private func assertRUMDataWasCollected(
        withConsent expectedConsentValue: String,
        andSentTo serverSession: ServerSession
    ) throws {
        let recordedRequests = try serverSession.pullRecordedRequests(timeout: dataDeliveryTimeout) { requests in
            try RUMSessionMatcher.singleSession(from: requests)?.viewVisits.count == 4
        }

        assertRUM(requests: recordedRequests)

        let session = try XCTUnwrap(RUMSessionMatcher.singleSession(from: recordedRequests))
        XCTAssertEqual(session.viewVisits[0].path, "Example.TSHomeViewController")
        XCTAssertGreaterThan(session.viewVisits[0].actionEvents.count, 0)

        XCTAssertEqual(session.viewVisits[1].path, "Example.TSPictureViewController")
        XCTAssertEqual(session.viewVisits[1].resourceEvents.count, 1)
        XCTAssertGreaterThan(session.viewVisits[1].actionEvents.count, 0)

        XCTAssertEqual(session.viewVisits[2].path, "Example.TSHomeViewController")
        XCTAssertGreaterThan(session.viewVisits[0].actionEvents.count, 0)

        XCTAssertEqual(session.viewVisits[3].path, "Example.TSConsentSettingViewController")
        XCTAssertGreaterThan(session.viewVisits[0].actionEvents.count, 0)

        let eventMatchers = try recordedRequests
            .flatMap { request in try RUMEventMatcher.fromNewlineSeparatedJSONObjectsData(request.httpBody) }
            .filter { event in try event.eventType() != "telemetry" }

        try eventMatchers.forEach { event in
            XCTAssertEqual(
                try event.attribute(forKeyPath: "usr.current-consent-value"),
                expectedConsentValue.uppercased()
            )
        }
    }
}
