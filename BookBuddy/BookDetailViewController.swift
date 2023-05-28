//
//  BookDetailViewController.swift
//  BookBuddy
//
//  Created by Tony Nguyen on 24/5/2023.
//

import UIKit

class BookDetailViewController: UIViewController {
    @IBOutlet weak var overviewDescriptionView: UILabel!
    
    @IBOutlet weak var overViewImageView: UIImageView!
    @IBOutlet weak var overviewTitileView: UILabel!
    @IBOutlet weak var overviewAuthorView: UILabel!
    @IBOutlet weak var overviewIsbn13View: UILabel!
    
    
    @IBOutlet weak var BookCoverView: UIImageView!
    var chosenBook: Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let book = chosenBook {
            navigationItem.title = book.title
            overviewDescriptionView.text = book.bookDescription
            overviewTitileView.text = book.title
            overviewAuthorView.text = book.authors
            overviewIsbn13View.text = book.isbn13
            
//            overViewImageView.String = book.imageURL
            
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
