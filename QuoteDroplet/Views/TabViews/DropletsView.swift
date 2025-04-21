//
//  DropletsView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-05-18.
//
import SwiftUI

@available(iOS 16.0, *)
struct DropletsView: View {
    @StateObject var viewModel: DropletsViewModel = DropletsViewModel(
        localQuotesService: LocalQuotesService(),
        apiService: APIService()
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
                    topNavBar
                    Spacer()
                    quotesListView
                }
                .padding()
            }
            .modifier(MainScreenBackgroundStyling())
            .onAppear {
                // Fetch initial quotes when the view appears
                viewModel.loadInitialQuotes()
                // ------------------------------------------

                sharedVars.colorPaletteIndex = widgetColorPaletteIndex
                
                colorPalettes[3][0] = Color(hex: widgetCustomColorPaletteFirstIndex)
                colorPalettes[3][1] = Color(hex: widgetCustomColorPaletteSecondIndex)
                colorPalettes[3][2] = Color(hex: widgetCustomColorPaletteThirdIndex)
                
                // Schedule notifications:
                // will schedule with previous date and category values
                NotificationSchedulerService.shared.scheduleNotifications()
            }
            .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                .onEnded { value in
                    switch(value.translation.width, value.translation.height) {
                        case (...0, -30...30): // left swipe
                            if viewModel.selected == .feed {
                                viewModel.setSelected(newValue: .saved)
                            } else if viewModel.selected == .saved {
                                viewModel.setSelected(newValue: .recent)
                            }
                        case (0..., -30...30): // right swipe
                            if viewModel.selected == .recent {
                                viewModel.setSelected(newValue: .saved)
                            } else if viewModel.selected == .saved {
                                viewModel.setSelected(newValue: .feed)
                            }
                        default: break
                    }
                }
            )
        }
    }
}

@available(iOS 16.0, *)
struct DropletsView_Previews: PreviewProvider {
    static var previews: some View {
        DropletsView()
    }
}

@available(iOS 16.0, *)
extension DropletsView {
    private var topNavBar: some View {
        Picker(selection: $viewModel.selected, label: Text("Picker"), content: {
            Text("Feed").tag(SelectedPage.feed)
            Text("Saved").tag(SelectedPage.saved)
            Text("Recent").tag(SelectedPage.recent)
        })
        .pickerStyle(SegmentedPickerStyle())
        .onChange(of: viewModel.selected) { newValue in
            viewModel.loadMoreQuotes()
        }
    }
    
    private var titleText: some View {
        HStack {
            Spacer()
            Text(viewModel.getTitleText())
                .modifier(QuotesPageTitleStyling())
            Spacer()
        }
    }
    
    private var quotesListView: some View {
        ScrollView {
            Spacer()
            LazyVStack{
                titleText
                Spacer()

                if viewModel.getPageSpecificQuotes().isEmpty {
                    Text(viewModel.getPageSpecificEmptyText())
                        .modifier(QuotesPageTextStyling())
                    if viewModel.selected == .saved {
                        Image(systemName: "bookmark")
                            .modifier(QuoteInteractionButtonStyling())
                    }
                } else {
                    if viewModel.selected == .recent {
                        Text("These are your most recent quotes from notifications.")
                            .modifier(QuotesPageTextStyling())
                    }
                    ForEach(viewModel.getPageSpecificQuotes()) { quote in
                        SingleQuoteView(
                            quote: quote,
                            from: .standardView
                        )
                    }
                }
                
                Color.clear.frame(height: 1)
                    .onAppear {
                        viewModel.checkMoreQuotesNeeded()
                    }
                if viewModel.checkLimitReached() {
                    Text("You've reached the quote limit of \(DropletsViewModel.maxQuotes). Maybe take a break?")
                        .modifier(QuotesPageTextStyling())
                }
                Spacer()
            }
        }
    }
}
