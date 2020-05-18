//
//  FeedTableViewController.swift
//  CoronaNews
//
//  Created by iosdev on 16.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class FeedTableViewController: UITableViewController, UISearchResultsUpdating, NewsAPIDelegate {
    
    //MARK: Properties
    var newsArray: [NewsArticles] = []
    var filteredNews = [NewsArticles]()
    let newsCollection = Firestore.firestore().collection("news")
    let bookmarkCollection = Firestore.firestore().collection("bookmarks")
    let newsAPI = NewsAPI()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsAPI.newsAPIDelegate = self
        
        getNewsFromFS()
        
        //Set a little bit more height to tableviewcells
        self.tableView.rowHeight = 150.0
        
        //searchController settings
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search..."
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    //MARK: Firebase and NewsAPI requests
    
    //Get the news from firestore
    func getNewsFromFS() {
        newsCollection.getDocuments() { (snapShot, error) in
            //Check if there is an error
            if let error = error {
                print("Error fetching documents from firestore: ", error.localizedDescription)
            } else {
                guard let documents = snapShot?.documents else { return }
                for document in documents {
                    let data = document.data()
                    
                    //Extract the data
                    let title = data["title"] as? String ?? ""
                    let author = data["author"] as? String ?? ""
                    let url = data["url"] as? String ?? ""
                    let urlToImage = data["urlToImage"] as? String ?? ""
                    let content = data["content"] as? String ?? ""
                    let publishedAt = data["publishedAt"] as? String ?? ""
                    let description = data["description"] as? String ?? ""
                    let documentId = document.documentID
                    
                    //Create newsArticle variable
                    let newsArticle = NewsArticles(author: author, title: title, articleDescription: description, url: url, urlToImage: urlToImage, publishedAt: publishedAt, content: content, documentId: documentId)
                    
                    //Append the article to the array
                    self.newsArray.append(newsArticle)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                self.newsAPI.getNews()
            }
        }
    }
    
    
    //NewsAPIDelegate function
    func newNews(_ news: News?) {
        //Loop through the articles which were fetched
        for article in news!.articles {
            
            //Compare the article URL to urls in news from firestore so there will be no duplicates saved
            let checkDuplicates = newsArray.contains(where: { (newsArticle) -> Bool in
                if newsArticle.url == article.url {
                    return true
                }
                return false
            })
            
            //If the same url was not found, add the article to firestore
            if checkDuplicates == false {
                var ref: DocumentReference? = nil
                ref = self.newsCollection.addDocument(data: [
                    "title": article.title ?? "",
                    "author": article.author ?? "",
                    "url": article.url ?? "",
                    "urlToImage": article.urlToImage ?? "",
                    "content": article.content ?? "",
                    "publishedAt": article.publishedAt ?? "",
                    "description": article.articleDescription ?? "",
                ]) {error in
                    if let error = error {
                        print("Error saving document: \(error)")
                    } else {
                        print("Document saved with ID: \(ref!.documentID)")
                    }
                }
            }
        }
    }
    
    //MARK: Search Bar
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(searchController.searchBar.text!)
    }
    
    func filterContentForSearch(_ searchText: String){
        filteredNews = self.newsArray.filter({(news: NewsArticles) -> Bool in
            return news.title!.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toArticleWebView", sender: newsArray[indexPath.row]);
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering(){
            return 1
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering(){
            return filteredNews.count
        } else {
            return newsArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as? FeedTableViewCell else {
            fatalError("The dequeued cell in not an instance of FeedCell")
        }
        
        let foundNewsArticle: NewsArticles
        if isFiltering() {
            foundNewsArticle = filteredNews[indexPath.row]
        } else {
            foundNewsArticle = newsArray[indexPath.row]
        }
        
        cell.titleLabel.text = foundNewsArticle.title
        cell.articleImage.sd_setImage(with: URL(string: foundNewsArticle.urlToImage ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addBookmarkAction = UIContextualAction(style: .normal, title: "Bookmark") { (Action, View, handler) in
            
            let userID = Auth.auth().currentUser?.uid
            let article = self.newsArray[indexPath.row]
            self.bookmarkCollection.document(userID ?? "").collection("userBookmarks").addDocument(data: [
                "title": article.title ?? "",
                "author": article.author ?? "",
                "url": article.url ?? "",
                "urlToImage": article.urlToImage ?? "",
                "content": article.content ?? "",
                "publishedAt": article.publishedAt ?? "",
                "description": article.articleDescription ?? "",
                "documentID": article.documentId ?? "",
            ]) { error in
                if let error = error {
                    print("Error adding a bookmark: ", error.localizedDescription)
                } else {
                    print("Bookmark added!")
                }
            }
            handler(true)
        }
        
        let swipeAction = UISwipeActionsConfiguration(actions: [addBookmarkAction])
        return swipeAction
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toArticleWebView") {
            if let destinationVC = segue.destination as? FeedWebViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let selectedNewsArticle: NewsArticles
                    if isFiltering() {
                        selectedNewsArticle = filteredNews[indexPath.row]
                    } else {
                        selectedNewsArticle = newsArray[indexPath.row]
                    }
                    destinationVC.newsArticles = selectedNewsArticle
                }
            }
        }
    }
}
