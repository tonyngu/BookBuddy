//
//  DatabaseProtocol.swift
//  BookBuddy
//
//  Created by Tony Nguyen on 6/4/2023.
//

import Foundation


protocol DatabaseListener: AnyObject {
    func onBookListChange(bookList: [Book])
}

protocol DatabaseProtocol: AnyObject {
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func addBook(bookData: BookData) -> Book
    func cleanup()
}

