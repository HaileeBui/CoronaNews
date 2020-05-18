//
//  MessageTableViewController.swift
//  CoronaNews
//
//  Created by iosdev on 16.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import UIKit
import Firebase

class MessageTableViewController: UITableViewController, QuestionDelegate {
    
    private var questions = [Question]()
    private var questionsCollectionRef: CollectionReference!
    private var questionsListener: ListenerRegistration!
    private var handle: AuthStateDidChangeListenerHandle?
    let firestore = Firestore.firestore()
    let colorArray = [UIColor("#FFCCBC"), UIColor("#ffc09b"), UIColor("#FFA9A9")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 100
        
        questionsCollectionRef = firestore.collection("questions")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        questionsListener = questionsCollectionRef
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
        if questionsListener != nil {
            questionsListener.remove()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "messageTableViewCell", for: indexPath) as? MessageTableViewCell {
            cell.configure(question: questions[indexPath.row], delegate: self)
            
            let cycle = indexPath.row / colorArray.count
            let colorIndex = indexPath.row - (cycle * colorArray.count)
            cell.backgroundColor = colorArray[colorIndex]
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "commentSegue", sender: questions[indexPath.row])
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentSegue" {
            if let destinationVC = segue.destination as? CommentsViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    if let question = sender as? Question {
                        destinationVC.question = question
                        
                        let cycle = indexPath.row / colorArray.count
                        let colorIndex = indexPath.row - (cycle * colorArray.count)
                        destinationVC.bgColor = colorArray[colorIndex]
                    }
                }
            }
        }
    }
    
    @IBAction func addQuestionTapped(_ sender: Any) {
    let alert = UIAlertController(title: "Question", message: "What do you want to ask?", preferredStyle: .alert)
        
        let submit = UIAlertAction(title: "Submit", style: .default) { (_) in
            guard let textField = alert.textFields?.first, let text = textField.text else {
                return
            }
            let now = Date()
            let timestamp = Timestamp(date: now)
            Firestore.firestore().collection("questions").addDocument(data: [
                "commentsTotal" : 0,
                "question" : text,
                "timestamp" : timestamp,
                "username" : Auth.auth().currentUser?.displayName ?? "",
                "userId" : Auth.auth().currentUser?.uid ?? ""
                
            ]) { (err) in
                if let err = err {
                    debugPrint("Error adding document: \(err)")
                } else {
                    alert.dismiss(animated: false, completion: nil)
                }
            }
        }
        
        submit.isEnabled = false
        
        alert.addTextField { (textField) in
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:
                {_ in
                    let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let textNotEmpty = textCount > 0
                    submit.isEnabled = textNotEmpty
            })
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(submit)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
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
}
