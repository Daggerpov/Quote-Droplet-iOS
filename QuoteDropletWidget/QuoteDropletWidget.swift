//
//  QuoteDropletWidget.swift
//  QuoteDropletWidget
//
//  Created by Daniel Agapov on 2023-08-30.
//

import WidgetKit
import SwiftUI
import Intents
import Foundation
import AppIntents

struct Provider: IntentTimelineProvider {
    let data: DataService = DataService()
    let localQuotesService: LocalQuotesService = LocalQuotesService()
    let apiService: APIService = APIService()
    @Environment(\.widgetFamily) var family
    
    func placeholder(in context: Context) -> SimpleEntry {
        let res: [String] = getTextForWidgetPreview(familia: .systemSmall)
        let placeholderQuoteText: String = res[0]
        let placeholderQuoteAuthor: String = res[1]
        
        let defaultQuote = Quote(
            id: 1,
            text: placeholderQuoteText,
            author: placeholderQuoteAuthor,
            classification: "Sample Classification",
            likes: 15
        )
        return SimpleEntry(date: Date(), configuration: ConfigurationIntent(), quote: defaultQuote, widgetColorPaletteIndex: data.getIndex(), widgetCustomColorPalette: data.getColorPalette(), quoteFrequency: data.getQuoteFrequencySelected(), quoteCategory: data.getQuoteCategory())
    }
    
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, quote: nil, widgetColorPaletteIndex: data.getIndex(), widgetCustomColorPalette: data.getColorPalette(), quoteFrequency: data.getQuoteFrequencySelected(), quoteCategory: data.getQuoteCategory())
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let startDate = Calendar.current.date(byAdding: .second, value: 0, to: currentDate)!
        
        // Calculate the frequency in seconds based on the selected index
        let frequencyInSeconds = getFrequencyInSeconds(
            quoteFrequency: data.getQuoteFrequencySelected()
        )
        
        // Schedule the next update based on the calculated frequency
        let nextUpdate = Calendar.current.date(byAdding: .second, value: frequencyInSeconds, to: startDate)!
        
        // Create a fallback quote in case of any errors
        let fallbackQuote = Quote(
            id: 999,
            text: "More is lost by indecision than by wrong decision.",
            author: "Cicero",
            classification: "wisdom",
            likes: 0
        )
        
        if data.getQuoteCategory() == .bookmarkedQuotes {
            let bookmarkedQuotes = localQuotesService.getBookmarkedQuotes()
            
            if !bookmarkedQuotes.isEmpty {
                let randomIndex = Int.random(in: 0..<bookmarkedQuotes.count)
                let entry = SimpleEntry(date: nextUpdate, configuration: configuration, quote: bookmarkedQuotes[randomIndex], widgetColorPaletteIndex: data.getIndex(), widgetCustomColorPalette: data.getColorPalette(), quoteFrequency: data.getQuoteFrequencySelected(), quoteCategory: data.getQuoteCategory())
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } else {
                // Use fallback quote with a message about no bookmarks
                let noBookmarksQuote = Quote(
                    id: 998,
                    text: "No bookmarked quotes found. Save quotes in the app to see them here.",
                    author: "Quote Droplet",
                    classification: "info",
                    likes: 0
                )
                let entry = SimpleEntry(date: nextUpdate, configuration: configuration, quote: noBookmarksQuote, widgetColorPaletteIndex: data.getIndex(), widgetCustomColorPalette: data.getColorPalette(), quoteFrequency: data.getQuoteFrequencySelected(), quoteCategory: data.getQuoteCategory())
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            }
        } else {
            // Fetch the initial quote
            apiService
                .getRandomQuoteByClassification(
                    classification: data
                        .getQuoteCategory().lowercasedName,
                    completion:  { quote, error in
                        if let quote = quote {
                            let entry = SimpleEntry(date: nextUpdate, configuration: configuration, quote: quote, widgetColorPaletteIndex: data.getIndex(), widgetCustomColorPalette: data.getColorPalette(), quoteFrequency: data.getQuoteFrequencySelected(), quoteCategory: data.getQuoteCategory())
                            
                            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                            completion(timeline)
                        } else {
                            // Use fallback quote if API fails
                            let entry = SimpleEntry(date: nextUpdate, configuration: configuration, quote: fallbackQuote, widgetColorPaletteIndex: data.getIndex(), widgetCustomColorPalette: data.getColorPalette(), quoteFrequency: data.getQuoteFrequencySelected(), quoteCategory: data.getQuoteCategory())
                            
                            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                            completion(timeline)
                        }
                    },
                    isShortQuoteDesired: (family == .systemSmall))
        }
    }
}

