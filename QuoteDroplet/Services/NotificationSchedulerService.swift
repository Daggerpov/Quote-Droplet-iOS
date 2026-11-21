//
//  NotificationSchedulerService.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-03-22.
//

import Foundation
import UserNotifications

private var scheduledNotificationIDs: Set<String> = Set() // for the quotes shown already

// Singleton class
@available(iOS 15, *)
class NotificationSchedulerService {
    static let shared = NotificationSchedulerService(localQuotesService: LocalQuotesService())
    
    // notifications default settings:
    private var defaultNotificationTime: Date = Calendar.current.date(byAdding: .minute, value: 3, to: Date.now) ?? Date.now
    
    public static var isDefaultConfigOverwritten: Bool = false
    
    public static var previouslySelectedNotificationTime: Date = Calendar.current.date(byAdding: .minute, value: 3, to: Date.now) ?? Date.now
    public static var previouslySelectedNotificationCategory: QuoteCategory = QuoteCategory.all
    
    private var quotes = [QuoteJSON]()
    
    public static var defaultScheduledNotificationTime: Date = Calendar.current.date(byAdding: .minute, value: 3, to: Date.now) ?? Date.now
    
    let localQuotesService: LocalQuotesService
    
    private init(localQuotesService: LocalQuotesService) {
        self.localQuotesService = localQuotesService
        fetchQuotesFromJSON()
    }
    
    func fetchQuotesFromJSON() {
        quotes = localQuotesService.loadQuotesFromJSON()
    }
    
    func scheduleNotifications() {
        // removed toggle check to make sure user has opted in; simply notififying no matter if opted in.
        if NotificationSchedulerService.isDefaultConfigOverwritten {
            scheduleNotifications(notificationTime: NotificationSchedulerService.previouslySelectedNotificationTime, quoteCategory: NotificationSchedulerService.storedQuoteCategory, defaults: true)
        } else {
            NotificationSchedulerService.defaultScheduledNotificationTime = defaultNotificationTime
            scheduleNotifications(notificationTime: defaultNotificationTime, quoteCategory: NotificationSchedulerService.storedQuoteCategory, defaults: true)
        }
    }

    /// The category picked in Settings > Quotes (shared with the widget), so notifications follow it across launches.
    static var storedQuoteCategory: QuoteCategory {
        if let raw = UserDefaults(suiteName: "group.selectedSettings")?.string(forKey: "quoteCategory"),
           let category = QuoteCategory(rawValue: raw) {
            return category
        }
        return .all
    }
    
    func scheduleNotifications(notificationTime: Date, quoteCategory: QuoteCategory, defaults: Bool) {
        // if given defaults -> don't want to overrite selections.
        
        // if not given defaults, so real selections, overwrite so that if default
        // notification scheduler gets called, that's what it'll use.
        
        if defaults == false {
            NotificationSchedulerService.previouslySelectedNotificationTime = notificationTime
            NotificationSchedulerService.previouslySelectedNotificationCategory = quoteCategory
            NotificationSchedulerService.isDefaultConfigOverwritten = true
        }
        
        // Cancel existing notifications to reschedule them with the new time
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let classification = quoteCategory.displayName
        
        // Create a calendar instance
        let calendar = Calendar.current
        
        // Get the current date
        let currentDate = calendar.startOfDay(for: Date())
        
        // Iterate over 60 days
        for i in 0..<60 {
            guard let futureDate = calendar.date(byAdding: .day, value: i, to: currentDate) else {
                print("Error: Unable to calculate future date.")
                continue
            }
            
            var triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationTime)
            triggerDate.year = calendar.component(.year, from: futureDate)
            triggerDate.month = calendar.component(.month, from: futureDate)
            triggerDate.day = calendar.component(.day, from: futureDate)
            
            // Create notification content
            let content = UNMutableNotificationContent()
            
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "sound-for-noti-water-drip-pixabay.mp3"))
            
            let shortQuotes = quotes.filter{ $0.text.count <= 100 }
            
            // Fetch a random quote for the specified classification
            var randomQuote: QuoteJSON
            if classification.lowercased() == "all" {
                guard let randomElement = shortQuotes.randomElement() else {
                    print("Error: Unable to retrieve a random quote.")
                    continue
                }
                randomQuote = randomElement
                content.title = "Quote Droplet"
            } else if classification.lowercased() == "saved" {
                let bookmarkedQuotes = localQuotesService.getBookmarkedQuotes().map { $0.toQuoteJSON() }
                
                if !bookmarkedQuotes.isEmpty {
                    let randomIndex = Int.random(in: 0..<bookmarkedQuotes.count)
                    
                    let randomElement = bookmarkedQuotes[randomIndex]
                    randomQuote = randomElement
                    
                    content.title = "Quote Droplet: Saved Quotes"
                    
                    // Now randomQuote is of type Quote
                    // Proceed with using randomQuote as needed
                } else {
                    // Handle case where bookmarkedQuotes is empty
                    randomQuote = QuoteJSON(id: 9999999, text: "Please add a quote to saved by clicking the save button under a quote in the app's \"Droplets\" tab", author: "", classification: "Saved")
                    content.title = "Quote Droplet: No Saved Quotes Added"
                    
                }
                
            } else if classification.lowercased() == QuoteCategory.custom.lowercasedName {
                if let custom = localQuotesService.getCustomQuotes().randomElement() {
                    randomQuote = custom.toQuoteJSON()
                    content.title = "Quote Droplet: Your Quotes"
                } else {
                    randomQuote = QuoteJSON(id: 9999998, text: "Add your own quotes in the app's \"Droplets\" tab, under Custom", author: "", classification: "Custom")
                    content.title = "Quote Droplet: No Custom Quotes Added"
                }
            } else {
                // Fetch a random quote with the specified classification
                let filteredQuotes = shortQuotes.filter { $0.classification.lowercased() == classification.lowercased() }
                guard let randomElement = filteredQuotes.randomElement() else {
                    print("Error: Unable to retrieve a random quote.")
                    continue
                }
                randomQuote = randomElement
                content.title = "Quote Droplet: \(classification)"
            }
            
            //adjusted
            if (isAuthorValid(authorGiven: randomQuote.author)) {
                content.body = "\(randomQuote.text)\n— \(randomQuote.author)"
            } else {
                content.body = "\(randomQuote.text)"
            }
            
            // Add randomQuote's id to userInfo
            content.userInfo = ["quoteID": randomQuote.id]
            
            // Calculate the trigger date for the current notification
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            // Generate a unique identifier for this notification
            let notificationID = UUID().uuidString
            
            // Create notification request
            let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
            
            // Schedule the notification
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
}
