//
//  Comment.swift
//  CoronaNews
//
//  Created by iosdev on 22.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import Foundation
import Firebase

class Question {
    
    private(set) var username: String!
    private(set) var timestamp: Timestamp!
    private(set) var question: String!
    private(set) var commentsTotal: Int!
    private(set) var documentId: String!
    private(set) var userId: String!
    
    init(username: String, timestamp: Timestamp, question: String, commentsTotal: Int, documentId: String, userId: String) {
        
        self.username = username
        self.timestamp = timestamp
        self.question = question
        self.commentsTotal = commentsTotal
        self.documentId = documentId
        self.userId = userId
    }
    
    //parse Firestore data to array
    class func parseData(snapshot: QuerySnapshot?) -> [Question] {
        var questions = [Question]()
        
        guard let snap = snapshot else { return questions }
        for document in snap.documents {
            let data = document.data()
            
            let username = data["username"] as? String ?? "Anonymous"
            let timestamp = data["timestamp"] as! Timestamp
            let question = data["question"] as? String ?? ""
            let commentsTotal = data["commentsTotal"] as? Int ?? 0
            let documentId = document.documentID
            let userId = data["userId"] as? String ?? ""
            
            let newQuestion = Question(username: username, timestamp: timestamp, question: question, commentsTotal: commentsTotal, documentId: documentId, userId: userId)
            questions.append(newQuestion)
        }
        
        return questions
    }
}
