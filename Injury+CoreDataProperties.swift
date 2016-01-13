//
//  Injury+CoreDataProperties.swift
//  HopefullyLastOne
//
//  Created by Seanmichael Stanley on 12/9/15.
//  Copyright © 2015 James Tapia. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Injury {

    @NSManaged var severity: NSNumber?
    @NSManaged var prevention: String?
    @NSManaged var name: String?
    @NSManaged var injuryDesc: String?
    @NSManaged var date: NSDate?
    @NSManaged var exercises: NSOrderedSet?

	func stringForDate() -> String {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy.M.d"
		if let date = date {
			return dateFormatter.stringFromDate(date)
		} else {
			return ""
		}
	}
}
