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

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
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
    //let s = "hello"
    //s[0..<3] // "hel"
    //s[3..<s.count] // "lo"
}



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

class TableViewController: UITableViewController, CLLocationManagerDelegate {

    //Constants
    let WEATHER_URL = "https://api.weather.gov/points/"
    
    //Declare instance variables here
    let locationManager = CLLocationManager()
    
    var weatherArray : [WeatherDataType] = []
    
    var howManyRowsAreThere : Int = 0
    
    var setOfSixIndex : Int = 0
    var setOfSixIndexMultiplied : Int = 0
    
    func refreshLocations() {

    }
    
    @IBAction func prevButtonPressed(_ sender: UIBarButtonItem) {
        setOfSixIndex -= 1
        if setOfSixIndex < 0 {
            setOfSixIndex = 0
        }
        setOfSixIndexMultiplied = setOfSixIndex * 6
        print (setOfSixIndexMultiplied)
        myTableView.reloadData()
    }
    
    @IBAction func nextButton(_ sender: UIBarButtonItem) {
        setOfSixIndex += 1
        if setOfSixIndex > 25 {
            setOfSixIndex = 25
        }
        setOfSixIndexMultiplied = setOfSixIndex * 6
        print (setOfSixIndexMultiplied)
        myTableView.reloadData()
    }
    
    
    @IBAction func refreshScreenPressed(_ sender: UIBarButtonItem) {
        locationManager.delegate = self // i.e. curret class WeatherViewController
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self // i.e. curret class WeatherViewController
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    @IBOutlet var myTableView: UITableView!
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return howManyRowsAreThere
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myWeatherTableViewCell", for: indexPath) as! WeatherTableViewCell
        let myWeatherData = weatherArray[indexPath.row]
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
    
    //getWeatherData method here:
    func getWeatherData (index: Int, url: String, long: Double, lat: Double) {
        let myUrl : String = url + String(lat) + "," + String(long)
        //print (myUrl)
        Alamofire.request(myUrl, method: .get).responseJSON {
            response in  // this is a closure so declare self
            if response.result.isSuccess {
                let weatherJSON : JSON = JSON(response.result.value!)
                //print(weatherJSON)
                if let tempResult:String = weatherJSON["properties"]["relativeLocation"]["properties"]["city"].string{
                    print(tempResult)
                    self.weatherArray[index].city = tempResult
                }
                if let tempResult:String = weatherJSON["properties"]["relativeLocation"]["properties"]["state"].string{
                    print(tempResult)
                    self.weatherArray[index].city += ", " + tempResult
                }
                if let tempResult:String = weatherJSON["properties"]["forecastHourly"].string{
                    //print(tempResult)
                    Alamofire.request(tempResult, method: .get).responseJSON {
                        response in  // this is a closure so declare self
                        if response.result.isSuccess {
                            let weatherJSON : JSON = JSON(response.result.value!)
                            print(weatherJSON)
                            //print(url + String(lat) + String(long))
                            self.updateWeatherData(index: index, json: weatherJSON)
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
    
    func updateWeatherData(index: Int,json : JSON) {
        if let tempResult:[JSON] = json["properties"]["periods"].arrayValue{ //swifty json make this notation easy, the if check if it can cast to double, if it is nil then the routine just does not run
            print(tempResult.count)
            for myResult in tempResult {
                //print(myResult["shortForecast"])
                //print(myResult["temperature"])
                weatherArray[index].temperature.append(myResult["temperature"].intValue )
                weatherArray[index].condition.append(myResult["shortForecast"].string ?? "")
                weatherArray[index].wind.append((myResult["windSpeed"].string ?? " ") + (myResult["windDirection"].string ?? " "))
                weatherArray[index].imageUrl.append(myResult["icon"].string ?? "")
                let myHourString : String = myResult["startTime"].string ?? ""
                let myDateString : String = myHourString
                weatherArray[index].startTime.append(returnTimeFromString(from: 12, to: 14, myString: myHourString))
                weatherArray[index].date.append(returnDateFromString(from: 6, to: 11, myString: myDateString))
            }
            howManyRowsAreThere = weatherArray.count
            myTableView.reloadData()
        }
        else {
            print("Dude I could not get stuff!")
        }
    }
    
    func resetWeatherData() {
        self.weatherArray.removeAll()
        self.weatherArray.append(WeatherDataType(id: 0, city: "", temperature: [], condition: [], wind: [], imageUrl: [], startTime: [], date:[]))
        self.weatherArray.append(WeatherDataType(id: 0, city: "", temperature: [], condition: [], wind: [], imageUrl: [], startTime: [], date:[]))
        self.weatherArray.append(WeatherDataType(id: 0, city: "", temperature: [], condition: [], wind: [], imageUrl: [], startTime: [], date:[]))
        self.weatherArray.append(WeatherDataType(id: 0, city: "", temperature: [], condition: [], wind: [], imageUrl: [], startTime: [], date:[]))
        self.weatherArray.append(WeatherDataType(id: 0, city: "", temperature: [], condition: [], wind: [], imageUrl: [], startTime: [], date:[]))
        self.weatherArray.append(WeatherDataType(id: 0, city: "", temperature: [], condition: [], wind: [], imageUrl: [], startTime: [], date:[]))
        self.weatherArray.append(WeatherDataType(id: 0, city: "", temperature: [], condition: [], wind: [], imageUrl: [], startTime: [], date:[]))
    }

    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(index: Int, city: String){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city) {
            placemarks, error in
            let placemark = placemarks?.first
            let lat1 = placemark?.location?.coordinate.latitude
            let lon1 = placemark?.location?.coordinate.longitude
            //print("Lat: \(String(describing: lat1)), Lon: \(String(describing: lon1))")
            self.getWeatherData(index: index, url: self.WEATHER_URL,long:lon1 ?? 0,lat:lat1 ?? 0)
        }
    }
    
    //Write the didUpdateLocations method here: this is what method that gets activate one found location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            resetWeatherData()
            //print("longitude =" + String(location.coordinate.longitude) + ", latitude =" + String(location.coordinate.latitude))
            getWeatherData(index: 0, url: WEATHER_URL,long: location.coordinate.longitude,lat: location.coordinate.latitude)
            userEnteredANewCityName(index: 1, city: "Ellendale DE")
            userEnteredANewCityName(index: 2, city: "Denton MD")
            userEnteredANewCityName(index: 3, city: "Grasonville MD")
            userEnteredANewCityName(index: 4, city: "Annapolis MD")
            userEnteredANewCityName(index: 5, city: "Arlington VA")
            userEnteredANewCityName(index: 6, city: "Tappahannock VA")
        }
    }
    
    //Write the didFailWithError method here: this method get triggered if there was an emmrror
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        //cityLabel.text = "Dude I don't know where you are"
    }
    
    func updateUIWithWeatherData() {
        //cityLabel.text = weatherDataModel.city
        //temperatureLabel.text = String(weatherDataModel.temperature) + "°" // or "\(weatherDataModel.temperature)"
        //weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
}
