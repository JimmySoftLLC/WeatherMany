//
//  TableViewController.swift
//  WeatherMany
//
//  Created by Jim  Bailey on 7/4/19.
//  Copyright © 2019 JimmySoftLLC. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import AlamofireImage

struct WeatherDataType {
    var id : Int
    var city : String
    var temperature : [Int]
    var condition : [String]
    var wind : [String]
    var imageUrl : [String]
    var startTime : [String]
    var date: [String]
}

///////////////////////////////////////////
//MARK: - extendingcapablity of UIImageView and String
//TODO: there must be some string libraries that should be used instead of writing your own routine.

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
}

extension UIColor {
    
    static var defaultBlue: UIColor {
        return UIButton(type: .system).tintColor
    }
    
}

///////////////////////////////////////////
//MARK: - WeatherTableViewCell
//TODO: Consider a nib file instead in the future

class WeatherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var Label21: UILabel!
    
    @IBOutlet weak var Label22: UILabel!
    
    @IBOutlet weak var Label23: UILabel!
    
    @IBOutlet weak var Label24: UILabel!
    
    @IBOutlet weak var Label25: UILabel!
    
    @IBOutlet weak var Label26: UILabel!

    @IBOutlet weak var Label31: UILabel!
    
    @IBOutlet weak var Label32: UILabel!
    
    @IBOutlet weak var Label33: UILabel!

    @IBOutlet weak var Label34: UILabel!
    
    @IBOutlet weak var Label35: UILabel!
    
    @IBOutlet weak var Label36: UILabel!
    
    @IBOutlet weak var Label41: UILabel!
    
    @IBOutlet weak var Label42: UILabel!
    
    @IBOutlet weak var Label43: UILabel!
    
    @IBOutlet weak var Label44: UILabel!
    
    @IBOutlet weak var Label45: UILabel!
    
    @IBOutlet weak var Label46: UILabel!
    
    @IBOutlet weak var Image11: UIImageView!
    
    @IBOutlet weak var Image12: UIImageView!
    
    @IBOutlet weak var Image13: UIImageView!
    
    @IBOutlet weak var Image14: UIImageView!
    
    @IBOutlet weak var Image15: UIImageView!
    
    @IBOutlet weak var Image16: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
}

class ExtWeatherArray {
    var weatherArray : [WeatherDataType] = []
}

class persitantDataTowns {
    var towns : [String] = []
}

class TableViewController: UITableViewController, CLLocationManagerDelegate {

    //Constants
    let WEATHER_URL = "https://api.weather.gov/points/"
    let locationManager = CLLocationManager()
    let defaults = UserDefaults.standard
    
    //Variables
    
    var myExtWeatherArray : [ExtWeatherArray] = []
    var myTowns : [persitantDataTowns] = []
    var howManyRowsAreThere : Int = 0
    var setOfSixIndex : Int = 0
    var setOfSixIndexMultiplied : Int = 0
    var currentRow : Int = 0
    var currentCityCollection : Int = 0
    
