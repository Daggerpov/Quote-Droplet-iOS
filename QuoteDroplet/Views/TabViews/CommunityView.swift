//
//  CommunityView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-09.
//

import SwiftUI
import Foundation

@available(iOS 16.0, *)
struct CommunityView: View {
    @StateObject var viewModel: CommunityViewModel = CommunityViewModel(
        localQuotesService: LocalQuotesService(), apiService: APIService()
    )
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    
    @AppStorage("widgetColorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var widgetColorPaletteIndex = 0
    
    // actual colors of custom:
    
    @AppStorage("widgetCustomColorPaletteFirstIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteFirstIndex = "1C7C54"
    
    @AppStorage("widgetCustomColorPaletteSecondIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteSecondIndex = "E2B6CF"
    
    @AppStorage("widgetCustomColorPaletteThirdIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteThirdIndex = "DEF4C6"
    
    var body: some View {
        NavigationStack {
            VStack {
                HeaderView()
                VStack{
                    Spacer()
                    quoteSection
                    Spacer()
                    SubmitView()
                    mySubmissionsButton
                    Spacer()
                }
                .padding()
            }
            .modifier(MainScreenBackgroundStyling())
            .onAppear {
                viewModel.getRecentQuotes()
                
                sharedVars.colorPaletteIndex = widgetColorPaletteIndex
                
                colorPalettes[3][0] = Color(hex:widgetCustomColorPaletteFirstIndex)
                colorPalettes[3][1] = Color(hex:widgetCustomColorPaletteSecondIndex)
                colorPalettes[3][2] = Color(hex:widgetCustomColorPaletteThirdIndex)
            }
        }
    }
}

@available(iOS 16.0, *)
struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}

@available(iOS 16.0, *)
extension CommunityView {
    private var mySubmissionsButton: some View {
        NavigationLink {
            SubmissionsView()
        } label: {
            SubmitButtonView(text: "My Submissions", imageSystemName: "tray.full")
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var quoteSection: some View {
        VStack(alignment: .leading) {
            HStack{
                Spacer()
                Text("Newest Quotes")
                    .modifier(QuotesPageTitleStyling())
                Spacer()
            }

            if viewModel.recentQuotes.isEmpty {
                Text("Loading Quotes ...")
                    .modifier(CommunityQuotesTextStyling())
                ForEach(1..<4) { index in
                    VStack() {
                        HStack {
                            Text("Quote Loading")
                                .modifier(CommunityQuotesTextStyling())
                            Spacer()
                        }
                        
                        HStack{
                            Spacer()
                            Text("— Author Loading")
                                .modifier(CommunityQuotesAuthorTextStyling())
                        }
                    }
                }
            } else {
                ForEach(viewModel.recentQuotes, id: \.id) { quote in
                    VStack() {
                        HStack{
                            Text("\(quote.text)")
                                .modifier(CommunityQuotesTextStyling())
                            Spacer()
                        }
                        
                        // adjusted
                        if let author = quote.author, isAuthorValid(authorGiven: quote.author) {
                            HStack{
                                Spacer()
                                Text("— \(author)")
                                    .modifier(CommunityQuotesAuthorTextStyling())
                            }
                        } else {
                            Text("")
                                .modifier(CommunityQuotesAuthorTextStyling())
                        }
                    }
                }
            }
        }
        .modifier(QuotesSectionOuterStyling())
    }
}
