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
    
    @IBOutlet weak var overviewDescriptionView: UILabel!
    @IBOutlet weak var overviewTitileView: UILabel!
    @IBOutlet weak var overviewAuthorView: UILabel!
    @IBOutlet weak var overviewPageCount: UILabel!
    
    @IBOutlet weak var BookCoverView: UIImageView!
    

    var chosenBook: Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let book = chosenBook {
            navigationItem.title = book.title
            overviewDescriptionView.text = book.bookDescription
            overviewTitileView.text = book.title
            overviewAuthorView.text = book.authors
            overviewPageCount.text = book.pageCount
            
            //To download image from URL
            let imageURL = book.imageURL
            let config = URLSessionConfiguration.background(withIdentifier: "edu.monash.fit3178.week05")
            let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
            let url = URL(string: imageURL!)
            let task = session.downloadTask(with: url!)
            task.resume()
            
            
            
            
            
            
        }
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
