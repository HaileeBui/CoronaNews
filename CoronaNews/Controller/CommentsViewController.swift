//
//  CommentsViewController.swift
//  CoronaNews
//
//  Created by iosdev on 22.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import UIKit
import Firebase

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CommentDelegate {
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCommentField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addView: UIView!
    
    let firestore = Firestore.firestore()
    var question: Question!
    var comments = [Comment]()
    var questionRef: DocumentReference!
    var commentListener : ListenerRegistration!
    var bgColor: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.backgroundColor = bgColor
        self.view.backgroundColor = bgColor
        self.addView.backgroundColor = bgColor
        
        questionRef = firestore.collection("questions").document(question.documentId)
        updateButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        commentListener = firestore.collection("questions").document(self.question.documentId)
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
    
    override func viewDidDisappear(_ animated: Bool) {
        commentListener.remove()
    }
    
    func updateButton() {
        let text = addCommentField.text ?? ""
        addButton.isEnabled = !text.isEmpty
    }
    
    @IBAction func textDidBeginEditing(_ sender: Any) {
        addButton.isEnabled = false
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        let text = addCommentField.text ?? ""
        addButton.isEnabled = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    @IBAction func textDidEndEditing(_ sender: Any) {
        addButton.isEnabled = false
    }
    
    // only works around the table view, make add to didSelectRowForIndexPath
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func commentButtonTapped(_ sender: Any) {
        let now = Date()
        let timestamp = Timestamp(date: now)
        guard let commentField = addCommentField.text else { return }
        
        //we have to run transaction because we are updating the document and adding to it
        firestore.runTransaction({ (transaction, errorPointer) -> Any? in
            
            let questionDocument: DocumentSnapshot
            
            do {
                try questionDocument = transaction.getDocument(self.questionRef)
            } catch let error as NSError {
                debugPrint("DocumentId fetch error: \(error)")
                return nil
            }
            
            //update commentsTotal everytime comment is added
            guard let oldCommentsTotal = questionDocument.data()!["commentsTotal"] as? Int else { return nil }
            transaction.updateData(["commentsTotal" : oldCommentsTotal + 1], forDocument: self.questionRef)
            
            //get the documentId, create a new collection to it and add a document.
            let newCommentRef = self.questionRef.collection("comments").document()
            transaction.setData([
                "comment" : commentField,
                "timestamp" : timestamp,
                "username" : Auth.auth().currentUser?.displayName ?? "",
                "userId" : Auth.auth().currentUser?.uid ?? ""
            ], forDocument: newCommentRef)
            
            return nil
        }) { (object, error) in
            if let error = error {
                debugPrint("Failed adding comment: \(error)")
            } else {
                self.addCommentField.text = ""
                self.addCommentField.resignFirstResponder()
            }
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "commentsTableViewCell", for: indexPath) as? CommentsTableViewCell {
            
            cell.configure(comment: comments[indexPath.row], delegate: self)
            cell.backgroundColor = bgColor
            return cell
        }
        return UITableViewCell()
    }
    
    func deleteCommentTapped(comment: Comment) {
        let alert = UIAlertController(title: "Delete Comment", message: "Are you sure you want to delete?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Confirm", style: .default){ (action) in
            
            //we have to run transaction because we are updating the document and adding to it
            self.firestore.runTransaction({ (transaction, errorPointer) -> Any? in
                
                let questionDocument: DocumentSnapshot
                do {
                    try questionDocument = transaction.getDocument(self.questionRef)
                } catch let error as NSError {
                    debugPrint("Fetch documentId error: \(error)")
                    return nil
                }
                
                //update the commentsTotal after deletion
                guard let oldCommentsTotal = questionDocument.data()!["commentsTotal"] as? Int else { return nil }
                transaction.updateData(["commentsTotal" : oldCommentsTotal - 1], forDocument: self.questionRef)
                
                //reference document and delete that document
                let commentRef = self.questionRef.collection("comments").document(comment.documentId)
                transaction.deleteDocument(commentRef)
                
                return nil
            }) { (object, error) in
                if let error = error {
                    debugPrint("Failed deleting comment: \(error)")
                } else {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}