@available(iOS 16.0, *)
struct QuoteDropletWidgetEntryView : View {
    var data: DataService = DataService()
    let localQuotesService: LocalQuotesService = LocalQuotesService()
    let apiService: APIService = APIService()
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var widgetQuote: Quote
    
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    @AppStorage("likedQuotes", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var likedQuotesData: Data = Data()
    
    @State private var isLiked: Bool = false
    @State private var isBookmarked: Bool = false
    @State private var isLiking: Bool = false // Add state for liking status
    
    @State private var isIntentsActive: Bool = false
    
    init(entry: SimpleEntry, isIntentsActive: Bool) {
        self.entry = entry
        self.widgetQuote = entry.quote ?? Quote(
            id: 1, 
            text: "More is lost by indecision than by wrong decision.", 
            author: "Cicero", 
            classification: "wisdom", 
            likes: 0
        )
        self._isBookmarked = State(initialValue: isQuoteBookmarked(self.widgetQuote))
        self._isLiked = State(initialValue: isQuoteLiked(self.widgetQuote))
        self._isIntentsActive = State(initialValue: isIntentsActive)
    }
    
    var colors: [Color] {
        if (data.getIndex() == 3) {
            return data.getColorPalette()
        } else {
            return colorPalettes[safe: data.getIndex()] ?? [Color.clear]
        }
    }
    
    private var likesSection: some View {
        HStack {
            if #available(iOS 17.0, *) {
                Button(intent: LikeQuoteIntent(quote: widgetQuote)) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundStyle(colors[2])
                }.backgroundStyle(colors[2])
            } else {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundStyle(colors[2])
            }
            
            Text("\(widgetQuote.likes ?? 69)")
                .foregroundColor(colors[2])
                
            if #available(iOS 17.0, *) {
                Button(intent: NextQuoteIntent()) {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(colors[2])
                }.backgroundStyle(colors[2])
            } else {
                Image(systemName: "arrow.right")
                    .foregroundStyle(colors[2])
            }
        }
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            VStack {
                if widgetQuote.text != "" {
                    if family == .systemSmall {
                        Text("\(widgetQuote.text)")
                            .font(Font.custom(availableFonts[data.getSelectedFontIndex()], size: getFontSizeForText(familia: family, whichText: .quoteText)))
                            .foregroundColor(colors[1])
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                            .minimumScaleFactor(0.5)
                    } else {
                        Text("\(widgetQuote.text)")
                            .font(Font.custom(availableFonts[data.getSelectedFontIndex()], size: getFontSizeForText(familia: family, whichText: .quoteText)))
                            .foregroundColor(colors[1])
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                    }
                    
                    HStack {
                        if (isAuthorValid(authorGiven: widgetQuote.author)) {
                            Text("— \(widgetQuote.author ?? "")")
                                .foregroundColor(colors[2]) // Use the third color for author text color
                                .padding(.horizontal, 5)
                                .lineLimit(1) // Ensure the text stays on one line
                                .minimumScaleFactor(0.01) // Allow the text to shrink to 50% of its original size
                        }
                        if isIntentsActive {
                            likesSection
                        }
                    }
                    .font(
                        Font
                            .custom(
                                availableFonts[data.getSelectedFontIndex()],
                                size: getFontSizeForText(
                                    familia: family,
                                    whichText: .authorText
                                )
                            )
                    ) // Use the selected font for author text
                    
                } else {
                    Text("\(getTextForWidgetPreview(familia: family)[0])")
                        .font(Font.custom(availableFonts[data.getSelectedFontIndex()], size: getFontSizeForText(familia: family, whichText: .quoteText)))
                        .foregroundColor(colors[1]) // Use the second color for text color
                        .padding(.horizontal, 10)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        .minimumScaleFactor(0.01)
                    //                    Spacer() // Add a spacer to push the author text to the center
                    HStack {
                        Text("— \(getTextForWidgetPreview(familia: family)[1])")
                        
                            .foregroundColor(colors[2]) // Use the third color for author text color
                            .padding(.horizontal, 10)
                        if isIntentsActive {
                            likesSection
                        }
                    }
                    .font(Font.custom(availableFonts[data.getSelectedFontIndex()], size: getFontSizeForText(familia: family, whichText: .authorText))) // Use the selected font for author text
                }
            }
            .padding()
            .onAppear {
                isBookmarked = isQuoteBookmarked(widgetQuote)
                isLiked = isQuoteLiked(widgetQuote)
            }
            .containerBackground(colors[0], for: .widget)
        } else {
            // Fallback for iOS 16 and earlier
            ZStack {
                colors[0]
                VStack {
                    if widgetQuote.text != "" {
                        if family == .systemSmall {
                            Text("\(widgetQuote.text)")
                                .font(Font.custom(availableFonts[data.getSelectedFontIndex()], size: getFontSizeForText(familia: family, whichText: .quoteText)))
                                .foregroundColor(colors[1])
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                                .minimumScaleFactor(0.5)
                        } else {
                            Text("\(widgetQuote.text)")
                                .font(Font.custom(availableFonts[data.getSelectedFontIndex()], size: getFontSizeForText(familia: family, whichText: .quoteText)))
                                .foregroundColor(colors[1])
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        }
                        
                        HStack {
                            if (isAuthorValid(authorGiven: widgetQuote.author)) {
                                Text("— \(widgetQuote.author ?? "")")
                                    .foregroundColor(colors[2]) // Use the third color for author text color
                                    .padding(.horizontal, 5)
                                    .lineLimit(1) // Ensure the text stays on one line
                                    .minimumScaleFactor(0.01) // Allow the text to shrink to 50% of its original size
                            }
                            if isIntentsActive {
                                likesSection
                            }
                        }
                        .font(
                            Font
                                .custom(
                                    availableFonts[data.getSelectedFontIndex()],
                                    size: getFontSizeForText(
                                        familia: family,
                                        whichText: .authorText
                                    )
                                )
                        ) // Use the selected font for author text
                        
                    } else {
                        Text("\(getTextForWidgetPreview(familia: family)[0])")
                            .font(Font.custom(availableFonts[data.getSelectedFontIndex()], size: getFontSizeForText(familia: family, whichText: .quoteText)))
                            .foregroundColor(colors[1]) // Use the second color for text color
                            .padding(.horizontal, 10)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                            .minimumScaleFactor(0.01)
                        //                    Spacer() // Add a spacer to push the author text to the center
                        HStack {
                            Text("— \(getTextForWidgetPreview(familia: family)[1])")
                            
                                .foregroundColor(colors[2]) // Use the third color for author text color
                                .padding(.horizontal, 10)
                            if isIntentsActive {
                                likesSection
                            }
                        }
                        .font(Font.custom(availableFonts[data.getSelectedFontIndex()], size: getFontSizeForText(familia: family, whichText: .authorText))) // Use the selected font for author text
                    }
                }
                .padding()
            }
            .onAppear {
                isBookmarked = isQuoteBookmarked(widgetQuote)
                isLiked = isQuoteLiked(widgetQuote)
            }
        }
        
    }
    
    private func toggleBookmark() {
        isBookmarked.toggle()
        
        localQuotesService.saveBookmarkedQuote(quote: widgetQuote, isBookmarked: isBookmarked)
    }
    
    private func toggleLike() {
        isLiked.toggle()
        
        localQuotesService.saveLikedQuote(quote: widgetQuote, isLiked: isLiked)
    }
    
    private mutating func likeQuoteAction() async {
        guard !isLiking else { return }
        isLiking = true
        
        // Check if the quote is already liked
        let isAlreadyLiked = isQuoteLiked(widgetQuote)
        
        // Use async/await pattern instead of completion handlers
        if isAlreadyLiked {
            do {
                let result = try await apiService.unlikeQuoteAsync(quoteID: widgetQuote.id)
                if let updatedQuote = result {
                    self.widgetQuote = updatedQuote
                }
            } catch {
                print("⚠️ Error unliking quote: \(error)")
            }
        } else {
            do {
                let result = try await apiService.likeQuoteAsync(quoteID: widgetQuote.id)
                if let updatedQuote = result {
                    self.widgetQuote = updatedQuote
                }
            } catch {
                print("⚠️ Error liking quote: \(error)")
            }
        }
        
        isLiking = false
    }
    
    private func isQuoteLiked(_ quote: Quote) -> Bool {
        guard let likedQuotesData = UserDefaults(suiteName: "group.selectedSettings")?.data(forKey: "likedQuotes") else {
            print("⚠️ Warning: Could not access likedQuotes data from shared UserDefaults")
            return false
        }
        
        // Use a do-catch block for the JSON decoding to prevent crashes
        do {
            let quotes = try JSONDecoder().decode([Quote].self, from: likedQuotesData)
            return quotes.contains(where: { $0.id == quote.id })
        } catch {
            print("⚠️ Warning: Error decoding liked quotes: \(error)")
            return false
        }
    }
    
    private func getLikedQuotes() -> [Quote] {
        guard let likedQuotesData = UserDefaults(suiteName: "group.selectedSettings")?.data(forKey: "likedQuotes") else {
            print("⚠️ Warning: Could not access likedQuotes data from shared UserDefaults")
            return []
        }
        
        // Use a do-catch block for the JSON decoding to prevent crashes
        do {
            let quotes = try JSONDecoder().decode([Quote].self, from: likedQuotesData)
            return quotes
        } catch {
            print("⚠️ Warning: Error decoding liked quotes: \(error)")
            return []
        }
    }
    
    private func isQuoteBookmarked(_ quote: Quote) -> Bool {
        return localQuotesService.getBookmarkedQuotes().contains(where: { $0.id == quote.id })
    }
}


