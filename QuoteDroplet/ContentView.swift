//
//  ContentView.swift
//  QuoteDroplet
//
//  Created by Daniel Agapov on 2023-08-30.
//

import SwiftUI
import WidgetKit

let colorPalettes = [
    [Color(hex: "504136"), Color(hex: "EEC584"), Color(hex: "CC5803")],
    [Color(hex: "85C7F2"), Color(hex: "0C1618"), Color(hex: "83781B")],
    [Color(hex: "EFF8E2"), Color(hex: "DC9E82"), Color(hex: "423E37")]
]

struct CustomColorPalette {
    var color1: Color
    var color2: Color
    var color3: Color
}

enum QuoteCategory: String, CaseIterable {
    case wisdom = "Wisdom"
    case motivation = "Motivation"
    case discipline = "Discipline"
    case philosophy = "Philosophy"
    case inspiration = "Inspiration"
    case upliftment = "Upliftment"
    case all = "All"
    
    var displayName: String {
        return self.rawValue
    }
}

struct ContentView: View {
    @State private var customColorPalette = CustomColorPalette(color1: Color(hex: "0D0630"), color2: Color(hex: "62A87C"), color3: Color(hex: ("384E77")))
    
    @AppStorage("colorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var colorPaletteIndex = 0
    @AppStorage("quoteFrequencyIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteFrequencyIndex = 3
    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteCategory: QuoteCategory = .all
    
    @State private var showInstructions = false
    
    
    
    let frequencyOptions = ["30 sec", "10 min", "1 hr", "2 hrs", "4 hrs", "8 hrs", "1 day"]

    var body: some View {
        VStack {
            HStack {
                Text("Quote Category:")
                    .font(.title2)
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                
                Picker("", selection: $quoteCategory) {
                    ForEach(QuoteCategory.allCases, id: \.self) { category in
                        Text(category.displayName)
                            .font(.headline)
                            .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .accentColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
                .onTapGesture{
                    WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                }
            }
            
            Group {
                Text("Time interval between quotes:")
                    .font(.title2) // Increased font size
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                    .padding(.top, 20)
                
                Picker("", selection: $quoteFrequencyIndex) {
                    ForEach(0..<frequencyOptions.count, id: \.self) { index in
                        Text(self.frequencyOptions[index])
                            .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onReceive([self.quoteFrequencyIndex].publisher.first()) { _ in
                    WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                }
                
            }
            .padding(.bottom, 20) // Increased spacing
            
            Group {
                Text("Color Palette:")
                    .font(.title2) // Increased font size
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                    .padding(.top, 20)
                
                HStack(spacing: 20) {
                    ForEach(0..<colorPalettes.count, id: \.self) { paletteIndex in
                        ColorPaletteView(colors: colorPalettes[safe: paletteIndex] ?? [])
                            .frame(width: 100, height: 100)
                            .border(colorPaletteIndex == paletteIndex ? Color.blue : Color.clear, width: 2)
                            .cornerRadius(8)
                            .onTapGesture {
                                colorPaletteIndex = paletteIndex
                                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                            }
                    }
                }
            }
            
            // Custom Color Palette Section
            Group {
                HStack(spacing: 10) { // Reduced spacing between color pickers
                    Text("Custom:")
                        .font(.title2)
                        .foregroundColor(customColorPalette.color2) // Use the middle color for text color
                        .padding(.top, 20)
                    
                    ColorPicker("", selection: $customColorPalette.color1)
                        .foregroundColor(customColorPalette.color1)
                        .frame(width: 100, height: 100) // Make them squares
                        .cornerRadius(8)
                    
                    ColorPicker("", selection: $customColorPalette.color2)
                        .foregroundColor(customColorPalette.color2)
                        .frame(width: 100, height: 100) // Make them squares
                        .cornerRadius(8)
                    
                    ColorPicker("", selection: $customColorPalette.color3)
                        .foregroundColor(customColorPalette.color3)
                        .frame(width: 100, height: 100) // Make them squares
                        .cornerRadius(8)
                }
            }

            
            Spacer() // Create spacing
            
            if showInstructions {
                VStack(alignment: .leading, spacing: 4) {
                    Text("1. Press and hold an empty area of your home screen.")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                    
                    Text("2. Tap the '+' button (top left).")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                    
                    Text("3. Find and select 'Quote Droplet'.")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                    
                    Text("4. Tap 'Add Widget,' then place it.")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                }
                .padding(.horizontal)
            } else {
                Text("Be sure to add this widget to your home screen.")
                    .font(.title)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            Button(action: {
                showInstructions.toggle()
            }) {
                if showInstructions{
                    Text("Hide Instructions")
                        .font(.headline)
                        .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
                } else {
                    Text("Show Instructions")
                        .font(.headline)
                        .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
                }
            }
               
            Spacer()
            
            // About Me Section
            VStack {
                Text("About Me")
                    .font(.title2) // Increased font size
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                
                HStack {
                    Spacer()
                    Link(destination: URL(string: "https://github.com/Daggerpov")!) {
                        Image("githublogo")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                    }
                    
                    Link(destination: URL(string: "https://www.linkedin.com/in/danielagapov/")!) {
                        Image("linkedinlogo")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                    }
                    Spacer()
                }
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
            .background(ColorPaletteView(colors: [colorPalettes[safe: colorPaletteIndex]?[0] ?? Color.clear]))
            .cornerRadius(20)
            .shadow(radius: 5)
            .padding(.horizontal)
        }
        .padding()
        .background(ColorPaletteView(colors: [colorPalettes[safe: colorPaletteIndex]?[0] ?? Color.clear]))
    }

    
    private func formattedFrequency() -> String {
        return frequencyOptions[quoteFrequencyIndex]
    }
}

// A view that displays a gradient background using the provided colors
struct ColorPaletteView: View {
    var colors: [Color]

    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0 ..< self.columns, id: \.self) { column in
                        self.content(row, column)
                    }
                }
            }
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
