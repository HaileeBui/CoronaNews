import UIKit
struct Country: Decodable{
    let country: String
}
class CountryViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var stack: UIStackView!
    private var countriesArray = [Country]()
    private var countriesUnsorted = [String]()
    private var countries = [String]()
    private var countryName = "hanoi"
    
    @IBOutlet weak var countryPicker: UIPickerView!
    
   
    @IBOutlet weak var totalTitle: UILabel!
    @IBOutlet weak var deathTitle: UILabel!
    @IBOutlet weak var recoverTitle: UILabel!
    @IBOutlet weak var activeTitle: UILabel!
    
    
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var deathLbl: UILabel!
    @IBOutlet weak var recoverLbl: UILabel!
    @IBOutlet weak var activeLbl: UILabel!
    
    @IBOutlet weak var totalIncLbl: UILabel!
    @IBOutlet weak var deathIncLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //pinBackground(backgroundView, to: stack)

        countryPicker.delegate = self
        countryPicker.dataSource = self
        totalLbl.font = UIFont.boldSystemFont(ofSize: 18.0)
        deathLbl.font = UIFont.boldSystemFont(ofSize: 18.0)
        recoverLbl.font = UIFont.boldSystemFont(ofSize: 18.0)
        activeLbl.font = UIFont.boldSystemFont(ofSize: 18.0)
        
        totalTitle.font = UIFont.boldSystemFont(ofSize: 18.0)
        deathTitle.font = UIFont.boldSystemFont(ofSize: 18.0)
        recoverTitle.font = UIFont.boldSystemFont(ofSize: 18.0)
        activeTitle.font = UIFont.boldSystemFont(ofSize: 18.0)

        let url = URL(string: "https://coronavirus-19-api.herokuapp.com/countries/")
        
        URLSession.shared.dataTask(with: url!) { (data, response,error ) in
            if error == nil {
                do {
                    self.countriesArray = try JSONDecoder().decode([Country].self, from: data!)
                    self.countriesUnsorted = self.countriesArray.map { $0.country }
                    let filtered = self.countriesUnsorted.filter {!$0.contains(" ")}
                    self.countries = filtered.sorted {$0 < $1}
                } catch {
                    print("parse error")
                }
                DispatchQueue.main.async{
                    self.countryPicker.reloadAllComponents()
                    self.countryPicker.selectRow(73, inComponent:0, animated:true)
                }
            }
        }.resume()
        // Do any additional setup after loading the view.
        //print("olll \(countries)")
    }
    /*private var backgroundView: UIView = {
      let view = UIView()
      view.backgroundColor = .lightGray
      view.layer.cornerRadius = 5.0
      return view
    }()

    private func pinBackground(_ view: UIView, to stackView: UIStackView) {
      view.translatesAutoresizingMaskIntoConstraints = false
      stackView.insertSubview(view, at: 0)
      view.pin(to: stackView)
    }
    */
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countries[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryName = countries[countryPicker.selectedRow(inComponent: 0)]
        print("chosen \(countryName)")
        let urlString = "https://coronavirus-19-api.herokuapp.com/countries/" + countryName
        if let url = URL(string:  urlString) {
            print("url \(url)")
            let task = URLSession.shared.dataTask(with: url) {data, response, error in
                if (error != nil) {
                    print("Client error \(String(describing: error))")
                } else {
                    if let urlContent = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                            if let total = json["cases"] as? Int {
                                DispatchQueue.main.async {
                                    self.totalLbl.text = "\(total )"
                                }
                            }
                            
                            if let death = json["deaths"] as? Int {
                                DispatchQueue.main.async {
                                    self.deathLbl.text = "\(death )"
                                }
                            }
                            
                            if let recover = json["recovered"] as? Int {
                                DispatchQueue.main.async {
                                    self.recoverLbl.text = "\(recover )"
                                }
                            }
                            
                            if let todayCase = json["todayCases"] as? Int {
                                DispatchQueue.main.async {
                                    self.totalIncLbl.text = "\u{2191}\(todayCase) "
                                }
                            }
                            
                            if let todayDeath = json["todayDeaths"] as? Int {
                                DispatchQueue.main.async {
                                    self.deathIncLbl.text = "\u{2191}\(todayDeath)"
                                }
                            }
                            
                            if let active = json["active"] as? Int {
                                DispatchQueue.main.async {
                                    self.activeLbl.text = "\(active)"
                                }
                            }
                        } catch {
                            print("Failed")
                        }
                    }
                }
            }
            task.resume()
        }
    }
}

public extension UIView {
  public func pin(to view: UIView) {
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: view.leadingAnchor),
      trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topAnchor.constraint(equalTo: view.topAnchor),
      bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])
  }
}
