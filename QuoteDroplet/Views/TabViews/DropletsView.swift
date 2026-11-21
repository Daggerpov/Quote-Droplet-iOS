//
//  DropletsView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-05-18.
//
import SwiftUI
import WidgetKit

@available(iOS 16.0, *)
struct DropletsView: View {
    @StateObject var viewModel: DropletsViewModel = DropletsViewModel(
        localQuotesService: LocalQuotesService(),
        apiService: APIService()
    )

    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs

    @AppStorage("quoteCategory", store: UserDefaults(suiteName: "group.selectedSettings"))
    private var quoteCategory: QuoteCategory = .all

    // Custom quote editor: `.new` to add one, `.edit` to change an existing one
    @State private var editorTarget: CustomQuoteEditorTarget? = nil
    @State private var quoteToDelete: Quote? = nil

    private static let pageOrder: [SelectedPage] = [.feed, .saved, .custom]

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                HeaderView(title: "Droplets", subtitle: Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                topNavBar
                quotesListView
            }
            .modifier(MainScreenBackgroundStyling())
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                // Fetch initial quotes when the view appears
                viewModel.loadInitialQuotes()
                viewModel.reloadCustomQuotes()
                // ------------------------------------------

                sharedVars.reloadFromDefaults()

                // Schedule notifications:
                // will schedule with previous date and category values
                NotificationSchedulerService.shared.scheduleNotifications()
            }
            .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                .onEnded { value in
                    guard abs(value.translation.height) <= 30,
                          let index = Self.pageOrder.firstIndex(of: viewModel.selected) else { return }
                    if value.translation.width < 0, index + 1 < Self.pageOrder.count { // left swipe
                        viewModel.setSelected(newValue: Self.pageOrder[index + 1])
                    } else if value.translation.width > 0, index > 0 { // right swipe
                        viewModel.setSelected(newValue: Self.pageOrder[index - 1])
                    }
                }
            )
            .sheet(item: $editorTarget) { target in
                CustomQuoteEditor(editing: target.quote) { text, author in
                    viewModel.saveCustomQuote(text: text, author: author, editing: target.quote)
                }
                .environmentObject(sharedVars)
                .preferredColorScheme(sharedVars.palette.colorScheme)
            }
            .alert("Delete this quote?", isPresented: Binding(
                get: { quoteToDelete != nil },
                set: { if !$0 { quoteToDelete = nil } }
            ), presenting: quoteToDelete) { quote in
                Button("Delete", role: .destructive) {
                    withAnimation { viewModel.deleteCustomQuote(quote) }
                    quoteToDelete = nil
                }
                Button("Cancel", role: .cancel) { quoteToDelete = nil }
            } message: { _ in
                Text("It's only stored on this device, so it can't be recovered.")
            }
        }
    }
}

@available(iOS 16.0, *)
struct DropletsView_Previews: PreviewProvider {
    static var previews: some View {
        DropletsView()
            .environmentObject(SharedVarsBetweenTabs())
    }
}

@available(iOS 16.0, *)
extension DropletsView {
    private var topNavBar: some View {
        PillSegmentedControl(
            options: [(SelectedPage.feed, "Feed"), (SelectedPage.saved, "Saved"), (SelectedPage.custom, "Custom")],
            selection: $viewModel.selected
        )
        .padding(.horizontal, AppMetrics.screenPadding)
        .onChange(of: viewModel.selected) { newValue in
            viewModel.loadMoreQuotes()
        }
    }

