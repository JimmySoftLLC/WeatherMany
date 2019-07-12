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

struct citiesWeatherDataType {
    var id : Int
    var city : String
    var temperature : [Int]
    var condition : [String]
    var wind : [String]
    var imageUrl : [String]
    var startTime : [String]
    var date: [String]
    var alert : String
    var alertDescription : String
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
    
    @IBOutlet weak var alertLabel: UILabel!
    
}

class GroupOfCitiesWeatherDataClass {
    var citiesWeatherData : [citiesWeatherDataType] = []
}

class GroupOfCitiesClass {
    var cities : [String] = []
}

class TableViewController: UITableViewController, CLLocationManagerDelegate {

    //Constants
    let WEATHER_URL = "https://api.weather.gov/points/"
    let ALERT_URL = "https://api.weather.gov/alerts/active?point="
    let locationManager = CLLocationManager()
    let defaults = UserDefaults.standard
    
    //Variables
    var groupsOfCitiesWeatherData : [GroupOfCitiesWeatherDataClass] = []
    var groupsOfCities : [GroupOfCitiesClass] = []
    var howManyCitiesAreThere : Int = 0
    var setOfSixIndex : Int = 0
    var setOfSixIndexMultiplied : Int = 0
    var currentSelectedRow : Int = 0
    var currentCitiesGroup : Int = 0
    let howManyGroupsToCreate : Int = 5
    
    ///////////////////////////////////////////
    //MARK: - View did load
    //TODO:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize the data objects used by the app
        for _ in 0..<howManyGroupsToCreate {
            let myGroupOfCitiesWeatherData: GroupOfCitiesWeatherDataClass = GroupOfCitiesWeatherDataClass.init()
            groupsOfCitiesWeatherData.append(myGroupOfCitiesWeatherData)
            let myGroupOfCities: GroupOfCitiesClass = GroupOfCitiesClass.init()
            groupsOfCities.append(myGroupOfCities)
        }
        
        //Get the data from device storage
        currentCitiesGroup = defaults.integer(forKey: "CurrentCitiesGroup")
        if defaults.array(forKey: "Cities1") != nil {
            groupsOfCities[0].cities = defaults.array(forKey: "Cities1") as! [String]
        }
        if defaults.array(forKey: "Cities2") != nil {
            groupsOfCities[1].cities = defaults.array(forKey: "Cities2") as! [String]
        }
        if defaults.array(forKey: "Cities3") != nil {
            groupsOfCities[2].cities = defaults.array(forKey: "Cities3") as! [String]
        }
        if defaults.array(forKey: "Cities4") != nil {
            groupsOfCities[3].cities = defaults.array(forKey: "Cities4") as! [String]
        }
        if defaults.array(forKey: "Cities5") != nil {
            groupsOfCities[4].cities = defaults.array(forKey: "Cities5") as! [String]
        }
        
