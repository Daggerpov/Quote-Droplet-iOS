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
        VStack{
            composeButton
        }.sheet(isPresented: $viewModel.isAddingQuote) {
            quoteAddition
        }
    }
}

@available(iOS 16.0, *)
extension SubmitView {
    private var composeButton: some View {
        Button(action: {
            viewModel.isAddingQuote = true
        }) {
            SubmitButtonView(text: "Submit a Quote", imageSystemName: "paperplane.circle")
        }
    }
    var howWorksPopUp: some View {
        Button(action: {
            viewModel.showSubmissionInfoAlert = true
        }) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.title3)
                Text("How This Works")
            }
            .padding()
        }
        .alert(isPresented: $viewModel.showSubmissionInfoAlert) {
            Alert(
                title: Text("How Quote Submission Works"),
                message: Text("Submitted quotes will either be approved to be added into the app's quote database, or dismissed.\n\nI'll be able to edit typos or insert missing fields, such as author and classification, so don't worry about this when submitting."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    private var quoteAddition: some View {
        VStack {
            howWorksPopUp
            NavigationStack {
                Text("Submit a Quote")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 5)
                Form{
                    //                    Section(header: Text("Quote Info"))
                    Section() { // without header
                        TextField("Quote Text", text: $viewModel.quoteText)
                        TextField("Quote Author", text: $viewModel.author)
                        TextField("Your Name/Alias (Optional)", text: $viewModel.submitterName)
                        submissionQuoteCategoryPicker
                    }
                    Button("Submit") {
						Task{
							await viewModel.addQuote()
						}
                    }
                    .alert(isPresented: $viewModel.showSubmissionReceivedAlert) { // Modify this line
                        Alert(
                            title: Text("Submission Received"),
                            message: Text(viewModel.submissionMessage),
                            dismissButton: .default(Text("OK")) {
                                viewModel.showSubmissionReceivedAlert = false // Dismisses the alert when OK is clicked
                            }
                        )
                    }
                    
                }
                //                .navigationTitle("Quote Submission")
                .accentColor(.blue)
            }
        }
        
    }
    private var submissionQuoteCategoryPicker: some View {
        HStack {
            Picker("Quote Category", selection: $viewModel.selectedCategory) {
                // Create a custom array that places .all at the beginning and filters out .bookmarkedQuotes
                ForEach([.all] + QuoteCategory.allCases.filter { $0 != .bookmarkedQuotes && $0 != .all }, id: \.self) { category in
                    Text(category == .all ? "Unsure" : category.rawValue)
                }
            }
        }
    }
}
