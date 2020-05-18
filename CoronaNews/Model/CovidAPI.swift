//
//  CovidAPI.swift
//  CoronaNews
//
//  Created by iosdev on 19.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import Foundation
import UIKit
class CovidAPI: ObservableObject{
    @Published var data = [Covid19]()
    var total = 0
    var death = 0
    var recover = 0
    var incTotal = 0
    var incDeath = 0
    var incRecover = 0

    
    init(){
        let urlString = "https://api.covid19api.com/summary"
        guard let url = URL(string: urlString) else {return}
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
            }

            guard let data = data else {return}
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    return
            }

            do {
                let array = try JSONDecoder().decode(Covid19.self, from: data)
                //print("\(array)")
                DispatchQueue.main.async{
                    self.total = array.Global.TotalConfirmed + array.Global.NewConfirmed
                    self.death = array.Global.TotalDeaths + array.Global.NewDeaths
                    self.recover = array.Global.TotalRecovered + array.Global.NewRecovered
                    self.incTotal = array.Global.NewConfirmed
                    self.incDeath = array.Global.NewDeaths
                    self.incRecover = array.Global.NewRecovered
                }
            } catch {
                print("parse error")
            }
        }.resume()
    }
}

class ChartViewModel: ObservableObject {
    @Published var dataSet = [DayData]()
    @Published var deathsSet = [DayData]()
    var max = 0
    var deathMax = 0
    init() {
        /*let currentDate = Date()
        print ("\(currentDate)")
        let formatter = DateFormatter()
        //formatter.dateStyle = .medium
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: currentDate)
        print("\(date)")*/
        let urlString = "https://pomber.github.io/covid19/timeseries.json"
        guard let url = URL(string: urlString) else {return}
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {return}
            
            do {
                let series = try JSONDecoder().decode(Series.self, from: data)
                DispatchQueue.main.async{
                    self.dataSet = series.Finland.filter { $0.confirmed > 100 }
                    self.deathsSet = series.Finland.filter { $0.deaths > 0 }
                    self.max = self.dataSet.max(by: {(day1, day2) -> Bool in
                        return day2.confirmed > day1.confirmed
                    })?.confirmed ?? 0
                    self.deathMax = self.deathsSet.max(by: {(day1, day2) -> Bool in
                        return day2.deaths > day1.deaths
                    })?.deaths ?? 0
                    //print(" dataset \(self.dataSet), \(self.max)")
                }
            } catch {
                print("parse error")
            }
        }.resume()
    }
}
