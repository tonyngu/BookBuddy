//
//  BookDetailViewController.swift
//  BookBuddy
//
//  Created by Tony Nguyen on 24/5/2023.
//

import UIKit



enum BookListError: Error {
    case invalidServerResponse
    case invalidShowURL
    case invalidEpisodeImageURL
}

class BookDetailViewController: UIViewController {
    
    //    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten:
    //                    Int64, totalBytesExpectedToWrite: Int64) {
    //        if totalBytesExpectedToWrite > 0 {
    //            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    //            debugPrint("Progress \(downloadTask) \(progress)")
    //        }
    //    }
    //
    //    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    //        do {
    //            let data = try Data(contentsOf: location)
    //            // Images can only be loaded from the main thread
    //            DispatchQueue.main.async {
    //                self.BookCoverView.image = UIImage(data: data)
    //            }
    //        } catch let error {
    //            print(error.localizedDescription)
    //        }
    //    }
    
    @IBOutlet weak var overviewDescriptionView: UILabel!
    @IBOutlet weak var overviewTitileView: UILabel!
    @IBOutlet weak var overviewAuthorView: UILabel!
    @IBOutlet weak var BookCoverView: UIImageView!
        
    var chosenBook: Book?
    var bookCover: [BookData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let book = chosenBook {
            navigationItem.title = book.title
            overviewDescriptionView.text = book.bookDescription
            overviewTitileView.text = book.title
            overviewAuthorView.text = book.authors
            
            let bookCover = bookCover
            BookCoverView?.image = nil
            
            if let image = bookCover.image {
                BookCoverView?.image = image
            }
            else if bookCover.imageIsDownloading == false, let imageURL = bookCover.imageURL?.smallThumbnail {
                let requestURL = URL(string: imageURL)
                if let requestURL {
                    Task{
                        print("Downloading image: " + imageURL)
                        bookCover.imageIsDownloading = true
                        do {
                            let (data, response) = try await URLSession.shared.data(from: requestURL)
                            guard let httpResponse = response as? HTTPURLResponse,
                                  httpResponse.statusCode == 200 else {
                                bookCover.imageIsDownloading = false
                                throw BookListError.invalidServerResponse
                            }
                            if let image = UIImage(data: data) {
                                print("Image is downloadd" + imageURL)
                                bookCover.image = image
                                await MainActor.run {
                                    viewDidLoad.reload()
                                }
                            }
                            else {
                                print("Image invalid:" + imageURL)
                                bookCover.imageIsDownloading = false
                            }
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                else {
                    print("Error: URL not valid: " + imageURL)
                }
                
                
                
                //To download image from URL
                
                //            let config = URLSessionConfiguration.background(withIdentifier: "")
                //            let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
                //            let url = URL(string: book.imageURL!)
                //            let task = session.downloadTask(with: url!)
                //            task.resume()
                
                
            }
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

