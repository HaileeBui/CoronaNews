//
//  Map.swift
//  CoronaNews
//
//  Created by iosdev on 28.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//
import Foundation

struct Response : Codable{
    
    
    public var features: [Cases]
        
    private enum CodingKeys: String, CodingKey {
        case features
    }
}

struct Cases : Codable{
        
    public var attributes: Attributes

    private enum CodingKeys: String, CodingKey {
        case attributes
    }
}

struct Attributes : Codable {

        let confirmed : Int?
        let countryRegion : String?
        let deaths : Int?
        let lat : Double?
        let longField : Double?
        let provinceState : String?
        let recovered : Int?

        enum CodingKeys: String, CodingKey {
                case confirmed = "Confirmed"
                case countryRegion = "Country_Region"
                case deaths = "Deaths"
                case lat = "Lat"
                case longField = "Long_"
                case provinceState = "Province_State"
                case recovered = "Recovered"
        }
}

