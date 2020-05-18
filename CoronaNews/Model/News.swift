//
//  News.swift
//  CoronaNews
//
//  Created by iosdev on 16.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import Foundation
import Firebase

struct News: Codable {
    var totalResults: Int
    var articles: [NewsArticles]
}

struct NewsArticles: Codable {
    var author: String?
    var title: String?
    var articleDescription: String?
    var url: String!
    var urlToImage: String?
    var publishedAt: String?
    var content: String?
    var documentId: String!
    
    enum CodingKeys: String, CodingKey {
        case author, title
        case articleDescription = "description"
        case url, urlToImage, publishedAt, content, documentId
    }
}
