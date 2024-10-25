//
//  CommunityView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-09.
//

import SwiftUI
import WidgetKit
import UIKit
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
                    Spacer()
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
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
    private var quoteSection: some View {
        VStack(alignment: .leading) {
            HStack{
                Spacer()
                Text("Newest Quotes")
                    .font(.largeTitle.bold())
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                    .padding(.bottom, 5)
                Spacer()
            }
            
            
            if viewModel.recentQuotes.isEmpty {
                Text("Loading Quotes ...")
                    .font(.title3)
                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                    .padding(.bottom, 2)
                ForEach(1..<4) { index in
                    VStack() {
                        HStack {
                            Text("Quote Loading")
                                .font(.title3)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                                .padding(.bottom, 2)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        
                        HStack{
                            Spacer()
                            Text("— Author Loading")
                                .font(.body)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                                .padding(.bottom, 5)
                                .frame(alignment: .trailing)
                        }
                    }
                }
            } else {
                ForEach(viewModel.recentQuotes, id: \.id) { quote in
                    VStack() {
                        HStack{
                            Text("\(quote.text)")
                                .font(.title3)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .white)
                                .padding(.bottom, 2)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        
                        // adjusted
                        if let author = quote.author, isAuthorValid(authorGiven: quote.author) {
                            HStack{
                                Spacer()
                                Text("— \(author)")
                                    .font(.body)
                                    .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                                    .padding(.bottom, 5)
                                    .frame(alignment: .trailing)
                            }
                        } else {
                            Text("")
                                .font(.body)
                                .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .white)
                                .padding(.bottom, 5)
                                .frame(alignment: .trailing)
                        }
                    }
                }
            }
        }
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}
