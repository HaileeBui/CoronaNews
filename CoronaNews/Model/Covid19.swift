//
//  Covid19.swift
//  CoronaNews
//
//  Created by iosdev on 19.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import Foundation

struct Covid19: Codable {
    var Global: GlobalInfo
    var Countries: [CountryInfo]
    
    private enum CodingKeys: String, CodingKey {
        case Global
        case Countries
    }
}

struct GlobalInfo: Codable {
    var NewConfirmed: Int
    var TotalConfirmed: Int
    var NewDeaths: Int
    var TotalDeaths: Int
    var NewRecovered: Int
    var TotalRecovered: Int
}

struct CountryInfo: Codable {
    var Country: String
    var CountryCode: String
    var Slug: String
    var NewConfirmed: Int
    var TotalConfirmed: Int
    var NewDeaths: Int
    var TotalDeaths: Int
    var NewRecovered: Int
    var TotalRecovered: Int
    var Date: String
}
