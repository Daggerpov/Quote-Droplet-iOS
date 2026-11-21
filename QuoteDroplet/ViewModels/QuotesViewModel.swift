//
//  QuotesViewModel.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-24.
//

import Foundation

@available(iOS 15, *)
class QuotesViewModel: ObservableObject{
    @Published var notificationTime: Date = Date()
    @Published var notificationScheduledTimeMessage: String = ""
    @Published var counts: [String: Int] = [:]
    @Published var isTimePickerExpanded: Bool = false
    
    private var showNotificationPicker: Bool = false
    private var notificationTimeCase: NotificationTime = .defaultScheduled
    
    let localQuotesService: ILocalQuotesService
    let apiService: IAPIService
    
    init(localQuotesService: ILocalQuotesService, apiService: IAPIService) {
        self.localQuotesService = localQuotesService
        self.apiService = apiService
        if UserDefaults.standard.value(forKey: "isFirstLaunch") as? Bool ?? true {
            UserDefaults.standard.setValue(false, forKey: "isFirstLaunch")
        }
    }
    
    public func initializeCounts() -> Void {
        getCategoryCounts { [weak self] fetchedCounts in
            guard let self = self else { return }
            self.counts = fetchedCounts
        }
    }
    
    public func fetchNotificationScheduledTimeInfo () -> Void {
        self.notificationTimeCase = getIsDefaultConfigOverwritten() ? .previouslySelected : .defaultScheduled
        
        self.notificationScheduledTimeMessage = "You currently have daily notifications \((notificationTimeCase == .defaultScheduled) ? "automatically " : "")scheduled for: \n"
    }
    
    public func getNotificationTime() -> Date {
        switch self.notificationTimeCase {
            case .previouslySelected:
                return NotificationSchedulerService.previouslySelectedNotificationTime
            case .defaultScheduled:
                return NotificationSchedulerService.defaultScheduledNotificationTime
        }
    }
    
    public func getIsDefaultConfigOverwritten () -> Bool {
        return NotificationSchedulerService.isDefaultConfigOverwritten
    }
    
    public func scheduleNotificationsAction() {
        if NotificationSchedulerService.isDefaultConfigOverwritten {
            self.notificationTime = NotificationSchedulerService.previouslySelectedNotificationTime
        } else {
            self.notificationTime = NotificationSchedulerService.defaultScheduledNotificationTime
        }
        self.isTimePickerExpanded.toggle()
    }
    
    private func getCategoryCounts(completion: @escaping ([String: Int]) -> Void) -> Void {
        let group: DispatchGroup = DispatchGroup()
        for category in QuoteCategory.allCases {
            group.enter()
            if category == .bookmarkedQuotes {
                self.getBookmarkedQuotesCount { [weak self] bookmarkedCount in
                    guard let self = self else { return }
                    self.counts[category.rawValue] = bookmarkedCount
                    group.leave()
                }
            } else if category == .custom {
                self.counts[category.rawValue] = self.localQuotesService.getCustomQuotes().count
                group.leave()
            } else {
                self.apiService.getCountForCategory(category: category) { [weak self] categoryCount in
                    guard let self = self else { return }
                    self.counts[category.rawValue] = categoryCount
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            completion(counts)
        }
    }
    
    private func getBookmarkedQuotesCount(completion: @escaping (Int) -> Void) -> Void {
        let bookmarkedQuotes = self.localQuotesService.getBookmarkedQuotes()
        completion(bookmarkedQuotes.count)
    }
}
