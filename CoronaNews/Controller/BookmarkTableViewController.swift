//
//  BookmarkTableViewController.swift
//  CoronaNews
//
//  Created by iosdev on 4.5.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class BookmarkTableViewController: UITableViewController {

    //MARK: Properties
    var bookmarks = [NewsArticles]()
    var ids = [String]()
    let bookmarksCollection = Firestore.firestore().collection("bookmarks")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 150
        self.tableView.tableFooterView = UIView()
        navigationItem.rightBarButtonItem = editButtonItem
        getBookmarks()
    }
    
    func getBookmarks() {
        let userID = Auth.auth().currentUser?.uid
        self.bookmarksCollection.document(userID ?? "").collection("userBookmarks").getDocuments() { (snapshot, error) in
            if let error = error {
                print("Error getting bookmarks: ", error.localizedDescription)
            } else {
                guard let documents = snapshot?.documents else { return }
                
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
                    let documentId = data["documentID"] as? String ?? ""
                    let id = document.documentID
                    
                    //Create newsArticle variable
                    let newsArticle = NewsArticles(author: author, title: title, articleDescription: description, url: url, urlToImage: urlToImage, publishedAt: publishedAt, content: content, documentId: documentId)
                    
                    //Append the article to the array
                    self.bookmarks.append(newsArticle)
                    self.ids.append(id)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath) as? BookmarkTableViewCell
        
        let bookmark = bookmarks[indexPath.row]
        
        cell?.newsTitleLabel.text = bookmark.title
        cell?.newsImage.sd_setImage(with: URL(string: bookmark.urlToImage ?? ""), placeholderImage: UIImage(named: "placeholder.png"))
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Are you sure?", message: "Do you really want to delete the bookmark?", preferredStyle: .actionSheet)
            
            let delete = UIAlertAction(title: "Delete", style: .destructive) { action in
                let userID = Auth.auth().currentUser?.uid
                let documentID = self.ids[indexPath.row]
                self.bookmarksCollection.document(userID ?? "").collection("userBookmarks").document(documentID ).delete(completion: { error in
                    if let error = error {
                        print("Error deleting document: ", error.localizedDescription)
                    } else {
                        self.bookmarks.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        alert.dismiss(animated: true, completion: nil)
                    }
                    
                })
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(delete)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowArticle" {
            if let destinationVC = segue.destination as? FeedWebViewController {
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    destinationVC.newsArticles = bookmarks[indexPath.row]
                }
            }
        }
    }

}
