//
//  Token+CoreDataProperties.swift
//  StockSavvy
//
//  Created by CHOIJUNHYUK on 4/15/24.
//
//

import Foundation
import CoreData


extension Token {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Token> {
        return NSFetchRequest<Token>(entityName: "Token")
    }

    @NSManaged public var date: Date?
    @NSManaged public var token: String?

    var dateString: String? {
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = self.date else { return "" }
        let savedDateString = myFormatter.string(from: date)
        return savedDateString
    }
}

extension Token : Identifiable {

}
