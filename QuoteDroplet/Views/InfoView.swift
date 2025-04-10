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

    @AppStorage("widgetColorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var widgetColorPaletteIndex = 0

    // actual colors of custom:
    @AppStorage("widgetCustomColorPaletteFirstIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteFirstIndex = "1C7C54"

    @AppStorage("widgetCustomColorPaletteSecondIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteSecondIndex = "E2B6CF"

    @AppStorage("widgetCustomColorPaletteThirdIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var widgetCustomColorPaletteThirdIndex = "DEF4C6"

    @Environment(\.requestReview) var requestReview

    @State private var showMacAlert = false

    

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("App Info (Version \(Bundle.main.releaseVersionNumber ?? "Unknown"))")
                        .font(.title)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[2] ?? .blue)
                        .padding(.bottom, 5)

                    Spacer()
                }
                shareAppButton
                Spacer()
                reviewButton
                Spacer()
                macNoteSection
                Spacer()
                aboutMeSection
                Spacer()
            }
            .modifier(MainScreenBackgroundStyling())
            .padding()
            .onAppear {
                // Fetch initial quotes when the view appears
                sharedVars.colorPaletteIndex = widgetColorPaletteIndex

                colorPalettes[3][0] = Color(hex: widgetCustomColorPaletteFirstIndex)
                colorPalettes[3][1] = Color(hex: widgetCustomColorPaletteSecondIndex)
                colorPalettes[3][2] = Color(hex: widgetCustomColorPaletteThirdIndex)
            }
        }
        .modifier(MainScreenBackgroundStyling())
        .padding()
        .onAppear {
            // Fetch initial quotes when the view appears
            sharedVars.colorPaletteIndex = widgetColorPaletteIndex

            colorPalettes[3][0] = Color(hex: widgetCustomColorPaletteFirstIndex)
            colorPalettes[3][1] = Color(hex: widgetCustomColorPaletteSecondIndex)
            colorPalettes[3][2] = Color(hex: widgetCustomColorPaletteThirdIndex)
        }

    }
}


@available(iOS 16.0, *)
extension InfoView {
    private var aboutMeSection: some View {
        HStack {
            Spacer()
            buildLinkImage(urlForImage: "https://www.linkedin.com/in/danielagapov/", imageName: "linkedinlogo")
            Spacer()
            buildLinkImage(urlForImage: "https://github.com/Daggerpov", imageName: "githublogo")
            Spacer()
            buildLinkImage(urlForImage: "mailto:danielagapov1@gmail.com?subject=Quote%20Droplet%20Contact", imageName: "gmaillogo", widthSpecified: 60)
            Spacer()
        }
        
        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
        .background(ColorPaletteView(colors: [colorPalettes[safe: sharedVars.colorPaletteIndex]?[0] ?? Color.clear]))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    private var shareAppButton: some View {
        HStack{
            HStack{
                ShareLink(item: URL(string: "https://apps.apple.com/us/app/quote-droplet/id6455084603")!, message: Text("Check out this app, Quote Droplet.")){
                    Label("Share Quote Droplet", systemImage: "arrow.up.right.square")
                        .font(.title3)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue)
                }
                
            }
            .modifier(RoundedRectangleStyling())
        }
    }
    
    private var donateButton: some View {
        HStack{
            HStack{
                Link(destination: URL(string: "https://buy.stripe.com/fZe17cbqd25Q0Mw000")!) {
                    Label("Donate", systemImage: "giftcard")
                        .font(.title3)
                        .foregroundColor(colorPalettes[safe: sharedVars.colorPaletteIndex]?[1] ?? .blue)
                }
                
            }
            .modifier(RoundedRectangleStyling())
        }
    }
    
    
    private var reviewButton: some View {
        
        return HStack{
            Button(action: {
                requestReview()
            }) {
                HStack {
                    Image(systemName: "star")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                    Text("Rate Quote Droplet")
                        .font(.title3)
                }
                .modifier(RoundedRectangleStyling())
            }
            .padding()
        }
    }
    
    private var macNoteSection: some View {
        VStack (spacing: 10){
            Button(action: {
                showMacAlert = true
            }) {
                HStack {
                    Image(systemName: "info.circle")
                    Text("Note for Mac Owners")
                        .padding(.leading, 5)
                }
                .font(.title3)
                .modifier(BasePicker_OuterBackgroundStyling())
                .buttonStyle(CustomButtonStyle())
            }
            .alert(isPresented: $showMacAlert) {
                Alert(
                    title: Text("Note for Mac Owners"),
                    message: Text("You can actually add this same iOS widget to your Mac's widgets by clicking the date in the top-right corner of your Mac -> Edit Widgets.\n\nAlso, Quote Droplet has a Mac version available on the App Store. It conveniently shows quotes from a small icon in your menu bar, even offline."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
