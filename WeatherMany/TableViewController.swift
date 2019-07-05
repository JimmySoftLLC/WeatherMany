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

struct WeatherDataType {
    
    var id : Int
    var city : String
    var temperature : [Int]
    var condition : [String]
    var wind : [String]
    
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
    
}



class TableViewController: UITableViewController, CLLocationManagerDelegate {

    //Constants
    let WEATHER_URL = "https://api.weather.gov/points/"
    
    //Declare instance variables here
    let locationManager = CLLocationManager()
    
    var weatherArray : [WeatherDataType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self // i.e. curret class WeatherViewController
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    
    @IBOutlet var myTableView: UITableView!
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myWeatherTableViewCell", for: indexPath) as! WeatherTableViewCell
        
        let myWeatherData = weatherArray[indexPath.row]
        cell.cityLabel?.text = myWeatherData.city
        cell.Label21?.text = String(myWeatherData.temperature[0])
        cell.Label22?.text = String(myWeatherData.temperature[1])
        cell.Label23?.text = String(myWeatherData.temperature[2])
        cell.Label24?.text = String(myWeatherData.temperature[3])
        cell.Label25?.text = String(myWeatherData.temperature[4])
        cell.Label26?.text = String(myWeatherData.temperature[5])
        cell.Label31?.text = myWeatherData.condition[0]
        cell.Label32?.text = myWeatherData.condition[1]
        cell.Label33?.text = myWeatherData.condition[2]
        cell.Label34?.text = myWeatherData.condition[3]
        cell.Label35?.text = myWeatherData.condition[4]
        cell.Label36?.text = myWeatherData.condition[5]
        cell.Label41?.text = myWeatherData.wind[0].replacingOccurrences(of: "mph", with: "")
        cell.Label42?.text = myWeatherData.wind[1].replacingOccurrences(of: "mph", with: "")
        cell.Label43?.text = myWeatherData.wind[2].replacingOccurrences(of: "mph", with: "")
        cell.Label44?.text = myWeatherData.wind[3].replacingOccurrences(of: "mph", with: "")
        cell.Label45?.text = myWeatherData.wind[4].replacingOccurrences(of: "mph", with: "")
        cell.Label46?.text = myWeatherData.wind[5].replacingOccurrences(of: "mph", with: "")
        return cell
    }
    
    //getWeatherData method here:
    func getWeatherData (url: String, long: Double, lat: Double) {
        let myUrl : String = url + String(lat) + "," + String(long)
        print (myUrl)
        Alamofire.request(myUrl, method: .get).responseJSON {
            response in  // this is a closure so declare self
            if response.result.isSuccess {
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                print(url + String(lat) + String(long))
                self.weatherArray.removeAll()
                self.weatherArray.append(WeatherDataType(id: 0, city: "", temperature: [], condition: [], wind: []))
                if let tempResult:String = weatherJSON["properties"]["relativeLocation"]["properties"]["city"].string{
                    print(tempResult)
                    self.weatherArray[0].city = tempResult
                }
                if let tempResult:String = weatherJSON["properties"]["relativeLocation"]["properties"]["state"].string{
                    print(tempResult)
                    self.weatherArray[0].city += ", " + tempResult
                }
                if let tempResult:String = weatherJSON["properties"]["forecastHourly"].string{
                    print(tempResult)
                    Alamofire.request(tempResult, method: .get).responseJSON {
                        response in  // this is a closure so declare self
                        if response.result.isSuccess {
                            let weatherJSON : JSON = JSON(response.result.value!)
                            print(weatherJSON)
                            print(url + String(lat) + String(long))
                            self.updateWeatherData(json: weatherJSON)
                            //self.updateUIWithWeatherData()
                        } else {
                            print ("Error \(String(describing: response.result.error))")
                            //self.cityLabel.text = ("Error \(String(describing: response.result.error))")
                        }
                    }
                }
            } else {
                print ("Error \(String(describing: response.result.error))")
                //self.cityLabel.text = ("Error \(String(describing: response.result.error))")
            }
        }
        
    }
    
    func updateWeatherData(json : JSON) {
        if let tempResult:[JSON] = json["properties"]["periods"].arrayValue{ //swifty json make this notation easy, the if check if it can cast to double, if it is nil then the routine just does not run
            print(tempResult.count)
            for myResult in tempResult {
                print(myResult["shortForecast"])
                print(myResult["temperature"])
                weatherArray[0].temperature.append(myResult["temperature"].intValue )
                weatherArray[0].condition.append(myResult["shortForecast"].string ?? "")
                weatherArray[0].wind.append((myResult["windSpeed"].string ?? " ") + (myResult["windDirection"].string ?? " "))
            }
            self.myTableView.reloadData()
        }
        else {
            //cityLabel.text = "Dude I could not get stuff!"
        }
    }

    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(city) {
            placemarks, error in
            let placemark = placemarks?.first
            let lat1 = placemark?.location?.coordinate.latitude
            let lon1 = placemark?.location?.coordinate.longitude
            print("Lat: \(String(describing: lat1)), Lon: \(String(describing: lon1))")
            self.getWeatherData(url: self.WEATHER_URL,long:lon1 ?? 0,lat:lat1 ?? 0)
        }
    }
    
    //Write the didUpdateLocations method here: this is what method that gets activate one found location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("longitude =" + String(location.coordinate.longitude) + ", latitude =" + String(location.coordinate.latitude))
            getWeatherData(url: WEATHER_URL,long: location.coordinate.longitude,lat: location.coordinate.latitude)
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
