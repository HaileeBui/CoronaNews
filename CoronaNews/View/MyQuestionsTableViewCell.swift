//
//  MyQuestionsTableViewCell.swift
//  CoronaNews
//
//  Created by iosdev on 4.5.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import UIKit
import Firebase

protocol MyQuestionDelegate {
    func deleteQuestionTapped(question: Question)
}

class MyQuestionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var delegate: MyQuestionDelegate?
    private var question: Question!
    
    @objc
    func deleteQuestionTapped() {
        delegate?.deleteQuestionTapped(question: question)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(question: Question, delegate: MyQuestionDelegate) {
        self.question = question
        self.delegate = delegate
        questionLabel.text = question.question
        
        //timestamp
        let questionTimestamp = question.timestamp
        let currentTimestamp = questionTimestamp?.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        let timestamp = formatter.string(from: currentTimestamp!)
        timestampLabel.text = timestamp
        
        //delete
        deleteButton.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(deleteQuestionTapped))
        deleteButton.addGestureRecognizer(tap)
    }
}
