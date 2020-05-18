//
//  MapView.swift
//  CoronaNews
//
//  Created by iosdev on 27.4.2020.
//  Copyright © 2020 metropolia. All rights reserved.
//

import SwiftUI
import MapKit
import Combine

struct MapViewContent: View {
    
    @ObservedObject var coronaCases = CoronaObservable()
    
    var body: some View {
        VStack{
            MapView(coronaCases: coronaCases.caseAnnotations, totalCases: Int(coronaCases.coronaOutbreak.totalCases) ?? 0)
        }
    }
}

struct MapViewContent_Previews: PreviewProvider {
    static var previews: some View {
        MapViewContent()
    }
}


struct MapView: UIViewRepresentable {

    var coronaCases: [CaseAnnotations]
    var totalCases : Int

    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView{
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ view: MKMapView, context: Context){

        view.delegate = context.coordinator
        
        view.addAnnotations(coronaCases)
        if let first = coronaCases.first{
            view.selectAnnotation(first, animated: true)
    
        }
    }
}

class MapViewCoordinator: NSObject, MKMapViewDelegate {
    
    var mapViewController: MapView

    init(_ control: MapView) {
        self.mapViewController = control
    }
    
    func mapView(_ mapView: MKMapView, viewFor
        annotation: MKAnnotation) -> MKAnnotationView?{

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "anno")
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "anno")
            annotationView?.canShowCallout = true
            
        }
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.text = annotation.subtitle ?? "NA"
        subtitleLabel.numberOfLines = 0
        annotationView?.detailCalloutAccessoryView = subtitleLabel

        return annotationView
    }
}

// load data from url
class CoronaObservable : ObservableObject{
    
    @Published var caseAnnotations = [CaseAnnotations]()
    @Published var coronaOutbreak = (totalCases: "...", totalRecovered: "...", totalDeaths: "...")

   var urlBase = "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/1/query"
    
    var cancellable : Set<AnyCancellable> = Set()
    
    init() {
        fetchCoronaCases()
    }
    
    func fetchCoronaCases() {
        
        var urlComponents = URLComponents(string: urlBase)!
        urlComponents.queryItems = [
            URLQueryItem(name: "f", value: "json"),
            URLQueryItem(name: "where", value: "Confirmed > 0"),
            URLQueryItem(name: "geometryType", value: "esriGeometryEnvelope"),
            URLQueryItem(name: "spatialRef", value: "esriSpatialRelIntersects"),
            URLQueryItem(name: "outFields", value: "*"),
            URLQueryItem(name: "orderByFields", value: "Confirmed desc"),
            URLQueryItem(name: "resultOffset", value: "0"),
            URLQueryItem(name: "cacheHint", value: "true")]

        URLSession.shared.dataTaskPublisher(for: urlComponents.url!)
            .map{$0.data}
            .decode(type: Response.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
        }) { response in
            
            self.casesByProvince(response: response)
        }
        .store(in: &cancellable)
    }
    
    func casesByProvince(response: Response) {
        var caseAnnotations : [CaseAnnotations] = []
        
        for cases in response.features{
            
            let confirmed = cases.attributes.confirmed ?? 0

            caseAnnotations.append(CaseAnnotations(title: cases.attributes.provinceState ?? cases.attributes.countryRegion ?? "", subtitle: "\(confirmed)", coordinate: .init(latitude: cases.attributes.lat ?? 0.0, longitude: cases.attributes.longField ?? 0.0)))

        }
        self.caseAnnotations = caseAnnotations
    }
}

//store content to annotate the map
class CaseAnnotations: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D //holding lat and long
    
    init(title: String?,
         subtitle: String?,
         coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}



class ChildController: UIHostingController<MapViewContent> {

    required init?(coder: NSCoder) {
        super.init(coder: coder,rootView: MapViewContent());
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
