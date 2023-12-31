//
//  ContentView.swift
//  QuoteDroplet
//
//  Created by Daniel Agapov on 2023-08-30.
//

import SwiftUI
import WidgetKit

var colorPalettes = [
    [Color(hex: "504136"), Color(hex: "EEC584"), Color(hex: "CC5803")],
    [Color(hex: "85C7F2"), Color(hex: "0C1618"), Color(hex: "83781B")],
    [Color(hex: "EFF8E2"), Color(hex: "DC9E82"), Color(hex: "423E37")],
    [Color(hex: "1C7C54"), Color(hex: "E2B6CF"), Color(hex: "DEF4C6")]
]

enum QuoteCategory: String, CaseIterable {
    case wisdom = "Wisdom"
    case motivation = "Motivation"
    case discipline = "Discipline"
    case philosophy = "Philosophy"
    case inspiration = "Inspiration"
    case upliftment = "Upliftment"
    case love = "Love"
    case all = "All"
    
    var displayName: String {
        return self.rawValue
    }
}

struct ContentView: View {
    @AppStorage("colorPaletteIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var colorPaletteIndex = 0
    @AppStorage("quoteFrequencyIndex", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteFrequencyIndex = 3
    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    var quoteCategory: QuoteCategory = .all
    
    @State private var showInstructions = false
    
    @State private var counts: [String: Int] = [:]
    // Add a property to track whether a custom color has been picked
    
    let frequencyOptions = ["30 sec", "10 min", "1 hr", "2 hrs", "4 hrs", "8 hrs", "1 day"]
    
    init() {
        // Check if the app is launched for the first time
        if UserDefaults.standard.value(forKey: "isFirstLaunch") as? Bool ?? true {
            // Set the default color palette index to 0 (first sample color palette)
            colorPaletteIndex = 0
            UserDefaults.standard.setValue(false, forKey: "isFirstLaunch")
        }
    }
    
    private func getCategoryCounts(completion: @escaping ([String: Int]) -> Void) {
        let group = DispatchGroup()
        var counts: [String: Int] = [:]

        for category in QuoteCategory.allCases {
            group.enter()
            getCountForCategory(category: category) { categoryCount in
                counts[category.rawValue] = categoryCount
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(counts)
        }
    }
    
    private var quoteCategoryPicker: some View {
        HStack {
            Text("Quote Category:")
                .font(.title2)
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)

            Picker("", selection: $quoteCategory) {
                if counts.isEmpty {
                    // Placeholder while counts are being fetched
                    Text("Loading...")
                } else {
                    ForEach(QuoteCategory.allCases, id: \.self) { category in
                        if let categoryCount = counts[category.rawValue] {
                            let displayNameWithCount = "\(category.displayName) (\(categoryCount))"

                            Text(displayNameWithCount)
                                .font(.headline)
                                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                        }
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
            .accentColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
            .onAppear {
                // Fetch category counts asynchronously when the view appears
                getCategoryCounts { fetchedCounts in
                    // Update the counts and trigger a view update
                    counts = fetchedCounts
                }
            }
            .onTapGesture {
                WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
            }
        }
    }

    
    private var timeIntervalPicker: some View {
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
    }
    
    private var widgetPreviewSection: some View {
        VStack {
            Text("Preview:")
                .font(.title3) // Increased font size
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorPalettes[safe: colorPaletteIndex]?[0] ?? .clear) // Use the first color as the background color
                    .overlay(
                        VStack {
                            Spacer()
                            Text("More is lost by indecision than by wrong decision.")
                                .font(.headline)
                                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white) // Use the second color for text color
                                .padding(.horizontal, 20) // SPLIT BY ME
                                .padding(.vertical, 10) // SPLIT BY ME
                                .multilineTextAlignment(.center) // Center-align the text
                                .lineSpacing(4) // Adjusted line spacing
                                .minimumScaleFactor(0.5)
                                .frame(maxHeight: .infinity)

                            Text("- Cicero")
                                .font(.subheadline)
                                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .white) // Use the third color for author text color
                                .padding(.horizontal, 20) // ! SPLIT BY ME
                                .padding(.bottom, 10) // ! CHANGED BY ME
                                .lineLimit(1) // Ensure the author text is limited to one line
                                .minimumScaleFactor(0.5) // Allow author text to scale down if needed
                        }
                    )
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 0) // Add a subtle shadow for depth
                    .padding(.trailing, 0)
            }
            .frame(width: 150, height: 150)
        }
    }
    
