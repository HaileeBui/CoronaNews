//
//  MessageTableViewCell.swift
//  CoronaNews
//
//  Created by iosdev on 16.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import UIKit
import Firebase

protocol QuestionDelegate {
    func deleteQuestionTapped(question: Question)
}

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var commentsTotalLabel: UILabel!
    
    private var delegate: QuestionDelegate?
    private var question: Question!
    
    @objc
    func deleteQuestionTapped() {
        delegate?.deleteQuestionTapped(question: question)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(question: Question, delegate: QuestionDelegate) {
        self.question = question
        self.delegate = delegate
        questionLabel.text = question.question
        usernameLabel.text = question.username + " *"
        commentsTotalLabel.text = String(question.commentsTotal)
        deleteButton.isHidden = true

        //timestamp
        let questionTimestamp = question.timestamp
        let currentTimestamp = questionTimestamp?.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        let timestamp = formatter.string(from: currentTimestamp!)
        timestampLabel.text = timestamp
        
        //if user is the same as who posted show delete button
        if question.userId == Auth.auth().currentUser?.uid {
            deleteButton.isHidden = false
            deleteButton.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(deleteQuestionTapped))
            deleteButton.addGestureRecognizer(tap)
        }
    }
}
