//
//  MyQuestionsTableViewController.swift
//  CoronaNews
//
//  Created by iosdev on 4.5.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import UIKit
import Firebase

class MyQuestionsTableViewController: UITableViewController, MyQuestionDelegate {
    
    var questions = [Question]()
    var questionListener : ListenerRegistration!
    var questionCollectionRef: CollectionReference!
    var questionUserId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionCollectionRef = Firestore.firestore().collection("questions")
        questionUserId = Auth.auth().currentUser?.uid
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        questionListener = questionCollectionRef.whereField("userId", isEqualTo : questionUserId!)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { (snapshot, error) in
                if let err = error {
                    debugPrint("Error fetching docs: \(err)")
                } else {
                    self.questions.removeAll()
                    self.questions = Question.parseData(snapshot: snapshot)
                    self.tableView.reloadData()
                }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if questionListener != nil {
            questionListener.remove()
        }
    }
    
    func deleteQuestionTapped(question: Question) {
        let alert = UIAlertController(title: "Delete Question", message: "Are you sure you want to delete?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Confirm", style: .default){ (action) in
            
            Firestore.firestore().collection("questions").document(question.documentId).delete(completion: {(error)
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
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "myQuestionsTableViewCell", for: indexPath) as? MyQuestionsTableViewCell {
            cell.configure(question: questions[indexPath.row], delegate: self)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
}