    ///////////////////////////////////////////
    //MARK: - View did load
    //TODO:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0..<4 {
            let myweatherArrayInstance: ExtWeatherArray = ExtWeatherArray.init()
            myExtWeatherArray.append(myweatherArrayInstance)
            let myTownsInstance: persitantDataTowns = persitantDataTowns.init()
            myTowns.append(myTownsInstance)
        }
    
        if defaults.array(forKey: "Cities1") != nil {
            myTowns[currentCityCollection].towns = defaults.array(forKey: "Cities1") as! [String]
        }
        defaults.set(myTowns[currentCityCollection].towns, forKey: "Cities1")
        
        if defaults.array(forKey: "Cities2") != nil {
            myTowns[1].towns = defaults.array(forKey: "Cities2") as! [String]
        }
        defaults.set(myTowns[1].towns, forKey: "Cities2")
        
        if defaults.array(forKey: "Cities3") != nil {
            myTowns[2].towns = defaults.array(forKey: "Cities3") as! [String]
        }
        defaults.set(myTowns[2].towns, forKey: "Cities3")
        
        currentCityCollection = defaults.integer(forKey: "currentCityCollection")
        defaults.set(currentCityCollection, forKey: "currentCityCollection")
        
        updatePrevAndNextButtons()
        
        updateCityCollectionButton(myCollectionItem: currentCityCollection)
    }
    
    ///////////////////////////////////////////
    //MARK: - Navbar Prev, Next buttons
    //TODO:
    
    @IBAction func prevButtonPressed(_ sender: UIBarButtonItem) {
        setOfSixIndex -= 1
        if setOfSixIndex < 0 {
            setOfSixIndex = 0
        }
        setOfSixIndexMultiplied = setOfSixIndex * 6
        updatePrevAndNextButtons()
        myTableView.reloadData()
    }
    
    func updatePrevAndNextButtons() {
        if setOfSixIndex == 25 {
            nextButton.isEnabled = false
        } else {
            nextButton.isEnabled = true
        }
        if setOfSixIndex == 0 {
            prevButton.isEnabled = false
        } else {
            prevButton.isEnabled = true
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: UIBarButtonItem) {
        setOfSixIndex += 1
        if setOfSixIndex > 25 {
            setOfSixIndex = 25
        }
        setOfSixIndexMultiplied = setOfSixIndex * 6
        updatePrevAndNextButtons()
        myTableView.reloadData()
    }
    
    @IBOutlet weak var prevButton: UIBarButtonItem!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    ///////////////////////////////////////////
    //MARK: - Toolbar add, delete, 1, 2, 3, Refresh Buttons
    //TODO:
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var trashButton: UIBarButtonItem!
    
    @IBOutlet weak var oneButton: UIBarButtonItem!
    
    @IBOutlet weak var twoButton: UIBarButtonItem!
    
    @IBOutlet weak var threeButton: UIBarButtonItem!
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add location", message: "Enter a location name", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.myTowns[self.currentCityCollection].towns.append(textField?.text ?? "")
            self.defaults.set(self.myTowns[self.currentCityCollection].towns, forKey: "Cities1")
            self.refreshLocations()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Do you want to delete this location", message: "Don't worry you can aways add it back later.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            if self.currentRow < self.myTowns.count && self.currentRow >= 0 {
                self.myTowns.remove(at: self.currentRow)
                self.defaults.set(self.myTowns[self.currentCityCollection].towns, forKey: "Cities1")
                self.refreshLocations()
            }
        }))
        
        self.present(alert, animated: true)
        
    }
    
    @IBAction func oneButton(_ sender: UIBarButtonItem) {
        updateCityCollectionButton(myCollectionItem: 0)
    }
    
    @IBAction func twoButton(_ sender: UIBarButtonItem) {
        updateCityCollectionButton(myCollectionItem: 1)
    }
    
    @IBAction func threeButton(_ sender: UIBarButtonItem) {
        updateCityCollectionButton(myCollectionItem: 2)
    }
    

    func updateCityCollectionButton(myCollectionItem : Int) {
        enableButtons(isEnabled: false)
        currentCityCollection = myCollectionItem
        switch currentCityCollection {
        case 0:
            oneButton.tintColor = UIColor.defaultBlue
            twoButton.tintColor = UIColor.lightGray
            threeButton.tintColor = UIColor.lightGray
        case 1:
            oneButton.tintColor = UIColor.lightGray
            twoButton.tintColor = UIColor.defaultBlue
            threeButton.tintColor = UIColor.lightGray
        case 2:
            oneButton.tintColor = UIColor.lightGray
            twoButton.tintColor = UIColor.lightGray
            threeButton.tintColor = UIColor.defaultBlue
        default:
            oneButton.tintColor = UIColor.defaultBlue
            twoButton.tintColor = UIColor.lightGray
            threeButton.tintColor = UIColor.lightGray
        }
        refreshLocations()
    }
    
    @IBAction func refreshScreenPressed(_ sender: UIBarButtonItem) {
        refreshLocations()
    }
    
    func enableButtons(isEnabled : Bool) {
        addButton.isEnabled = isEnabled
        trashButton.isEnabled = isEnabled
        oneButton.isEnabled = isEnabled
        twoButton.isEnabled = isEnabled
        threeButton.isEnabled = isEnabled
        refreshButton.isEnabled = isEnabled
    }
    ///////////////////////////////////////////
    //MARK: - Formatting and fetching functions
    //TODO:
    
    func getImage(_ url:String,handler: @escaping (UIImage?)->Void) {
        //print(url)
        Alamofire.request(url, method: .get).responseImage { response in
            if let data = response.result.value {
                handler(data)
            } else {
                handler(nil)
            }
        }
    }
    
    func returnTimeFromString(from: Int, to: Int, myString: String) -> String {
        //let my
        let myString = String(myString[from - 1..<to - 1])
        let myInt : Int = Int(myString)!
        let myIntString : String = String(myInt)
        let myIntMinus12String : String = String(myInt - 12)
        if myInt > 11 {
            if myInt == 12 {
                return "12pm"
            } else {
                return myIntMinus12String + "pm"
            }
        }
        else if myInt == 0 {
            return "12am"
        }
        else {
            return myIntString + "am"
        }
    }
    
    func returnDateFromString(from: Int, to: Int, myString: String) -> String {
        //let my
        let myString = String(myString[from - 1..<to - 1])
        return myString
    }

    func refreshLocations() {
        locationManager.delegate = self // i.e. curret class WeatherViewController
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    ///////////////////////////////////////////
    //MARK: - Table view outlet, functions
    //TODO:
    
    @IBOutlet var myTableView: UITableView!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentRow = indexPath.row - 1
        print("row: \(self.currentRow)")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return howManyRowsAreThere
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myWeatherTableViewCell", for: indexPath) as! WeatherTableViewCell
        let myWeatherData = myExtWeatherArray[currentCityCollection].weatherArray[indexPath.row]
        if indexPath.row % 2 == 0 {
            //even Number
            cell.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1.0)
        } else {
            // Odd number
            cell.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:1.0)
        }

        if myWeatherData.temperature.count > 0 {
            cell.cityLabel?.text = myWeatherData.city
            cell.dateLabel?.text = String(myWeatherData.date[0 + setOfSixIndexMultiplied])
            cell.Label21?.text = String(myWeatherData.temperature[0 + setOfSixIndexMultiplied]) + "\r\n" + String(myWeatherData.startTime[0 + setOfSixIndexMultiplied])
            cell.Label22?.text = String(myWeatherData.temperature[1 + setOfSixIndexMultiplied]) + "\r\n" + String(myWeatherData.startTime[1 + setOfSixIndexMultiplied])
            cell.Label23?.text = String(myWeatherData.temperature[2 + setOfSixIndexMultiplied]) + "\r\n" + String(myWeatherData.startTime[2 + setOfSixIndexMultiplied])
            cell.Label24?.text = String(myWeatherData.temperature[3 + setOfSixIndexMultiplied]) + "\r\n" + String(myWeatherData.startTime[3 + setOfSixIndexMultiplied])
            cell.Label25?.text = String(myWeatherData.temperature[4 + setOfSixIndexMultiplied]) + "\r\n" + String(myWeatherData.startTime[4 + setOfSixIndexMultiplied])
            cell.Label26?.text = String(myWeatherData.temperature[5 + setOfSixIndexMultiplied]) + "\r\n" + String(myWeatherData.startTime[5 + setOfSixIndexMultiplied])
        }
        if myWeatherData.condition.count > 0 {
            cell.Label31?.text = myWeatherData.condition[0 + setOfSixIndexMultiplied]
            cell.Label32?.text = myWeatherData.condition[1 + setOfSixIndexMultiplied]
            cell.Label33?.text = myWeatherData.condition[2 + setOfSixIndexMultiplied]
            cell.Label34?.text = myWeatherData.condition[3 + setOfSixIndexMultiplied]
            cell.Label35?.text = myWeatherData.condition[4 + setOfSixIndexMultiplied]
            cell.Label36?.text = myWeatherData.condition[5 + setOfSixIndexMultiplied]
        }
        if myWeatherData.wind.count > 0 {
            cell.Label41?.text = myWeatherData.wind[0 + setOfSixIndexMultiplied].replacingOccurrences(of: "mph", with: "")
            cell.Label42?.text = myWeatherData.wind[1 + setOfSixIndexMultiplied].replacingOccurrences(of: "mph", with: "")
            cell.Label43?.text = myWeatherData.wind[2 + setOfSixIndexMultiplied].replacingOccurrences(of: "mph", with: "")
            cell.Label44?.text = myWeatherData.wind[3 + setOfSixIndexMultiplied].replacingOccurrences(of: "mph", with: "")
            cell.Label45?.text = myWeatherData.wind[4 + setOfSixIndexMultiplied].replacingOccurrences(of: "mph", with: "")
            cell.Label46?.text = myWeatherData.wind[5 + setOfSixIndexMultiplied].replacingOccurrences(of: "mph", with: "")
        }
        if myWeatherData.imageUrl.count > 0 {
            cell.Image11?.downloaded(from: myWeatherData.imageUrl[0 + setOfSixIndexMultiplied])
            cell.Image12?.downloaded(from: myWeatherData.imageUrl[1 + setOfSixIndexMultiplied])
            cell.Image13?.downloaded(from: myWeatherData.imageUrl[2 + setOfSixIndexMultiplied])
            cell.Image14?.downloaded(from: myWeatherData.imageUrl[3 + setOfSixIndexMultiplied])
            cell.Image15?.downloaded(from: myWeatherData.imageUrl[4 + setOfSixIndexMultiplied])
            cell.Image16?.downloaded(from: myWeatherData.imageUrl[5 + setOfSixIndexMultiplied])
        }
        return cell
    }
    
    ///////////////////////////////////////////
    //MARK: - Weather Data functions
    //TODO:
    
    func getWeatherDataFormUSGovAPI (index: Int, url: String, long: Double, lat: Double) {
        let myUrl : String = url + String(lat) + "," + String(long)
        //print (myUrl)
        Alamofire.request(myUrl, method: .get).responseJSON {
            response in  // this is a closure so declare self
            if response.result.isSuccess {
                let weatherJSON : JSON = JSON(response.result.value!)
                //print(weatherJSON)
                if let tempResult:String = weatherJSON["properties"]["relativeLocation"]["properties"]["city"].string{
                    //print(tempResult)
                    self.myExtWeatherArray[self.currentCityCollection].weatherArray[index].city = tempResult
                }
                if let tempResult:String = weatherJSON["properties"]["relativeLocation"]["properties"]["state"].string{
                    //print(tempResult)
                    self.myExtWeatherArray[self.currentCityCollection].weatherArray[index].city += ", " + tempResult
                }
                if let tempResult:String = weatherJSON["properties"]["forecastHourly"].string{
                    //print(tempResult)
                    Alamofire.request(tempResult, method: .get).responseJSON {
                        response in  // this is a closure so declare self
                        if response.result.isSuccess {
                            let weatherJSON : JSON = JSON(response.result.value!)
                            //print(weatherJSON)
                            //print(url + String(lat) + String(long))
                            self.updateWeatherDataObject(index: index, json: weatherJSON)
                        } else {
                            print ("Error \(String(describing: response.result.error))")
                        }
                    }
                }
            } else {
                print ("Error \(String(describing: response.result.error))")
            }
        }
        
    }
    
    func updateWeatherDataObject(index: Int,json : JSON) {
        if let tempResult:[JSON] = json["properties"]["periods"].arrayValue{ //swifty json make this notation easy, the if check if it can cast to double, if it is nil then the routine just does not run
            //print(tempResult.count)
            for myResult in tempResult {
                //print(myResult["shortForecast"])
                //print(myResult["temperature"])
                myExtWeatherArray[currentCityCollection].weatherArray[index].temperature.append(myResult["temperature"].intValue )
                myExtWeatherArray[currentCityCollection].weatherArray[index].condition.append(myResult["shortForecast"].string ?? "")
                myExtWeatherArray[currentCityCollection].weatherArray[index].wind.append((myResult["windSpeed"].string ?? " ") + (myResult["windDirection"].string ?? " "))
                myExtWeatherArray[currentCityCollection].weatherArray[index].imageUrl.append(myResult["icon"].string ?? "")
                let myHourString : String = myResult["startTime"].string ?? ""
                let myDateString : String = myHourString
            myExtWeatherArray[currentCityCollection].weatherArray[index].startTime.append(returnTimeFromString(from: 12, to: 14, myString: myHourString))
                myExtWeatherArray[currentCityCollection].weatherArray[index].date.append(returnDateFromString(from: 6, to: 11, myString: myDateString))
            }
            howManyRowsAreThere = myExtWeatherArray[currentCityCollection].weatherArray.count
            myTableView.reloadData()
        }
        else {
            print("Dude I could not get stuff!")
        }
    }
    
    func resetWeatherDataObject(howMany: Int) {
        myExtWeatherArray[currentCityCollection].weatherArray.removeAll()
        for _ in 0..<howMany+1 {
            myExtWeatherArray[currentCityCollection].weatherArray.append(WeatherDataType(id: 0, city: "", temperature: [], condition: [], wind: [], imageUrl: [], startTime: [], date:[]))
        }
    }
    
    ///////////////////////////////////////////
    //MARK: - Current location functions
    //TODO:
    
    func removeAllTowns() {
        myTowns.removeAll()
    }

    func userEnteredANewCityName(index: Int, city: String){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city) {
            placemarks, error in
            let placemark = placemarks?.first
            let lat1 = placemark?.location?.coordinate.latitude
            let lon1 = placemark?.location?.coordinate.longitude
            //print("Lat: \(String(describing: lat1)), Lon: \(String(describing: lon1))")
            self.getWeatherDataFormUSGovAPI(index: index, url: self.WEATHER_URL,long:lon1 ?? 0,lat:lat1 ?? 0)
        }
    }
    
    ///////////////////////////////////////////
    //MARK: - Current location functions
    //TODO:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            resetWeatherDataObject(howMany : myTowns[currentCityCollection].towns.count)
            //print("longitude =" + String(location.coordinate.longitude) + ", latitude =" + String(location.coordinate.latitude))
            getWeatherDataFormUSGovAPI(index: 0, url: WEATHER_URL,long: location.coordinate.longitude,lat: location.coordinate.latitude)
            for myIndex in 0..<myTowns[currentCityCollection].towns.count {
                print(myIndex)
                userEnteredANewCityName(index: myIndex + 1, city: myTowns[currentCityCollection].towns.self[myIndex])
            }
            enableButtons(isEnabled: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        //cityLabel.text = "Dude I don't know where you are"
    }
    
}
