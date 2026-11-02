//
//  Submission.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2026-11-02.
//

import Foundation

enum SubmissionStatus: String {
    case pending
    case approved
    case rejected

    var displayName: String {
        switch self {
            case .pending: return "Awaiting Approval"
            case .approved: return "Approved"
            case .rejected: return "Not Approved"
        }
    }

    var imageSystemName: String {
        switch self {
            case .pending: return "clock"
            case .approved: return "checkmark.circle"
            case .rejected: return "xmark.circle"
        }
    }
}

// A quote the user submitted, as returned by GET /quotes/submissions
struct Submission: Codable, Identifiable, Equatable {
    let id: Int
    let text: String
    let author: String?
    let classification: String?
    let likes: Int?
    let status: String
    let createdAt: String?

    var submissionStatus: SubmissionStatus {
        SubmissionStatus(rawValue: status) ?? .pending
    }

    var submittedDate: Date? {
        APIDateParser.date(from: createdAt)
    }
}

extension Submission {
    static func mockSubmission(id: Int = 0, status: SubmissionStatus = .pending) -> Submission {
        return Submission(
            id: id,
            text: "He who has a why to live can bear almost any how.",
            author: "Friedrich Nietzsche",
            classification: "philosophy",
            likes: 0,
            status: status.rawValue,
            createdAt: "2026-11-02T12:00:00.123456Z"
        )
    }
}
