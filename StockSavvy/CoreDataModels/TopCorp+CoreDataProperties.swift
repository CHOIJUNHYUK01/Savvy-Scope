//
//  TopCorp+CoreDataProperties.swift
//  StockSavvy
//
//  Created by CHOIJUNHYUK on 4/15/24.
//
//

import Foundation
import CoreData


extension TopCorp {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TopCorp> {
        return NSFetchRequest<TopCorp>(entityName: "TopCorp")
    }

    @NSManaged public var rank: Int32
    @NSManaged public var title: String?
    @NSManaged public var symbol: String?
    @NSManaged public var marketcap: String?
    @NSManaged public var currentPrice: String?
    @NSManaged public var date: Date?
    @NSManaged public var arise: Bool
    
    var dateString: String? {
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = self.date else { return "" }
        let savedDateString = myFormatter.string(from: date)
        return savedDateString
    }
    
    var timeString: String? {
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "HH:mm"
        guard let date = self.date else { return "" }
        let savedDateString = myFormatter.string(from: date)
        return savedDateString
    }

}

extension TopCorp : Identifiable {

}