    private func emptyState(icon: String, title: String, message: String) -> some View {
        let palette = sharedVars.palette
        return VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(palette.accent)
                .frame(width: 64, height: 64)
                .background(Circle().fill(palette.accent.opacity(0.16)))
            Text(title)
                .font(AppFont.sectionTitle)
                .foregroundColor(palette.text)
            Text(message)
                .font(.subheadline)
                .foregroundColor(palette.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .modifier(CardStyling(padding: 28))
        .padding(.horizontal, AppMetrics.screenPadding)
    }

    private var quotesListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.selected == .custom {
                    customQuotesHeader
                }
                if viewModel.getPageSpecificQuotes().isEmpty {
                    switch viewModel.selected {
                        case .feed:
                            ProgressView()
                                .tint(sharedVars.palette.accent)
                                .scaleEffect(1.3)
                                .padding(.top, 80)
                        case .saved:
                            emptyState(icon: "bookmark", title: "Nothing saved yet",
                                       message: "Tap the bookmark on any quote in your feed to keep it here.")
                                .padding(.top, 24)
                        case .custom:
                            emptyState(icon: "quote.bubble", title: "Your own quotes",
                                       message: "Add quotes you wrote, heard from someone, or can't find in the app. They stay on this device, and your widget and notifications can show them.")
                    }
                } else {
                    ForEach(viewModel.getPageSpecificQuotes()) { quote in
                        if quote.isCustom {
                            SingleQuoteView(
                                quote: quote,
                                from: .standardView,
                                onEdit: { editorTarget = .edit(quote) },
                                onDelete: { quoteToDelete = quote }
                            )
                        } else {
                            SingleQuoteView(
                                quote: quote,
                                from: .standardView,
                                onBookmarkRemoved: viewModel.selected == .saved ? {
                                    viewModel.removeSavedQuote(quote)
                                } : nil
                            )
                        }
                    }
                }

                if viewModel.selected != .custom {
                    Color.clear.frame(height: 1)
                        .onAppear {
                            viewModel.checkMoreQuotesNeeded()
                        }
                    if viewModel.checkLimitReached() {
                        Text("You've reached the quote limit of \(DropletsViewModel.maxQuotes). Maybe take a break?")
                            .modifier(QuotesPageTextStyling())
                    }
                }
            }
            .padding(.top, 6)
            .padding(.bottom, 24)
        }
    }

    /// "Add a quote", plus a one-tap way to show custom quotes in the widget and notifications.
    private var customQuotesHeader: some View {
        let palette = sharedVars.palette
        return VStack(spacing: 10) {
            Button {
                editorTarget = .new
            } label: {
                SubmitButtonView(text: "Add a Quote", imageSystemName: "plus")
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityIdentifier("addCustomQuote")

            if !viewModel.customQuotes.isEmpty {
                if quoteCategory == .custom {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(palette.accent)
                        Text("Your widget and notifications show these quotes.")
                            .foregroundColor(palette.secondaryText)
                    }
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                } else {
                    Button {
                        quoteCategory = .custom
                        WidgetCenter.shared.reloadAllTimelines()
                        NotificationSchedulerService.shared.scheduleNotifications()
                    } label: {
                        SubmitButtonView(text: "Show These in My Widget", imageSystemName: "rectangle.stack", isPrimary: false)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
        }
        .padding(.horizontal, AppMetrics.screenPadding)
    }
}

enum CustomQuoteEditorTarget: Identifiable {
    case new
    case edit(Quote)

    var id: Int {
        switch self {
            case .new: return 0
            case .edit(let quote): return quote.id
        }
    }

    var quote: Quote? {
        if case .edit(let quote) = self { return quote }
        return nil
    }
}

/// Form for adding or editing one of the user's own quotes.
@available(iOS 16.0, *)
struct CustomQuoteEditor: View {
    @EnvironmentObject var sharedVars: SharedVarsBetweenTabs
    @Environment(\.dismiss) private var dismiss

    let editing: Quote?
    let onSave: (_ text: String, _ author: String) -> Void

    @State private var text: String
    @State private var author: String
    @FocusState private var isTextFocused: Bool

    static let maxLength = 500

    init(editing: Quote?, onSave: @escaping (_ text: String, _ author: String) -> Void) {
        self.editing = editing
        self.onSave = onSave
        _text = State(initialValue: editing?.text ?? "")
        _author = State(initialValue: editing?.author ?? "")
    }

    private var canSave: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Quote text", text: $text, axis: .vertical)
                        .lineLimit(3...8)
                        .font(.system(.body, design: .serif))
                        .focused($isTextFocused)
                        .onChange(of: text) { newValue in
                            if newValue.count > Self.maxLength {
                                text = String(newValue.prefix(Self.maxLength))
                            }
                        }
                        .accessibilityIdentifier("customQuoteText")
                    TextField("Author (optional)", text: $author)
                        .textInputAutocapitalization(.words)
                        .accessibilityIdentifier("customQuoteAuthor")
                } header: {
                    Text("Quote")
                } footer: {
                    Text("Only stored on this device. Short quotes fit the small widget best.")
                }
                .modifier(PaletteFormRowStyling())

                Section {
                    Button {
                        onSave(text, author)
                        dismiss()
                    } label: {
                        Text(editing == nil ? "Add Quote" : "Save Changes")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle(palette: sharedVars.palette))
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.5)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .accessibilityIdentifier("saveCustomQuote")
                }
            }
            .modifier(PaletteFormStyling())
            .onAppear {
                // Open the keyboard right away when adding a quote
                if editing == nil { isTextFocused = true }
            }
            .navigationTitle(editing == nil ? "New Quote" : "Edit Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
