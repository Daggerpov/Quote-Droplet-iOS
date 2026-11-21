//
//  SubmitView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-08.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct SubmitView: View {
    @StateObject var viewModel: SubmitViewModel = SubmitViewModel(apiService: APIService())
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs

    var body: some View {
        composeButton
            .sheet(isPresented: $viewModel.isAddingQuote) {
                quoteAddition
                    .environmentObject(sharedVars)
                    .preferredColorScheme(sharedVars.palette.colorScheme)
            }
            // Lives outside the sheet: the sheet closes as the submission finishes
            .alert("Submission Received", isPresented: $viewModel.showSubmissionReceivedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.submissionMessage)
            }
    }
}

@available(iOS 16.0, *)
extension SubmitView {
    private var composeButton: some View {
        Button(action: {
            viewModel.isAddingQuote = true
        }) {
            SubmitButtonView(text: "Submit a Quote", imageSystemName: "square.and.pencil")
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var canSubmit: Bool {
        !viewModel.quoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var quoteAddition: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Quote text", text: $viewModel.quoteText, axis: .vertical)
                        .lineLimit(3...8)
                        .font(.system(.body, design: .serif))
                    TextField("Author", text: $viewModel.author)
                    submissionQuoteCategoryPicker
                } header: {
                    Text("Quote")
                } footer: {
                    Text("Don't worry about typos or a missing author or category: I review every submission and can fill those in.")
                }
                .modifier(PaletteFormRowStyling())

                Section {
                    TextField("Your name or alias (optional)", text: $viewModel.submitterName)
                } header: {
                    Text("Credit")
                } footer: {
                    Text("Shown with the quote once it's approved.")
                }
                .modifier(PaletteFormRowStyling())

                Section {
                    Button {
                        Task {
                            await viewModel.addQuote()
                        }
                    } label: {
                        Text("Submit Quote")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle(palette: sharedVars.palette))
                    .disabled(!canSubmit)
                    .opacity(canSubmit ? 1 : 0.5)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
            .modifier(PaletteFormStyling())
            .navigationTitle("Submit a Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.isAddingQuote = false
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showSubmissionInfoAlert = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("How this works")
                }
            }
            .alert("How Quote Submission Works", isPresented: $viewModel.showSubmissionInfoAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Submitted quotes will either be approved to be added into the app's quote database, or dismissed.\n\nI'll be able to edit typos or insert missing fields, such as author and classification, so don't worry about this when submitting.")
            }
        }
    }

    private var submissionQuoteCategoryPicker: some View {
        Picker("Category", selection: $viewModel.selectedCategory) {
            // .all (shown as "Unsure") first, without the on-device Saved and Custom categories
            ForEach([.all] + QuoteCategory.remoteCases.filter { $0 != .all }, id: \.self) { category in
                Text(category == .all ? "Unsure" : category.rawValue)
            }
        }
    }
}
