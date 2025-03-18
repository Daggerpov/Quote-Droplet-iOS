//
//  AuthorHelper.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-21.
//

import Foundation

public func isAuthorValid(authorGiven: String?) -> Bool {
    guard let author = authorGiven else { return false }
    return !(author.isEmpty || author == "Unknown Author" || author == "NULL")
}
