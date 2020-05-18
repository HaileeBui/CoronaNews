//
//  ContentView.swift
//  test
//
//  Created by iosdev on 24.4.2020.
//  Copyright © 2020 iosdev. All rights reserved.
//

import SwiftUI
import UIKit

struct Series: Decodable {
    let Finland: [DayData]
}

struct DayData: Decodable, Hashable {
    let date: String
    let confirmed, deaths, recovered: Int
}


struct ContentView: View {
    @ObservedObject var vm = ChartViewModel()
    @ObservedObject var api = CovidAPI()
    static var dateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    var now = Date()
    var body: some View {
        ScrollView{
        VStack{
           
            HStack {
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 10){
                HStack{
                    Text("Total:").font(.system(size: 18, weight: .bold))
                    Text("\(api.total) (\u{2191}\(api.incTotal))")
                }
                HStack{
                    Text("Deaths:").font(.system(size: 18, weight: .bold))
                    Text("\(api.death) (\u{2191}\(api.incDeath))")
                }
                HStack{
                    Text("Recovered:").font(.system(size: 18, weight: .bold))
                    Text("\(api.recover) (\u{2191}\(api.incRecover))")
                }
                NavigationLink(destination: MapViewContent()) {
                    Text("Show map")
                    }
            }

            Divider()

            Text("Finland").font(.system(size: 34, weight: .bold))
            Text("Total Confirmed: \(vm.max)")
            if !vm.dataSet.isEmpty{
                ScrollView(.horizontal){
                    HStack (alignment: .bottom, spacing: 5){
                        ForEach(vm.dataSet, id: \.self) { day in
                            HStack{
                                Spacer()
                            }.frame(width: 8, height: CGFloat(day.confirmed)/CGFloat(self.vm.max) * 200).background(Color.orange)
                        }
                    }
                }
            }
            HStack{
                Text("\u{2190} Jan 22, 2020").font(.caption).foregroundColor(Color.gray)
                Spacer()
                Text("\(self.now,formatter: Self.dateFormatter) \u{2192}").font(.caption).foregroundColor(Color.gray)
            }
            Text("Total Deaths: \(vm.deathMax)")
            if !vm.deathsSet.isEmpty{
                ScrollView(.horizontal){
                    HStack (alignment: .bottom, spacing: 5){
                        ForEach(vm.deathsSet, id: \.self) { day in
                            HStack{
                                Spacer()
                            }.frame(width: 8, height: CGFloat(day.deaths)/CGFloat(self.vm.deathMax) * 200).background(Color.orange)
                        }
                    }
                }
            }
            HStack{
                Text("\u{2190} Jan 22, 2020").font(.caption).foregroundColor(Color.gray)
                Spacer()
                Text("\(self.now,formatter: Self.dateFormatter) \u{2192}").font(.caption).foregroundColor(Color.gray)
            }
            
        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
    }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class ChildHostingController: UIHostingController<ContentView> {

    required init?(coder: NSCoder) {
        super.init(coder: coder,rootView: ContentView());
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
