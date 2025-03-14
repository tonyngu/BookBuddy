//
//  BookDetailViewController.swift
//  BookBuddy
//
//  Created by Tony Nguyen on 24/5/2023.
//

import UIKit

class BookDetailViewController: UIViewController, URLSessionTaskDelegate, URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten:
                    Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            debugPrint("Progress \(downloadTask) \(progress)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            // Images can only be loaded from the main thread
            DispatchQueue.main.async {
                self.BookCoverView.image = UIImage(data: data)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @IBOutlet weak var DescriptionView: UITextView!
    @IBOutlet weak var TitleView: UILabel!
    @IBOutlet weak var AuthorView: UILabel!
    @IBOutlet weak var BookCoverView: UIImageView!
    
    var chosenBook: Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display book data that got passed from MyBooksTableViewController
        if let book = chosenBook {
            navigationItem.title = book.title
            DescriptionView.text = book.bookDescription
            TitleView.text = book.title
            AuthorView.text = book.authors
            
            //To download image from URL
            BookCoverView?.image = nil
            let config = URLSessionConfiguration.background(withIdentifier: "")
            let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
            let url = URL(string: book.imageURL!)
            let task = session.downloadTask(with: url!)
            task.resume()
               
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "reminderSegue" {
            let book = chosenBook
            let bookName = book!.title
            let destination = segue.destination as! NotificationViewController
            destination.remindedBookTitle = bookName!
        }
    }
    
    
    
}
