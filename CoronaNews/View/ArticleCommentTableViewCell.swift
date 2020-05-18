//
//  ArticleCommentTableViewCell.swift
//  CoronaNews
//
//  Created by iosdev on 4.5.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import UIKit
import Firebase

protocol ArticleCommentDelegate {
    func deleteCommentTapped(comment: Comment)
}

class ArticleCommentTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var delegate: ArticleCommentDelegate?
    private var comment: Comment!
    
    @objc
    func deleteCommentTapped() {
        delegate?.deleteCommentTapped(comment: comment)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(comment: Comment, delegate: ArticleCommentDelegate) {
        deleteButton.isHidden = true
        self.comment = comment
        self.delegate = delegate
        usernameLabel.text = comment.username + " *"
        commentLabel.text = comment.comment
        
        //timestamp
        let commentTimestamp = comment.timestamp
        let currentTimestamp = commentTimestamp?.dateValue()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        let timestamp = formatter.string(from: currentTimestamp!)
        timestampLabel.text = timestamp
        
        //if user is the same as who posted show delete button
        if comment.userId == Auth.auth().currentUser?.uid {
            deleteButton.isHidden = false
            deleteButton.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(deleteCommentTapped))
            deleteButton.addGestureRecognizer(tap)
        }
    }
}