@available(iOS 16.0, *)
struct QuoteDropletWidgetSmall: Widget {
    let kind: String = "QuoteDropletWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            QuoteDropletWidgetEntryView(entry: entry, isIntentsActive: false)
        }
        .disableContentMarginsIfNeeded() // Use the extension here
        .configurationDisplayName("Example Widget")
        .description("Note that the color palette and font are customizable.")
        .supportedFamilies([.systemSmall])
    }
}

@available(iOS 16.0, *)
struct QuoteDropletWidgetMedium: Widget {
    let kind: String = "QuoteDropletWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            QuoteDropletWidgetEntryView(entry: entry, isIntentsActive: false)
        }
        .disableContentMarginsIfNeeded() // Use the extension here
        .configurationDisplayName("Example Widget")
        .description("Note that the color palette and font are customizable.")
        .supportedFamilies([.systemMedium])
    }
}

@available(iOS 16.0, *)
struct QuoteDropletWidgetLarge: Widget {
    let kind: String = "QuoteDropletWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            QuoteDropletWidgetEntryView(entry: entry, isIntentsActive: false)
        }
        .disableContentMarginsIfNeeded() // Use the extension here
        .configurationDisplayName("Example Widget")
        .description("Note that the color palette and font are customizable.")
        .supportedFamilies([.systemLarge])
    }
}

