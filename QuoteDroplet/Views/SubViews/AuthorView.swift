//
//  AuthorView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-21.
//

import SwiftUI
import Foundation

@available(iOS 16.0, *)
struct AuthorView: View {
    @ObservedObject var viewModel: AuthorViewModel
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

    init(quote: Quote) {
        self.viewModel = AuthorViewModel(
            quote: quote,
            localQuotesService: LocalQuotesService(),
            apiService: APIService()
        )
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    Text("Quotes by \(viewModel.quote.author ?? "Author"):")
                        .modifier(QuotesPageTitleStyling())

                    Spacer()
                }

                ZStack{
                    Image("authorimageframe")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                    AsyncImage(url: URL(string: "https://your_image_url_address"))
                }


                ScrollView {
                    Spacer()
                    LazyVStack{
                        if viewModel.quotes.isEmpty {
                            Text("Loading Quotes...")
                                .modifier(QuotesPageTextStyling())
                        } else {
                            ForEach(viewModel.quotes) { quote in
                                SingleQuoteView(quote: quote, from: .authorView)
                            }
                        }
                        Color.clear.frame(height: 1)
                            .onAppear {
                                if !viewModel.isLoadingMore && viewModel.quotes.count < AuthorViewModel.maxQuotes {
                                    viewModel.loadMoreQuotes()
                                }
                            }
                        Spacer()

                        VStack{
                            Text("Missing a quote from this author?\nI'd greatly appreciate submissions:")
                                .modifier(QuotesPageTextStyling())

                            SubmitView(viewModel: SubmitViewModel(apiService: viewModel.apiService))
                        }

                        if !viewModel.isLoadingMore {
                            if (viewModel.quotes.count >= AuthorViewModel.maxQuotes) {
                                Text("You've reached the quote limit of \(AuthorViewModel.maxQuotes). Maybe take a break?")
                                    .modifier(QuotesPageTextStyling())
                            }
                        }
                        Spacer()
                    }
                }

            }
            .modifier(MainScreenBackgroundStyling())
            .onAppear {
                // Fetch initial quotes when the view appears
                viewModel.loadInitialQuotes()
                sharedVars.colorPaletteIndex = widgetColorPaletteIndex

                colorPalettes[3][0] = Color(hex: widgetCustomColorPaletteFirstIndex)
                colorPalettes[3][1] = Color(hex: widgetCustomColorPaletteSecondIndex)
                colorPalettes[3][2] = Color(hex: widgetCustomColorPaletteThirdIndex)

                if let APIKey: String = ProcessInfo.processInfo.environment["GoogleImagesAPIKey"] {
                    viewModel
                        .loadRemoteJSON("https://www.googleapis.com/customsearch/v1?key=\(APIKey)&cx=238ad9d0296fb425a&searchType=image&q=Marcus%20Aurelius"){ (
                            data: TestModel
                        ) in
                            //data is your returned value of the generic type T.
                            print(data)
                        }
                }
            }
        }
    }
}
