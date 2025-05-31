//
//  AuthorView.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-21.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct AuthorView: View {
	@ObservedObject var viewModel: AuthorViewModel
	@EnvironmentObject var sharedVars: SharedVarsBetweenTabs
	@State private var forceViewUpdate = UUID() // Change to UUID for better forcing

	@AppStorage(
		"widgetColorPaletteIndex",
		store: UserDefaults(suiteName: "group.selectedSettings")
	)
	var widgetColorPaletteIndex = 0

	// actual colors of custom:
	@AppStorage(
		"widgetCustomColorPaletteFirstIndex",
		store: UserDefaults(suiteName: "group.selectedSettings")
	)
	private var widgetCustomColorPaletteFirstIndex = "1C7C54"

	@AppStorage(
		"widgetCustomColorPaletteSecondIndex",
		store: UserDefaults(suiteName: "group.selectedSettings")
	)
	private var widgetCustomColorPaletteSecondIndex = "E2B6CF"

	@AppStorage(
		"widgetCustomColorPaletteThirdIndex",
		store: UserDefaults(suiteName: "group.selectedSettings")
	)
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
				// Author header with clickable name
				if let authorName = viewModel.quote.author,
					let encodedName = authorName.addingPercentEncoding(
						withAllowedCharacters: .urlQueryAllowed
					),
					let url = URL(
						string:
							"https://en.wikipedia.org/wiki/\(encodedName)"
					)
				{
					Link(destination: url) {
						Text("Quotes by \(viewModel.quote.author ?? "Author"):")
							.modifier(QuotesPageTitleStyling())
							.padding(.horizontal)
					}
				} else {
					Text("Quotes by \(viewModel.quote.author ?? "Author"):")
						.modifier(QuotesPageTitleStyling())
						.padding(.horizontal)
				}

				// Author image
				ZStack {
					Image("authorimageframe")
						.resizable()
						.frame(width: 200, height: 200)
						.foregroundColor(
							colorPalettes[safe: sharedVars.colorPaletteIndex]?[
								1
							] ?? .white
						)

					if let imageURL = viewModel.authorImageURL,
						let url = URL(string: imageURL)
					{
						AsyncImage(url: url) { phase in
							switch phase {
							case .empty:
								ProgressView()
							case .success(let image):
								image
									.resizable()
									.scaledToFill()
									.frame(width: 180, height: 180)
									.clipShape(Circle())
							case .failure:
								Image(systemName: "person.circle.fill")
									.resizable()
									.frame(width: 180, height: 180)
									.foregroundColor(
										colorPalettes[
											safe: sharedVars.colorPaletteIndex
										]?[2] ?? .gray
									)
							@unknown default:
								EmptyView()
							}
						}
					} else {
						Image(systemName: "person.circle.fill")
							.resizable()
							.frame(width: 180, height: 180)
							.foregroundColor(
								colorPalettes[
									safe: sharedVars.colorPaletteIndex
								]?[2] ?? .gray
							)
					}
				}
				.padding(.bottom, 10)

				// Debug text to check quotes
				Text("Quotes array count: \(viewModel.quotes.count)")
					.foregroundColor(.orange)
					.font(.headline)
					.padding(.top, 5)

				ScrollView {
					LazyVStack {
						if viewModel.isLoadingMore && viewModel.quotes.isEmpty {
							ProgressView()
								.scaleEffect(1.5)
								.padding()

							Text("Loading Quotes...")
								.modifier(QuotesPageTextStyling())
						} else if viewModel.quotes.isEmpty {
							Text("No quotes found for this author")
								.modifier(QuotesPageTextStyling())
								.padding()
						} else {
							Text("Found \(viewModel.quotes.count) quotes")
								.foregroundColor(.green)
								.padding(.top)
							
							ForEach(Array(viewModel.quotes.enumerated()), id: \.element.id) { index, quote in
								VStack {
									Text("Quote #\(index + 1): \(quote.text ?? "No content")")
										.padding()
										.background(Color.gray.opacity(0.2))
										.cornerRadius(8)
										.padding(.horizontal)
									
									SingleQuoteView(quote: quote, from: .authorView)
										.id(quote.id)
								}
							}
						}
						
						Color.clear.frame(height: 1)
							.onAppear {
								if !viewModel.isLoadingMore
									&& viewModel.quotes.count
										< AuthorViewModel.maxQuotes
								{
									viewModel.loadMoreQuotes()
								}
							}
						Spacer()

						VStack {
							Text(
								"Missing a quote from this author?\nI'd greatly appreciate submissions:"
							)
							.modifier(QuotesPageTextStyling())

							SubmitView(
								viewModel: SubmitViewModel(
									apiService: viewModel.apiService
								)
							)
						}

						if !viewModel.isLoadingMore {
							if viewModel.quotes.count
								>= AuthorViewModel.maxQuotes
							{
								Text(
									"You've reached the quote limit of \(AuthorViewModel.maxQuotes). Maybe take a break?"
								)
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
				print("🔄 AuthorView appeared - Loading quotes for \(viewModel.quote.author ?? "unknown")")
				sharedVars.colorPaletteIndex = widgetColorPaletteIndex

				colorPalettes[3][0] = Color(
					hex: widgetCustomColorPaletteFirstIndex
				)
				colorPalettes[3][1] = Color(
					hex: widgetCustomColorPaletteSecondIndex
				)
				colorPalettes[3][2] = Color(
					hex: widgetCustomColorPaletteThirdIndex
				)

				// Load author image
				if let authorName = viewModel.quote.author {
					viewModel.loadAuthorImage(authorName: authorName)
				}
			}
			.id(forceViewUpdate) // Force the entire view to update with a UUID
			.onChange(of: viewModel.quotes) { _ in
				print("📱 Quotes changed: \(viewModel.quotes.count)")
				// Force view to update
				forceViewUpdate = UUID()
			}
		}
	}
}
