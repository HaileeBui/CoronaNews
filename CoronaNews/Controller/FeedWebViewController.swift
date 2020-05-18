//
//  FeedWebViewController.swift
//  CoronaNews
//
//  Created by iosdev on 24.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import UIKit
import WebKit
import Firebase

class FeedWebViewController: UIViewController {
    
    let firestore = Firestore.firestore()
    var newsArticles: NewsArticles!
    var newsRef: DocumentReference!
    var commentListener : ListenerRegistration!
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsRef = firestore.collection("news").document(newsArticles.documentId)
        let url = URL(string: newsArticles.url)
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowArticleComments" {
            if let destinationVC = segue.destination as? ArticleCommentViewController {
                destinationVC.newsRef = newsRef
                destinationVC.newsArticle = newsArticles
            }
        }
    }
}
