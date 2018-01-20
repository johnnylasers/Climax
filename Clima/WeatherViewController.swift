//
//  ViewController.swift
//  Climax
//


import UIKit
import CoreLocation // a lot of location-related functionalities
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherData = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        //let WeatherViewController be the delegate to tab into the location functionalities
        locationManager.delegate = self
        //desired accuracy with 1km range is good enough for a weather application
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url : String, parameters : [String : String]) {
        
        //Asynchronous request
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            
            response in // the "in" keyword specifies that response is inside a closure (function within function)
            if response.result.isSuccess {
                print("Connection successful! Got weather data!")
                
                let weatherJSON : JSON = JSON(response.result.value!)
//                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
                
            } else {
                print("Request failed: \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection issues......"
            }
        }
    }

    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON) {
        
        // use if/else to first check if we are getting back proper response
        if let tempResult = json["main"]["temp"].double {
            weatherData.temperature = Int(tempResult - 273.15)
            weatherData.city = json["name"].stringValue
            weatherData.condition = json["weather"][0]["id"].intValue
            weatherData.weatherIconName = weatherData.updateWeatherIcon(condition: weatherData.condition)
            updateUIWithWeatherData()
        } else {
            cityLabel.text = "Weather unavailable..."
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData() {
        cityLabel.text = weatherData.city
        temperatureLabel.text = "\(weatherData.temperature)℃"
        weatherIcon.image = UIImage(named : weatherData.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //[CLLocation] array of objects, with the first element being the least accurate result
        //so we would want the last element in the array
        let location = locations[locations.count - 1]
        
        //when we got the correct result, we should stop updating location to save battery life
        if location.horizontalAccuracy > 0 {
            
            locationManager.stopUpdatingLocation()
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            //building out parameters to send to the Weather API
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            getWeatherData(url : WEATHER_URL, parameters : params)
        }
        
    }
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location unavailable...."
    }
    

    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredNewCityName(city: String) {
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
}


