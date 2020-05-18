//
//  ArticleCommentViewController.swift
//  CoronaNews
//
//  Created by iosdev on 4.5.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import UIKit
import Firebase

class ArticleCommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ArticleCommentDelegate {
    
    //MARK: Properties
    let firestore = Firestore.firestore()
    var newsArticle: NewsArticles!
    var newsRef: DocumentReference!
    var comments = [Comment]()
    var commentListener: ListenerRegistration!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
        
        commentTextField.delegate = self
        updateAddButtonState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("ID: ", self.newsArticle as Any)
        commentListener = firestore.collection("news").document(self.newsArticle.documentId)
            .collection("comments")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener({ (snapshot, error) in
                
                guard let snapshot = snapshot else {
                    debugPrint("Error fetching comments: \(error!)")
                    return
                }
                self.comments.removeAll()
                self.comments = Comment.parseData(snapshot: snapshot)
                self.tableView.reloadData()
            })
    }
    
    //MARK: TableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCommentCell", for: indexPath) as? ArticleCommentTableViewCell {
            
            cell.configure(comment: comments[indexPath.row], delegate: self)
            return cell
        }
        return UITableViewCell()
    }
    
    //MARK: TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateAddButtonState()
    }
    
    //MARK: Actions
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addComment(_ sender: Any) {
        if commentTextField.text != "" {
            let now = Date()
            let timestamp = Timestamp(date: now)
            self.newsRef.collection("comments").addDocument(data: [
                "comment" : commentTextField.text ?? "",
                "timestamp" : timestamp,
                "username" : Auth.auth().currentUser?.displayName ?? "",
                "userId" : Auth.auth().currentUser?.uid ?? ""
                
            ]) { (err) in
                if let err = err {
                    debugPrint("Error adding document: \(err)")
                } else {
                    self.commentTextField.text = ""
                }
            }
        }
    }
    
    func deleteCommentTapped(comment: Comment) {
        let alert = UIAlertController(title: "Delete Comment", message: "Are you sure you want to delete?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Confirm", style: .default){ (action) in
            
            Firestore.firestore().collection("news").document(self.newsArticle.documentId).collection("comments").document(comment.documentId).delete(completion: {(error)
                in
                if let error = error {
                    debugPrint("Error deleting document: \(error)")
                }else{
                    alert.dismiss(animated: true, completion: nil)
                }
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    
    //MARK: Private methods
    
    private func updateAddButtonState() {
        let commentText = commentTextField.text ?? ""
        addButton.isEnabled = !commentText.isEmpty
    }
}
