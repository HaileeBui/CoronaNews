//
//  NewsAPI.swift
//  CoronaNews
//
//  Created by iosdev on 16.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//
//  Handles the API request from newsapi.org

import Foundation

class NewsAPI {
    
    private var url = URL(string: "https://newsapi.org/v2/everything?q=covid&language=en&sortBy=publishedAt&apiKey=627415d1bd174042827c2eeb4ee59d0e")
    var newsAPIDelegate: NewsAPIDelegate?
    
    func getNews() {
        
        let dataTask = URLSession.shared.dataTask(with: url!) {data, response, error in
            
            //Check if there is an error
            if let error = error {
                print(error)
            }
            
            //Check the HTTP response
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    return
            }
            
            //Get the data
            guard let data = data else {
                return
            }
            
            //Decode the data using News.swift struct
            let news = try? JSONDecoder().decode(News.self, from: data)
            self.newsAPIDelegate?.newNews(news)
        }
        
        dataTask.resume()
    }
}

protocol NewsAPIDelegate {
    func newNews(_ news: News?)
}