@available(iOS 16.0, *)
struct QuoteDropletWidgetExtraLarge: Widget {
    let kind: String = "QuoteDropletWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            QuoteDropletWidgetEntryView(entry: entry, isIntentsActive: false)
        }
        .disableContentMarginsIfNeeded()
        .configurationDisplayName("Example Widget")
        .description("Note that the color palette and font are customizable.")
        .supportedFamilies([.systemExtraLarge])
    }
}

@available(iOS 16.0, *)
struct QuoteDropletWidgetWithIntentsMedium: Widget {
    let kind: String = "QuoteDropletWidgetWithIntents"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            QuoteDropletWidgetEntryView(entry: entry, isIntentsActive: true)
        }
        .disableContentMarginsIfNeeded()
        .configurationDisplayName("Interactive Widget")
        .description("Widget with interactive elements.")
        .supportedFamilies([.systemMedium])
    }
}

@available(iOS 16.0, *)
struct QuoteDropletWidgetWithIntentsLarge: Widget {
    let kind: String = "QuoteDropletWidgetWithIntents"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            QuoteDropletWidgetEntryView(entry: entry, isIntentsActive: true)
        }
        .disableContentMarginsIfNeeded()
        .configurationDisplayName("Interactive Widget")
        .description("Widget with interactive elements.")
        .supportedFamilies([.systemLarge])
    }
}