        howManyCitiesAreThere = 0
        myTableView.reloadData()
        saveToDefaults()
        updatePrevAndNextButtons()
        updateCityCollectionButton(myCollectionItem: currentCitiesGroup)
        refreshLocations()
    }
    
    func saveToDefaults() {
        defaults.set(currentCitiesGroup, forKey: "CurrentCitiesGroup")
        defaults.set(groupsOfCities[0].cities, forKey: "Cities1")
        defaults.set(groupsOfCities[1].cities, forKey: "Cities2")
        defaults.set(groupsOfCities[2].cities, forKey: "Cities3")
        defaults.set(groupsOfCities[3].cities, forKey: "Cities4")
        defaults.set(groupsOfCities[4].cities, forKey: "Cities5")
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
        updateScreenNow()
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
        updateScreenNow()
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
    
    @IBOutlet weak var fourButton: UIBarButtonItem!
    
    @IBOutlet weak var fiveButton: UIBarButtonItem!
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add location", message: "Enter a location name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let mytext = textField?.text ?? ""
            if mytext != "" {
                self.groupsOfCities[self.currentCitiesGroup].cities.append(mytext)
                self.defaults.set(self.groupsOfCities[self.currentCitiesGroup].cities, forKey: "Cities1")
                self.saveToDefaults()
                self.refreshLocations()
                self.updateScreenNow()
            }else{
                let alertIfError = UIAlertController(title: "No location entered", message: "Enter a location and try again.", preferredStyle: .alert)
                alertIfError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertIfError, animated: true)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        if self.currentSelectedRow < self.groupsOfCities[self.currentCitiesGroup].cities.count && self.currentSelectedRow >= 0 {
            let alert = UIAlertController(title: "Do you want to delete this location?", message: "You can add it back later if needed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.groupsOfCities[self.currentCitiesGroup].cities.remove(at: self.currentSelectedRow)
                self.defaults.set(self.groupsOfCities[self.currentCitiesGroup].cities, forKey: "Cities1")
                self.saveToDefaults()
                self.refreshLocations()
                self.updateScreenNow()
            }))
            self.present(alert, animated: true)
        }else{
            let alertIfError = UIAlertController(title: "Invalid row selected", message: "Select a row by clicking it first and try again. Note: You cannot delete the first row which is your current location.", preferredStyle: .alert)
            alertIfError.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertIfError, animated: true)
        }
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
    
    @IBAction func fourButtonPressed(_ sender: Any) {
        updateCityCollectionButton(myCollectionItem: 3)
    }
    
    @IBAction func fiveButtonPressed(_ sender: Any) {
        updateCityCollectionButton(myCollectionItem: 4)
    }
    
    @IBAction func refreshScreenPressed(_ sender: UIBarButtonItem) {
        refreshLocations()
    }
    
    func updateCityCollectionButton(myCollectionItem : Int) {
        currentCitiesGroup = myCollectionItem
        let mySelectedColor : UIColor = UIColor.defaultBlue
        let myUnSelectedColor : UIColor = UIColor.lightGray
        switch currentCitiesGroup {
        case 0:
            oneButton.tintColor = mySelectedColor
            twoButton.tintColor = myUnSelectedColor
            threeButton.tintColor = myUnSelectedColor
            fourButton.tintColor = myUnSelectedColor
            fiveButton.tintColor = myUnSelectedColor
        case 1:
            oneButton.tintColor = myUnSelectedColor
            twoButton.tintColor = mySelectedColor
            threeButton.tintColor = myUnSelectedColor
            fourButton.tintColor = myUnSelectedColor
            fiveButton.tintColor = myUnSelectedColor
        case 2:
            oneButton.tintColor = myUnSelectedColor
            twoButton.tintColor = myUnSelectedColor
            threeButton.tintColor = mySelectedColor
            fourButton.tintColor = myUnSelectedColor
            fiveButton.tintColor = myUnSelectedColor
        case 3:
            oneButton.tintColor = myUnSelectedColor
            twoButton.tintColor = myUnSelectedColor
            threeButton.tintColor = myUnSelectedColor
            fourButton.tintColor = mySelectedColor
            fiveButton.tintColor = myUnSelectedColor
        case 4:
            oneButton.tintColor = myUnSelectedColor
            twoButton.tintColor = myUnSelectedColor
            threeButton.tintColor = myUnSelectedColor
            fourButton.tintColor = myUnSelectedColor
            fiveButton.tintColor = mySelectedColor
        default:
            oneButton.tintColor = mySelectedColor
            twoButton.tintColor = myUnSelectedColor
            threeButton.tintColor = myUnSelectedColor
            fourButton.tintColor = myUnSelectedColor
            fiveButton.tintColor = myUnSelectedColor
        }
        saveToDefaults()
        updateScreenNow()
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
        Alamofire.request(url, method: .get).responseImage { response in
            if let data = response.result.value {
                handler(data)
            } else {
                handler(nil)
            }
        }
    }
    
    func returnTimeFromString(from: Int, to: Int, myString: String) -> String {
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
    
    func returnMonthDayFromString(from: Int, to: Int, myString: String) -> String {
        let myString = String(myString[from - 1..<to - 1])
        return myString
    }
    
    func returnDayFromString(from: Int, to: Int, myString: String) -> String {
        let today = String(myString[from - 1..<to - 1])
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let todayDate = formatter.date(from: today) {
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
            let myComponents = myCalendar.components(.weekday, from: todayDate)
            let weekDay = myComponents.weekday
            switch weekDay {
            case 1:
                return "Sun"
            case 2:
                return "Mon"
            case 3:
                return "Tue"
            case 4:
                return "Wed"
            case 5:
                return "Thu"
            case 6:
                return "Fri"
            case 7:
                return "Sat"
            default:
                print("Error fetching days")
                return "Day"
            }
        } else {
            return ""
        }
    }

    func refreshLocations() {
        print ("Refreshing location")
        enableButtons(isEnabled: false)
        howManyCitiesAreThere = 0
        self.myTableView.reloadData()
        locationManager.delegate = self // i.e. curret class WeatherViewController
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    ///////////////////////////////////////////
    //MARK: - Table view outlet, functions
    //TODO:
    
    @IBOutlet var myTableView: UITableView!
    
    func updateScreenNow() {
        howManyCitiesAreThere = self.groupsOfCitiesWeatherData[self.currentCitiesGroup].citiesWeatherData.count
        myTableView.reloadData()
        updatePrevAndNextButtons()
        enableButtons(isEnabled: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentSelectedRow = indexPath.row - 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return howManyCitiesAreThere
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myWeatherTableViewCell", for: indexPath) as! WeatherTableViewCell
        if currentCitiesGroup < groupsOfCitiesWeatherData.count {
            if indexPath.row < groupsOfCitiesWeatherData[currentCitiesGroup].citiesWeatherData.count {
                let myWeatherData = groupsOfCitiesWeatherData[currentCitiesGroup].citiesWeatherData[indexPath.row]
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
                        cell.alertLabel?.text = String(myWeatherData.alert)
                        if myWeatherData.alert == "" {
                            cell.accessoryType = UITableViewCell.AccessoryType.none
                        }else{
                            cell.accessoryType = UITableViewCell.AccessoryType.detailButton
                        }
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
            }
        }
        let cellBGView = UIView()
        cellBGView.backgroundColor = UIColor(red:193/255, green:217/255, blue:247/255, alpha:1.0)
        cell.selectedBackgroundView = cellBGView
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if currentCitiesGroup < groupsOfCitiesWeatherData.count {
            if indexPath.row < groupsOfCitiesWeatherData[currentCitiesGroup].citiesWeatherData.count {
                let alert = UIAlertController(title: "Alert Details", message: groupsOfCitiesWeatherData[currentCitiesGroup].citiesWeatherData[indexPath.row].alertDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    ///////////////////////////////////////////
    //MARK: - Weather Data functions
    //TODO:
    
    func resetWeatherDataObject() {
        for myIndex in 0..<groupsOfCitiesWeatherData.count{
            for myIndex2 in 0..<groupsOfCitiesWeatherData[myIndex].citiesWeatherData.count {
                groupsOfCitiesWeatherData[myIndex].citiesWeatherData[myIndex2].id = 0
                groupsOfCitiesWeatherData[myIndex].citiesWeatherData[myIndex2].city = ""
                groupsOfCitiesWeatherData[myIndex].citiesWeatherData[myIndex2].condition = []
                groupsOfCitiesWeatherData[myIndex].citiesWeatherData[myIndex2].wind = []
                groupsOfCitiesWeatherData[myIndex].citiesWeatherData[myIndex2].imageUrl = []
                groupsOfCitiesWeatherData[myIndex].citiesWeatherData[myIndex2].startTime = []
                groupsOfCitiesWeatherData[myIndex].citiesWeatherData[myIndex2].date = []
                groupsOfCitiesWeatherData[myIndex].citiesWeatherData[myIndex2].alert = ""
            }
        }
        for myIndex in 0..<groupsOfCitiesWeatherData.count{
            groupsOfCitiesWeatherData[myIndex].citiesWeatherData.removeAll()
            for _ in 0..<groupsOfCities[myIndex].cities.count + 1 {
                groupsOfCitiesWeatherData[myIndex].citiesWeatherData.append(citiesWeatherDataType(id: 0, city: "",  temperature: [], condition: [], wind: [], imageUrl: [], startTime: [], date:[], alert: "", alertDescription: ""))
            }
        }
    }
    
    func getWeatherDataFormUSGovAPI (groupOfCitiesIndex: Int, cityIndex: Int, url: String, long: Double, lat: Double) {
        if groupOfCitiesIndex < groupsOfCitiesWeatherData.count {
            if cityIndex < groupsOfCitiesWeatherData[currentCitiesGroup].citiesWeatherData.count {
                let myUrl : String = url + String(lat) + "," + String(long)
                Alamofire.request(myUrl, method: .get).responseJSON {
                    response in
                    if response.result.isSuccess {
                        let weatherJSON : JSON = JSON(response.result.value!)
                        //print(weatherJSON)
                        if let tempResult:String = weatherJSON["properties"]["relativeLocation"]["properties"]["city"].string{
                            self.groupsOfCitiesWeatherData[groupOfCitiesIndex].citiesWeatherData[cityIndex].city = tempResult
                        }
                        if let tempResult:String = weatherJSON["properties"]["relativeLocation"]["properties"]["state"].string{
                            self.groupsOfCitiesWeatherData[groupOfCitiesIndex].citiesWeatherData[cityIndex].city += ", " + tempResult
                        }
                        if let tempResult:String = weatherJSON["properties"]["forecastHourly"].string{
                            Alamofire.request(tempResult, method: .get).responseJSON {
                                response in
                                if response.result.isSuccess {
                                    let weatherJSON : JSON = JSON(response.result.value!)
                                    self.updateGroupsOfCitiesWeatherData(groupOfCitiesIndex: groupOfCitiesIndex, cityIndex: cityIndex, json: weatherJSON)
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
        }
    }
    
    func getAlertDataFormUSGovAPI (groupOfCitiesIndex: Int, cityIndex: Int, url: String, long: Double, lat: Double) {
        let myUrl : String = url + String(lat) + "," + String(long)
        Alamofire.request(myUrl, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                let weatherJSON : JSON = JSON(response.result.value!)
                //print(weatherJSON)
                self.updateGroupsOfCitiesAlertData(groupOfCitiesIndex: groupOfCitiesIndex, cityIndex: cityIndex, json: weatherJSON)
            } else {
                print ("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    func updateGroupsOfCitiesWeatherData(groupOfCitiesIndex: Int, cityIndex: Int,json : JSON) {
        if let tempResult:[JSON] = json["properties"]["periods"].arrayValue{ //swifty json make this notation easy, the if check if it can cast to double, if it is nil then the routine just does not run
            if groupOfCitiesIndex < groupsOfCitiesWeatherData.count {
                if cityIndex < groupsOfCitiesWeatherData[currentCitiesGroup].citiesWeatherData.count {
                    for myResult in tempResult {
                        groupsOfCitiesWeatherData[groupOfCitiesIndex].citiesWeatherData[cityIndex].temperature.append(myResult["temperature"].intValue )
                        groupsOfCitiesWeatherData[groupOfCitiesIndex].citiesWeatherData[cityIndex].condition.append(myResult["shortForecast"].string ?? "")
                        groupsOfCitiesWeatherData[groupOfCitiesIndex].citiesWeatherData[cityIndex].wind.append((myResult["windSpeed"].string ?? " ") + (myResult["windDirection"].string ?? " "))
                        groupsOfCitiesWeatherData[groupOfCitiesIndex].citiesWeatherData[cityIndex].imageUrl.append(myResult["icon"].string ?? "")
                        let myHourString : String = myResult["startTime"].string ?? ""
                        let myDateString : String = myHourString
                        groupsOfCitiesWeatherData[groupOfCitiesIndex].citiesWeatherData[cityIndex].startTime.append(returnTimeFromString(from: 12, to: 14, myString: myHourString))
                        groupsOfCitiesWeatherData[groupOfCitiesIndex].citiesWeatherData[cityIndex].date.append(returnDayFromString(from: 1, to: 11, myString: myDateString) + " " + returnMonthDayFromString(from: 6, to: 11, myString: myDateString))
                    }
                    self.updateScreenNow()
                }
            }
        }
        else {
            print("Dude I could not get stuff!")
        }
    }
    
    func updateGroupsOfCitiesAlertData(groupOfCitiesIndex: Int, cityIndex: Int,json : JSON) {
        if let tempResult:[JSON] = json["features"].arrayValue{ //swifty json make this notation easy, the if check if it can cast to double, if it is nil then the routine just does not run
            if groupOfCitiesIndex < groupsOfCitiesWeatherData.count {
                if cityIndex < groupsOfCitiesWeatherData[currentCitiesGroup].citiesWeatherData.count {
                    var myAlertString : String = ""
                    var myAlertDescriptionString : String = ""
                    var myCount : Int = 0
                    for myResult in tempResult {
                        if myCount > 0 {
                            myAlertString += ", "
                            myAlertDescriptionString += "\r\n\r\n"
                        }else{
                            myAlertString += "Alert: "
                            myAlertDescriptionString += "\r\n"
                        }
                        myAlertString += (myResult["properties"]["event"].string ?? " ")
                        myAlertDescriptionString += (myResult["properties"]["event"].string ?? " ")
                        myAlertDescriptionString += "\r\n\r\n" + (myResult["properties"]["description"].string ?? " ")
                        myCount += 1
                        groupsOfCitiesWeatherData[groupOfCitiesIndex].citiesWeatherData[cityIndex].alert = myAlertString
                        groupsOfCitiesWeatherData[groupOfCitiesIndex].citiesWeatherData[cityIndex].alertDescription = myAlertDescriptionString
                    }
                    self.updateScreenNow()
                }
            }
        }
        else {
            print("Dude I could not get stuff!")
        }
    }
    
    
    ///////////////////////////////////////////
    //MARK: - enter city functions
    //TODO:

    func userEnteredANewCityName(groupOfCitiesIndex: Int, cityIndex: Int, city: String){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city) {
            placemarks, error in
            let placemark = placemarks?.first
            let lat1 = placemark?.location?.coordinate.latitude
            let lon1 = placemark?.location?.coordinate.longitude
            self.getWeatherDataFormUSGovAPI(groupOfCitiesIndex: groupOfCitiesIndex, cityIndex: cityIndex, url: self.WEATHER_URL,long:lon1 ?? 0,lat:lat1 ?? 0)
            self.getAlertDataFormUSGovAPI(groupOfCitiesIndex: groupOfCitiesIndex, cityIndex: cityIndex, url: self.ALERT_URL,long:lon1 ?? 0,lat:lat1 ?? 0)
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
            resetWeatherDataObject()
            for groupOfCitiesIndex in 0..<groupsOfCitiesWeatherData.count{
                // add current location a position 0
                getWeatherDataFormUSGovAPI(groupOfCitiesIndex: groupOfCitiesIndex, cityIndex: 0, url: WEATHER_URL,long: location.coordinate.longitude,lat: location.coordinate.latitude)
                getAlertDataFormUSGovAPI(groupOfCitiesIndex: groupOfCitiesIndex, cityIndex: 0, url: ALERT_URL,long: location.coordinate.longitude,lat: location.coordinate.latitude)
                //Add user locations
                for cityIndex in 0..<groupsOfCities[groupOfCitiesIndex].cities.count {
                    if groupOfCitiesIndex < groupsOfCitiesWeatherData.count {
                        if cityIndex < groupsOfCitiesWeatherData[currentCitiesGroup].citiesWeatherData.count {
                            userEnteredANewCityName(groupOfCitiesIndex: groupOfCitiesIndex, cityIndex: cityIndex + 1, city: groupsOfCities[groupOfCitiesIndex].cities[cityIndex])
                        }
                    }
                }
            }
        }
        enableButtons(isEnabled: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}
