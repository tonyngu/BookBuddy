//
//  MyBooksTableViewController.swift
//  BookBuddy
//
//  Created by Tony Nguyen on 5/4/2023.
//

import UIKit

class MyBooksTableViewController: UITableViewController, DatabaseListener, UIViewControllerTransitioningDelegate {
    

    @IBAction func showAboutButton(_ sender: Any) {
        showBottomCard()
    }
    
    func showBottomCard() {
        let slideVC = BottomCardViewController()
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        self.present(slideVC, animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationControlller(presentedViewController: presented, presenting: presenting)
    }
    
    let SECTION_BOOK = 0
    let SECTION_INFO = 1
    
    let CELL_BOOK = "BookCell"
    let CELL_INFO = "bookCountCell"
    var allBooks: [Book] = []
    weak var databaseController: DatabaseProtocol?
    
    func onBookListChange(bookList: [Book]) {
        // Update the allBooks property with the given bookList
        allBooks = bookList
        
        // Reload the tableView to reflect the changes
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_BOOK)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            databaseController = appDelegate.databaseController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allBooks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_BOOK {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath)
            
            // Configure the cell...
            let book = allBooks[indexPath.row]
            cell.textLabel?.text = book.title
            cell.detailTextLabel?.text = book.authors
            return cell
            
        } else {
            
            let infoCell = tableView.dequeueReusableCell(withIdentifier: "bookCountCell", for:
                                                            indexPath) as! BookCountTableViewCell
            infoCell.totalLabel?.text = "\(allBooks.count)"
            return infoCell
        }
        
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let book = allBooks[indexPath.row]
            self.databaseController?.deleteBook(bookData: book)
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        return "My Collection \(allBooks.count)"
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "bookDataSegue" {
            
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                let book = allBooks[indexPath.row]
                let destination = segue.destination as! BookDetailViewController
                destination.chosenBook = book
            }
        }
    }
}
