//
//  SubmissionsViewModel_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2026-11-02.
//

import Testing
@testable import Quote_Droplet
import Foundation

@Suite("Submissions View Model Tests", .serialized) final class SubmissionsViewModel_Tests {

    let mockAPIService: MockAPIService
    let sut: SubmissionsViewModel

    init() {
        self.mockAPIService = MockAPIService()
        self.sut = SubmissionsViewModel(apiService: mockAPIService, submitterID: "test-submitter-id")
    }

    @Test func getSubmissions_success() async throws {
        let mockSubmissions = [
            Submission.mockSubmission(id: 1, status: .pending),
            Submission.mockSubmission(id: 2, status: .approved),
            Submission.mockSubmission(id: 3, status: .rejected)
        ]
        mockAPIService.setSubmissionsResponse(submissions: mockSubmissions, error: nil)

        await sut.getSubmissions()

        #expect(mockAPIService.lastSubmitterID == "test-submitter-id")
        #expect(sut.submissions == mockSubmissions)
        #expect(sut.errorMessage == nil)
        #expect(sut.isLoading == false)
    }

    @Test func getSubmissions_failure() async throws {
        let mockError = NSError(domain: "TestError", code: 500, userInfo: nil)
        mockAPIService.setSubmissionsResponse(submissions: nil, error: mockError)

        await sut.getSubmissions()

        #expect(sut.submissions.isEmpty)
        #expect(sut.errorMessage != nil)
        #expect(sut.isLoading == false)
    }

    @Test func submission_parsesStatusAndDate() {
        let submission = Submission.mockSubmission(status: .approved)
        #expect(submission.submissionStatus == .approved)
        #expect(submission.submittedDate != nil)

        let unknown = Submission(id: 0, text: "", author: nil, classification: nil, likes: nil, status: "something-new", createdAt: "2026-11-02T12:00:00Z")
        #expect(unknown.submissionStatus == .pending)
        #expect(unknown.submittedDate != nil)
    }
}