@available(iOS 16.0, *)
struct QuoteDropletWidgetWithIntentsExtraLarge: Widget {
    let kind: String = "QuoteDropletWidgetWithIntents"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            QuoteDropletWidgetEntryView(entry: entry, isIntentsActive: true)
        }
        .disableContentMarginsIfNeeded()
        .configurationDisplayName("Interactive Widget")
        .description("Widget with interactive elements.")
        .supportedFamilies([.systemExtraLarge])
    }
}

@available(iOS 16.0, *)
struct QuoteDropletWidget_Previews: PreviewProvider {
    static var previews: some View {
        let widgetEntry = SimpleEntry(
            date: Date(),
            configuration: ConfigurationIntent(),
            quote: Quote(
                id: 1,
                text: "Sample Quote",
                author: "Sample Author",
                classification: "Sample Classification",
                likes: 15
            ),
            widgetColorPaletteIndex: 420,
            widgetCustomColorPalette: [
                Color(hex: "1C7C54"),
                Color(hex: "E2B6CF"),
                Color(hex: "DEF4C6")
            ],
            quoteFrequency: .oneDay,
            quoteCategory: .all
        )
        
        
        QuoteDropletWidgetEntryView(entry: widgetEntry, isIntentsActive: false)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

@available(iOS 16.0, *)
struct LikeQuoteIntent: AppIntent {
    var widgetQuote: Quote
    
    // Remove @EnvironmentObject and @AppStorage - these don't work properly in widget intents
    private var isLiked: Bool = false
    private var isLiking: Bool = false
    
    let localQuotesService: LocalQuotesService = LocalQuotesService()
    let apiService: APIService = APIService()
    
    init() {
        self.widgetQuote = Quote(id: 1, text: "", author: "", classification: "", likes: 15)
        self.isLiked = false
    }
    
    init(quote: Quote) {
        self.widgetQuote = quote
        self.isLiked = isQuoteLiked(widgetQuote)
    }
    
    static var title: LocalizedStringResource = "Like Quote Button"
    
    static var description = IntentDescription("Like/Unlike Quote")
    
    func perform() async throws -> some IntentResult {
        var mutableSelf = self
        await mutableSelf.likeQuoteAction()
        mutableSelf.toggleLike()
        
        // Only update the like status, don't refresh the entire widget which would change the quote
        return .result()
    }
    
    private mutating func toggleLike() {
        isLiked.toggle()
        
        localQuotesService.saveLikedQuote(quote: widgetQuote, isLiked: isLiked)
    }
    
    private mutating func likeQuoteAction() async {
        guard !isLiking else { return }
        isLiking = true
        
        // Check if the quote is already liked
        let isAlreadyLiked = isQuoteLiked(widgetQuote)
        
        // Use async/await pattern instead of completion handlers
        if isAlreadyLiked {
            do {
                let result = try await apiService.unlikeQuoteAsync(quoteID: widgetQuote.id)
                if let updatedQuote = result {
                    self.widgetQuote = updatedQuote
                }
            } catch {
                print("⚠️ Error unliking quote: \(error)")
            }
        } else {
            do {
                let result = try await apiService.likeQuoteAsync(quoteID: widgetQuote.id)
                if let updatedQuote = result {
                    self.widgetQuote = updatedQuote
                }
            } catch {
                print("⚠️ Error liking quote: \(error)")
            }
        }
        
        isLiking = false
    }
    
    private func isQuoteLiked(_ quote: Quote) -> Bool {
        guard let likedQuotesData = UserDefaults(suiteName: "group.selectedSettings")?.data(forKey: "likedQuotes") else {
            print("⚠️ Warning: Could not access likedQuotes data from shared UserDefaults")
            return false
        }
        
        // Use a do-catch block for the JSON decoding to prevent crashes
        do {
            let quotes = try JSONDecoder().decode([Quote].self, from: likedQuotesData)
            return quotes.contains(where: { $0.id == quote.id })
        } catch {
            print("⚠️ Warning: Error decoding liked quotes: \(error)")
            return false
        }
    }
    
    private func getLikedQuotes() -> [Quote] {
        guard let likedQuotesData = UserDefaults(suiteName: "group.selectedSettings")?.data(forKey: "likedQuotes") else {
            print("⚠️ Warning: Could not access likedQuotes data from shared UserDefaults")
            return []
        }
        
        // Use a do-catch block for the JSON decoding to prevent crashes
        do {
            let quotes = try JSONDecoder().decode([Quote].self, from: likedQuotesData)
            return quotes
        } catch {
            print("⚠️ Warning: Error decoding liked quotes: \(error)")
            return []
        }
    }
}

@available(iOS 16.0, *)
struct NextQuoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Quote Button"
    
    static var description = IntentDescription("Show Next Quote")
    
    func perform() async throws -> some IntentResult {
        // Request an immediate widget refresh
        WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "QuoteDropletWidgetWithIntents")
        
        // This will trigger a widget refresh to show a new quote
        return .result()
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let quote: Quote?  // Include the fetched quote here
    let widgetColorPaletteIndex: Int
    let widgetCustomColorPalette: [Color]
    let quoteFrequency: QuoteFrequency
    let quoteCategory: QuoteCategory
}

struct MinimumFontModifier: ViewModifier {
    let size: CGFloat
    let weight: Font.Weight
    let design: Font.Design
    let minimumSize: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: max(size, minimumSize), weight: weight, design: design))
            .lineLimit(nil) // Remove line limit to prevent truncation
    }
}

