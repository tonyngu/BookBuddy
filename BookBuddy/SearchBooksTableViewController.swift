//
//  SearchBooksTableViewController.swift
//  BookBuddy
//
//  Created by Tony Nguyen on 5/4/2023.
//

import UIKit


class SearchBooksTableViewController: UITableViewController, UISearchBarDelegate {
    
    let MAX_ITEMS_PER_REQUEST = 40
    let MAX_REQUESTS = 10
    
    var currentRequestIndex: Int = 0

    
    weak var databaseController: DatabaseProtocol?
    
    let CELL_BOOK = "bookCell"
    let REQUEST_STRING = "https://www.googleapis.com/books/v1/volumes?q="
//    let REQUEST_STRING = "https://openlibrary.org/works/"
//    let REQUEST_STRING = "https://api2.isbndb.com/book/"

    
    var newBooks = [BookData]()
    
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Add a loading indicator view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    func requestBooksNamed(_ bookName: String) async {
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "www.googleapis.com"
//        searchURLComponents.host = "api2.isbndb.com"
        searchURLComponents.path = "/books/v1/volumes"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "maxResults", value: "\(MAX_ITEMS_PER_REQUEST)"), URLQueryItem(name: "startIndex", value: "\(currentRequestIndex * MAX_ITEMS_PER_REQUEST)"),
            URLQueryItem(name: "q", value: bookName)
        ]
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL.")
            return
        }
//        guard let queryString = bookName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
//            print("Query string can't be encoded.")
//            return
//        }
//
//        guard let requestURL = URL(string: REQUEST_STRING + queryString) else {
//            print("Invalid URL.")
//            return
//        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            
            do {
                let decoder = JSONDecoder()
                let volumeData = try decoder.decode(VolumeData.self, from: data)
                
                if let books = volumeData.books {
                    newBooks.append(contentsOf: books)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    if books.count == MAX_ITEMS_PER_REQUEST, currentRequestIndex + 1 < MAX_REQUESTS {
                        currentRequestIndex += 1
                        await requestBooksNamed(bookName)
                    }
                }
               
            }
            catch let error {
                print(error)
            }
            
        }
        catch let error {
            print(error)
        }
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        newBooks.removeAll()
        tableView.reloadData()
        

        
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        
        Task {
            URLSession.shared.invalidateAndCancel()
            currentRequestIndex = 0
            
            await requestBooksNamed(searchText)
        }
    }
    
    
    
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newBooks.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath)
        
        // Configure the cell...
        let book = newBooks[indexPath.row]
        cell.textLabel?.text = book.title
        cell.detailTextLabel?.text = book.authors
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = newBooks[indexPath.row]
        let _ = databaseController?.addBook(bookData: book)
        navigationController?.popViewController(animated: true)
    }

    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
