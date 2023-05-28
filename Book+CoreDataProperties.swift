//
//  Book+CoreDataProperties.swift
//  BookBuddy
//
//  Created by Tony Nguyen on 6/4/2023.
//
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var authors: String?
    @NSManaged public var bookDescription: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var isbn13: String?
    @NSManaged public var publicationDate: String?
    @NSManaged public var publisher: String?
    @NSManaged public var title: String?

}

extension Book : Identifiable {

}