// Helper function to convert selected quote frequency to seconds
private func getFrequencyInSeconds(quoteFrequency: QuoteFrequency) -> Int {
    switch quoteFrequency {
        case .eightHours: return 28800
        case .twelveHours: return 43200
        case .oneDay: return 86400
        case .twoDays: return 172800
        case .fourDays: return 345600
        case .oneWeek: return 604800
    }
}

@available(iOS 16.0, *)
private func getFontSizeForText(familia: WidgetFamily, whichText: WidgetTextType) -> CGFloat {
    if (whichText == .quoteText) {
        // widgetAppropriateTextFontSize
        if familia == .systemExtraLarge {
            return 32
        } else if familia == .systemLarge {
            return 24
        } else {
            // .systemSmall & .systemMedium
            // stays as it was earlier
            return 16
        }
    } else {
        if familia == .systemExtraLarge {
            return 22
        } else if familia == .systemLarge {
            return 18
        } else {
            // .systemSmall & .systemMedium
            // stays as it was earlier
            return 14
        }
    }
}

public func getTextForWidgetPreview(familia: WidgetFamily) -> [String] {
    if familia == .systemSmall {
        return ["More is lost by indecision than by wrong decision.", "Cicero"];
    } else if familia == .systemMedium {
        return ["Our anxiety does not come from thinking about the future, but from wanting to control it.", "Khalil Gibran"];
    } else {
        // .systemLarge
        return ["Show me a person who has never made a mistake and I'll show you someone who hasn't achieved much.", "Joan Collins"];
    }
    
}

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOS 17.0, macCatalyst 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
