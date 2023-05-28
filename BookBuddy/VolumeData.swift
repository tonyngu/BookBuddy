//
//  VolumeData.swift
//  BookBuddy
//
//  Created by Tony Nguyen on 4/4/2023.
//

import UIKit

class VolumeData: NSObject, Decodable {
    var books: [BookData]?
    
    private enum CodingKeys: String, CodingKey {
        case books = "items"
        
        
    }

}
