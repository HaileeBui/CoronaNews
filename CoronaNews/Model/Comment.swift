//
//  Question.swift
//  CoronaNews
//
//  Created by iosdev on 20.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import Foundation
import Firebase

class Comment {
    
    private(set) var username: String!
    private(set) var timestamp: Timestamp!
    private(set) var comment: String!
    private(set) var documentId: String!
    private(set) var userId: String!
    
    
    init(username: String, timestamp: Timestamp, comment: String, documentId: String, userId: String) {
        self.username = username
        self.timestamp = timestamp
        self.comment = comment
        self.documentId = documentId
        self.userId = userId
    }
    
    //parse Firestore data to array
    class func parseData(snapshot: QuerySnapshot?) -> [Comment] {
        var comments = [Comment]()
        
        guard let snap = snapshot else { return comments }
        for document in snap.documents {
            let data = document.data()
            let username = data["username"] as? String ?? "Anonymous"
            let timestamp = data["timestamp"] as! Timestamp
            let comment = data["comment"] as? String ?? ""
            let documentId = document.documentID
            let userId = data["userId"] as? String ?? ""
            
            let newComment = Comment(username: username, timestamp: timestamp, comment: comment, documentId: documentId, userId: userId)
            comments.append(newComment)
        }
        
        return comments
    }
}
