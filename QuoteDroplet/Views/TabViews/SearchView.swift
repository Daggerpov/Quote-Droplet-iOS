//
//  SearchView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-09-08.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct SearchView: View {
    @StateObject var viewModel: SearchViewModel = SearchViewModel(
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
    
    // for top UI stuff:
    @Namespace private var animation
    
    var body: some View {
        NavigationStack{
            VStack{
                ScrollView(.vertical) {
                    LazyVStack(spacing: 15) {
                        if viewModel.searchText != "" {
                            ForEach(viewModel.quotes) { quote in
                                SingleQuoteView(
                                    quote: quote,
                                    from: .standardView,
                                    searchText: viewModel.searchText
                                )
                            }
                        } else {
                            DummyQuotesView()
                        }
                    }
                    .safeAreaInset(edge: .top, spacing: 0) {
                        ExpandableSearchBar()
                    }
                }
            }
            .modifier(MainScreenBackgroundStyling())
            .onAppear() {
                sharedVars.colorPaletteIndex = widgetColorPaletteIndex
                
                colorPalettes[3][0] = Color(hex: widgetCustomColorPaletteFirstIndex)
                colorPalettes[3][1] = Color(hex: widgetCustomColorPaletteSecondIndex)
                colorPalettes[3][2] = Color(hex: widgetCustomColorPaletteThirdIndex)
            }
        }
    }
}

@available(iOS 16.0, *)
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

@available(iOS 16.0, *)
extension SearchView {
    @ViewBuilder
    func ExpandableSearchBar(_ title: String = "Quote Search") -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                .padding(.bottom, 5)
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass").font(.title3)
                TextField("Search by quote text or author name", text: $viewModel.searchText)
                    .onChange(of: viewModel.searchText) { _ in
                        viewModel.loadQuotesBySearch()
                    }
                
                // Clear/dismiss button
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.clearSearch()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .gray)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .frame(height: 45)
            .background{
                RoundedRectangle(cornerRadius: 25).fill(.background)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(QuoteCategory.allCases, id: \.rawValue) { category in
                        Button(action: {
                            withAnimation(.snappy) {
                                viewModel.activeCategory = category
                            }
                            
                        }) {
                            Text(category.rawValue)
                                .font(.callout)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? .blue)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 15)
                                .background {
                                    if viewModel.activeCategory == category {
                                        Capsule()
                                            .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                                            .matchedGeometryEffect(id: "ACTIVECATEGORY", in: animation)
                                    } else {
                                        Capsule()
                                            .fill(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        
                    }
                }
                .onChange(of: viewModel.activeCategory) { _ in
                    viewModel.loadQuotesBySearch()
                }
                .padding(.top, 10)
            }
        }
        .padding(.horizontal, 15)
        .padding(.bottom, 20)
    }
    
    // Dummy Quotes View
    @ViewBuilder
    func DummyQuotesView() -> some View {
        ForEach(0..<20, id: \.self) { _ in
            VStack {
                HStack {
                    VStack {
                        HStack {
                            Rectangle().frame(width: CGFloat(Int.random(in: 200..<250)), height:9.5)
                                .modifier(DummyQuoteTextStyling())
                            Spacer()
                        }
                        
                        HStack{
                            Rectangle().frame(width: CGFloat(Int.random(in: 40..<130)), height:9.5)
                                .modifier(DummyQuoteTextStyling())
                            Spacer()
                        }
                        
                        HStack{
                            Rectangle().frame(width: CGFloat(Int.random(in: 40..<130)), height:9.5)
                                .modifier(DummyQuoteTextStyling())
                            Spacer()
                        }
                        
                    }
                    Spacer()
                }
                
                HStack{
                    Spacer()
                    Text("— ")
                        .modifier(DummyQuoteAuthorTextStyling())
                    Rectangle().frame(width: CGFloat(Int.random(in: 70..<150)), height: 9.5)
                        .modifier(DummyQuoteAuthorTextStyling())
                }
            }
            .modifier(QuotesSectionOuterStyling())
            .padding(.horizontal)
        }
    }
}
