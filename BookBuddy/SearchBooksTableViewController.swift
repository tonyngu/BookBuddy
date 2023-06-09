//
//  SearchBooksTableViewController.swift
//  BookBuddy
//
//  Created by Tony Nguyen on 5/4/2023.
//

import UIKit


class SearchBooksTableViewController: UITableViewController, UISearchBarDelegate {
    

    // Maximum items can be display with 1 search
    let MAX_ITEMS_PER_REQUEST = 40
    let MAX_REQUESTS = 10
    
    var currentRequestIndex: Int = 0

    
    weak var databaseController: DatabaseProtocol?
    
    let CELL_BOOK = "bookCell"
    let REQUEST_STRING = "https://www.googleapis.com/books/v1/volumes?q="


    // Array of book to display to the user
    var newBooks = [BookData]()
    
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        
        // Create the search controller and attach it to the navigation item
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
    
    // A method to call the API to request book information
    func requestBooksNamed(_ bookName: String) async {
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "www.googleapis.com"
        searchURLComponents.path = "/books/v1/volumes"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "maxResults", value: "\(MAX_ITEMS_PER_REQUEST)"), URLQueryItem(name: "startIndex", value: "\(currentRequestIndex * MAX_ITEMS_PER_REQUEST)"),
            URLQueryItem(name: "q", value: bookName)
        ]
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL.")
            return
        }

        
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            
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

    // Called if the user hits enter or taps the search button after typing in the search field.
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        newBooks.removeAll()
        tableView.reloadData()
        

        // Guard statement if the search bar text is empty or nil and return imediately.
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
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows
        return newBooks.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath)
        
        // Dequeue a regular cell using the CELL_BOOK identifier. Get the specified book from the newBooks array and set the cell labels with the book title and authors
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
    
}