    private var aboutMeSection: some View {
        // About Me Section
        
        HStack {
            Text("About Me:")
                .font(.title2) // Increased font size
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                .padding(.leading, 10)
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
        
        .padding(EdgeInsets(top: 15, leading: 0, bottom: 10, trailing: 0))
        .background(ColorPaletteView(colors: [colorPalettes[safe: colorPaletteIndex]?[0] ?? Color.clear]))
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    private var sampleColourSection: some View {
        VStack {
            Text("Sample Colours:")
                .font(.title3) // Increased font size
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                .padding(.top, 10)
            HStack(spacing: 10) {
                ForEach(0..<colorPalettes.count - 1, id: \.self) { paletteIndex in
                    ColorPaletteView(colors: colorPalettes[safe: paletteIndex] ?? [])
                        .frame(width: 60, height: 60) // Adjusted size
                        .border(colorPaletteIndex == paletteIndex ? Color.blue : Color.clear, width: 2)
                        .cornerRadius(8)
                        .onTapGesture {
                            colorPaletteIndex = paletteIndex
                            
                            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
                        }
                }
            }
        }
    }

    
    private var customColorPickers: some View {
        HStack(spacing: 10) {
            ForEach(0..<(colorPalettes.last?.count ?? 0), id: \.self) { customIndex in
                customColorPicker(index: customIndex)
            }
        }
    }
    
    private func getCountForCategory(category: QuoteCategory, completion: @escaping (Int) -> Void) {
        guard let url = URL(string: "http://quote-dropper-production.up.railway.app/quoteCount?category=\(category.rawValue.lowercased())") else {
            completion(0)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let count = json["count"] as? Int {
                completion(count)
            } else {
                completion(0)
            }
        }.resume()
    }



    private func customColorPicker(index: Int) -> some View {
        ColorPicker(
            "",
            selection: Binding(
                get: {
                    colorPalettes[3][index]
                },
                set: { newColor in
                    // Update the last element with the custom color palette
                    colorPalettes[3][index] = newColor
                    // Set colorPaletteIndex to the index of the custom color palette
                    colorPaletteIndex = 3
                }
            ),
            supportsOpacity: false
        )
        .frame(width: 60, height: 60)
        .cornerRadius(8)
        .onChange(of: colorPalettes) { _ in
            // Reload the widget timeline whenever the custom color changes
            WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
        }
    }

    private var customColourSection: some View {
        VStack(spacing: 10) {
            Text("Custom Colours:")
                .font(.title3) // Increased font size
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[1] ?? .white)
                .padding(.top, 10)
            
            customColorPickers
        }
    }


    var body: some View {
        VStack {
            quoteCategoryPicker
            
            timeIntervalPicker
            
            // Color Palette Section
            Group {
                HStack(spacing: 20) {
                    VStack(spacing: 10) {
                        sampleColourSection
                        
                        customColourSection
                    }
                    widgetPreviewSection
                }
            }
            
            Text("Note: To make more than a singular change to the custom colours, click a sample to make it update. This is a bug I intend to fix.")
                .font(.title3)
                .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .gray)
                .multilineTextAlignment(.center)

            
            Spacer() // Create spacing
            
            
            if showInstructions {
                InstructionsSection()
            } else {
                Text("Be sure to add the widget.")
                    .font(.title2)
                    .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
//            Button(action: {
//                showInstructions.toggle()
//            }) {
//                if showInstructions{
//                    Text("Hide Instructions")
//                        .font(.headline)
//                        .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
//                } else {
//                    Text("Show Instructions")
//                        .font(.headline)
//                        .foregroundColor(colorPalettes[safe: colorPaletteIndex]?[2] ?? .blue)
//                }
//            }
               
//            Spacer()
            
            aboutMeSection
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
            .ignoresSafeArea() // This line will make the background take up the whole screen
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


struct InstructionsSection: View {
    let instructions = [
        "Press and hold an empty area of your home screen.",
        "Tap the '+' button (top left).",
        "Find and select 'Quote Droplet'."
    ]

    var body: some View {
        List(instructions, id: \.self) { instruction in
            Text(instruction)
                .font(.title3)
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
        }
    }
}
