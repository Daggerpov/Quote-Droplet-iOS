//
//  SubmissionsView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2026-11-02.
//

import SwiftUI

@available(iOS 16.0, *)
struct SubmissionsView: View {
    @StateObject var viewModel: SubmissionsViewModel = SubmissionsViewModel(apiService: APIService())
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Quotes you've submitted from this device, and whether they've been approved yet.")
                    .font(.subheadline)
                    .foregroundColor(sharedVars.palette.secondaryText)
                    .padding(.horizontal, 4)
                submissionsSection
            }
            .padding(.horizontal, AppMetrics.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .modifier(MainScreenBackgroundStyling())
        .navigationTitle("My Submissions")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await viewModel.getSubmissions()
        }
        .task {
            await viewModel.getSubmissions()
        }
    }
}

@available(iOS 16.0, *)
struct SubmissionsView_Previews: PreviewProvider {
    static var previews: some View {
        SubmissionsView()
            .environmentObject(SharedVarsBetweenTabs())
    }
}

@available(iOS 16.0, *)
extension SubmissionsView {
    private var palette: AppPalette { sharedVars.palette }

    private var submissionsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.submissions.isEmpty {
                Group {
                    if viewModel.isLoading {
                        HStack(spacing: 10) {
                            ProgressView().tint(palette.accent)
                            Text("Loading submissions…")
                        }
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                    } else {
                        Text("You haven't submitted any quotes from this device yet. Quotes you submit will show up here along with their approval status.")
                    }
                }
                .font(.body)
                .foregroundColor(palette.text)
                .padding(.vertical, 6)
            } else {
                ForEach(viewModel.submissions) { submission in
                    submissionRow(submission)
                    if submission != viewModel.submissions.last {
                        Rectangle().fill(palette.hairline).frame(height: 1)
                    }
                }
            }
        }
        .modifier(CardStyling(padding: 18))
    }

    private func submissionRow(_ submission: Submission) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(submission.text)
                .modifier(QuoteTextStyling(font: .system(.body, design: .serif)))

            if let author = submission.author, isAuthorValid(authorGiven: submission.author) {
                HStack {
                    Spacer()
                    Text("— \(author)")
                        .modifier(AuthorTextStyling())
                }
            }

            HStack {
                statusBadge(submission.submissionStatus)
                Spacer()
                if let date = submission.submittedDate {
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(palette.secondaryText)
                }
            }
        }
        .padding(.vertical, 14)
    }

    private func statusBadge(_ status: SubmissionStatus) -> some View {
        let isApproved = status == .approved
        return HStack(spacing: 4) {
            Image(systemName: status.imageSystemName)
            Text(status.displayName)
        }
        .font(.caption.bold())
        .foregroundColor(isApproved ? palette.onAccent : palette.accent)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(isApproved ? palette.accent : palette.accent.opacity(0.14)))
    }
}
