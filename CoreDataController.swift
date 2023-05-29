//
//  CoreDataController.swift
//  BookBuddy
//
//  Created by Tony Nguyen on 6/4/2023.
//

import UIKit
import CoreData

class CoreDataController: NSObject, NSFetchedResultsControllerDelegate, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var allBooksFetchedResultsController: NSFetchedResultsController<Book>?
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "BookDataModel")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error {
                fatalError("Failed to load Core Data stack with error: \(error)")
            }
        }
        
        super.init()
    }
    
    func fetchAllBooks() -> [Book] {
        if allBooksFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            
            allBooksFetchedResultsController = NSFetchedResultsController<Book>(
                fetchRequest:fetchRequest, managedObjectContext:
                    persistentContainer.viewContext, sectionNameKeyPath: nil,
                cacheName: nil)
            
            allBooksFetchedResultsController?.delegate = self
            
            do {
                try allBooksFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        if let books = allBooksFetchedResultsController?.fetchedObjects {
            return books
        }
        return [Book]()
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        listener.onBookListChange(bookList: fetchAllBooks())
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addBook(bookData: BookData) -> Book {
        let book = NSEntityDescription.insertNewObject(forEntityName: "Book",
                                                       into: persistentContainer.viewContext) as! Book
        book.authors = bookData.authors
        book.bookDescription = bookData.bookDescription
        book.imageURL = bookData.imageURL
        book.isbn13 = bookData.isbn13
        book.publicationDate = bookData.publicationDate
        book.publisher = bookData.publisher
        book.title = bookData.title
        book.pageCount = bookData.pageCount
        
        return book
    }
    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data with error \(error)")
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        listeners.invoke() { listener in
            listener.onBookListChange(bookList: fetchAllBooks())
        }
    }
    
    
}
