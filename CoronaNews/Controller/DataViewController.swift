//
//  DataViewController.swift
//  CoronaNews
//
//  Created by iosdev on 16.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import UIKit

class DataViewController: UIViewController, CovidAPIDelegate {
    func newData(_ covidData: Covid19?) {
        DispatchQueue.main.sync {
            self.totalLbl.text = "\(covidData?.Global.TotalConfirmed ?? 0)"
            self.deathLbl.text = "\(covidData?.Global.TotalDeaths ?? 0)"
            self.recoveredLbl.text = "\(covidData?.Global.TotalRecovered ?? 0)"
            self.totalIncreaseLbl.text = "\u{2191} \(covidData?.Global.NewConfirmed ?? 0)"
            self.deathIncreaseLbl.text = "\u{2191} \(covidData?.Global.NewConfirmed ?? 0)"
            self.recoveredIncreaseLbl.text = "\u{2191} \(covidData?.Global.NewConfirmed ?? 0)"

        }
    }
    
    /*@IBOutlet weak var totalTitle: UILabel!
    @IBOutlet weak var deathTitle: UILabel!
    @IBOutlet weak var recoverTitle: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var recoveredLbl: UILabel!
    @IBOutlet weak var totalIncreaseLbl: UILabel!
    
    @IBOutlet weak var recoveredIncreaseLbl: UILabel!
    @IBOutlet weak var deathIncreaseLbl: UILabel!
    @IBOutlet weak var deathLbl: UILabel!*/
    
    @IBOutlet weak var totalTitle: UILabel!
    @IBOutlet weak var deathTitle: UILabel!
    @IBOutlet weak var recoverTitle: UILabel!
    
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var deathLbl: UILabel!
    @IBOutlet weak var recoveredLbl: UILabel!
    
    @IBOutlet weak var totalIncreaseLbl: UILabel!
    @IBOutlet weak var deathIncreaseLbl: UILabel!
    @IBOutlet weak var recoveredIncreaseLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let covidAPI = CovidAPI()
        //covidAPI.url = "https://api.covid19api.com/summary"
        covidAPI.covidAPIDelegate = self
        covidAPI.getData()
        totalTitle.font = UIFont.boldSystemFont(ofSize: 20.0)
        deathTitle.font = UIFont.boldSystemFont(ofSize: 20.0)
        recoverTitle.font = UIFont.boldSystemFont(ofSize: 20.0)
        // Do any additional setup after loading the view.
    }
}


