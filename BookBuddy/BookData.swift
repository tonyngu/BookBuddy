//
//  BookData.swift
//  BookBuddy
//
//  Created by Tony Nguyen on 4/4/2023.
//

import UIKit

class BookData: NSObject, Decodable {
    
    var isbn13: String?
    var title: String
    var authors: String?
    var publisher: String?
    var publicationDate: String?
    var bookDescription: String?
    var imageURL: String?
    var pageCount: String?

    
    //use to track image download
//    var image: UIImage?
//    var imageIsDownloading: Bool = false
    
    private enum RootKeys: String, CodingKey {
        case volumeInfo
    }
    
    private enum BookKeys: String, CodingKey {
        case title
        case publisher
        case publicationDate = "publishedDate"
        case bookDescription = "description"
        case authors
        case industryIdentifiers
        case imageLinks
        case pageCount = "pageCount"


    }
    
    private enum ImageKeys: String, CodingKey {
        case smallThumbnail
    }
    

    
    private struct ISBNCode: Decodable {
        var type: String
        var identifier: String
    }
    
    required init(from decoder: Decoder) throws {
        // Get the root container first
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        
        // Get the book container for most info
        let bookContainer = try rootContainer.nestedContainer(keyedBy: BookKeys.self, forKey: .volumeInfo)
        // Get the book info
            title = try bookContainer.decode(String.self, forKey: .title)
            publisher = try? bookContainer.decode(String.self, forKey: .publisher)
            publicationDate = try? bookContainer.decode(String.self, forKey: .publicationDate)
            bookDescription = try? bookContainer.decode(String.self, forKey: .bookDescription)
            pageCount = try? bookContainer.decode(String.self, forKey: .pageCount)


        // Get the image links container for the thumbnail
        let imageContainer = try? bookContainer.nestedContainer(keyedBy:
        ImageKeys.self, forKey: .imageLinks)
        
        
        // Get authors as an array then compact
        if let authorArray = try? bookContainer.decode([String].self, forKey:
        .authors) {
        authors = authorArray.joined(separator: ", ")
        }
        
        // ISBN 13 takes a little more work to get done
        // First get the ISBNCodes as an array of ISBNCode
        if let isbnCodes = try? bookContainer.decode([ISBNCode].self, forKey: .industryIdentifiers) {
        // Loop through array and find the ISBN13
            for code in isbnCodes {
                if code.type == "ISBN_13" {
                    isbn13 = code.identifier
                }
            }
        }
        
        // Lastly get the image thumbnail from the imageContainer
        imageURL = try imageContainer?.decode(String.self, forKey: .smallThumbnail)


    }



}
