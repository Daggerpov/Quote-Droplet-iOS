//
//  InfoView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-21.
//

import SwiftUI
import Foundation
import StoreKit

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

@available(iOS 16.0, *)
struct InfoView: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    @StateObject var feedbackViewModel = FeedbackViewModel(apiService: APIService())

    @Environment(\.requestReview) var requestReview

    @State private var showMacAlert = false

    private var palette: AppPalette { sharedVars.palette }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                heroSection
                actionsSection
                aboutMeSection
            }
            .padding(.horizontal, AppMetrics.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .modifier(MainScreenBackgroundStyling())
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            sharedVars.reloadFromDefaults()
        }
        .sheet(isPresented: $feedbackViewModel.isSubmittingFeedback) {
            feedbackSubmissionView
                .environmentObject(sharedVars)
                .preferredColorScheme(palette.colorScheme)
        }
        // Both alerts live here: a legacy .alert(isPresented:) on this ancestor stopped the
        // Mac note's alert (previously attached to its button) from ever presenting
        .alert("Feedback Received", isPresented: $feedbackViewModel.showSubmissionReceivedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(feedbackViewModel.submissionMessage)
        }
        .alert("Note for Mac Owners", isPresented: $showMacAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You can actually add this same iOS widget to your Mac's widgets by clicking the date in the top-right corner of your Mac -> Edit Widgets.\n\nAlso, Quote Droplet has a Mac version available on the App Store. It conveniently shows quotes from a small icon in your menu bar, even offline.")
        }
    }
}


@available(iOS 16.0, *)
extension InfoView {
    private var heroSection: some View {
        VStack(spacing: 10) {
            Image(systemName: "drop.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundColor(palette.onAccent)
                .frame(width: 76, height: 76)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(LinearGradient(colors: [palette.accent, palette.accent.mixed(with: .black, amount: 0.18)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                )
                .shadow(color: palette.shadow, radius: 12, x: 0, y: 6)
            Text("Quote Droplet")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(palette.text)
            Text("Version \(Bundle.main.releaseVersionNumber ?? "Unknown")")
                .font(.subheadline)
                .foregroundColor(palette.secondaryText)
        }
        .padding(.top, 12)
    }

    private var actionsSection: some View {
        VStack(spacing: 0) {
            ShareLink(item: URL(string: "https://apps.apple.com/us/app/quote-droplet/id6455084603")!, message: Text("Check out this app, Quote Droplet.")) {
                SettingsRowLabel(icon: "square.and.arrow.up", title: "Share Quote Droplet") { RowChevron() }
            }
            .buttonStyle(PressableButtonStyle())
            RowDivider()
            Button(action: {
                requestReview()
            }) {
                SettingsRowLabel(icon: "star.fill", title: "Rate Quote Droplet") { RowChevron() }
            }
            .buttonStyle(PressableButtonStyle())
            RowDivider()
            Button(action: {
                feedbackViewModel.isSubmittingFeedback = true
            }) {
                SettingsRowLabel(icon: "bubble.left.fill", title: "Send Feedback", subtitle: "Bugs, ideas or quote corrections") { RowChevron() }
            }
            .buttonStyle(PressableButtonStyle())
            RowDivider()
            Button(action: {
                showMacAlert = true
            }) {
                SettingsRowLabel(icon: "laptopcomputer", title: "Note for Mac Owners") { RowChevron(systemName: "info.circle") }
            }
            .buttonStyle(PressableButtonStyle())
        }
        .modifier(CardStyling(padding: 16))
    }

    private var aboutMeSection: some View {
        VStack(spacing: 10) {
            SectionLabel(text: "Find me online")
            HStack(spacing: 0) {
                Spacer()
                buildLinkImage(urlForImage: "https://www.instagram.com/quote_droplet_app", imageName: "instagramlogo")
                Spacer()
                buildLinkImage(urlForImage: "https://www.linkedin.com/in/danielagapov/", imageName: "linkedinlogo")
                Spacer()
                buildLinkImage(urlForImage: "https://github.com/Daggerpov", imageName: "githublogo")
                Spacer()
                buildLinkImage(urlForImage: "mailto:danielagapov1@gmail.com?subject=Quote%20Droplet%20Contact", imageName: "gmaillogo", widthSpecified: 40)
                Spacer()
            }
            .modifier(CardStyling(padding: 16))
        }
    }

    private var feedbackSubmissionView: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Feedback Type", selection: $feedbackViewModel.feedbackType) {
                        Text("General").tag("General")
                        Text("Bug Report").tag("Bug Report")
                        Text("Feature Request").tag("Feature Request")
                        Text("Content").tag("Content")
                    }

                    TextField("What's on your mind?", text: $feedbackViewModel.feedbackText, axis: .vertical)
                        .lineLimit(5...10)
                } header: {
                    Text("Feedback")
                }
                .modifier(PaletteFormRowStyling())

                Section {
                    TextField("Email (optional)", text: $feedbackViewModel.contactEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Contact")
                } footer: {
                    Text("Only if you'd like a reply.")
                }
                .modifier(PaletteFormRowStyling())

                Section {
                    Button {
                        feedbackViewModel.submitFeedback()
                    } label: {
                        Text("Send Feedback")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle(palette: palette))
                    .disabled(feedbackViewModel.feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
            .modifier(PaletteFormStyling())
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        feedbackViewModel.isSubmittingFeedback = false
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        feedbackViewModel.showSubmissionInfoAlert = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("About feedback")
                }
            }
            .alert("About Feedback", isPresented: $feedbackViewModel.showSubmissionInfoAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your feedback helps me improve Quote Droplet. I personally review all feedback and take it into consideration for future updates.")
            }
        }
    }
}
