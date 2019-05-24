import UIKit
import CoreLocation
import MapKit
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "9938110e5f36ee96092d4095337cc05a"
    
    /*
     ** -273.15 to convert from kelvin to celcius, could add toggle for conversions
     ** but since all the offices use celsius its not necessary at this moment
     **
     */
    let KELVIN_TO_CELCIUS_CONSTANT = 273.15
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var officeWeatherData: Array<WeatherDataModel> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        populateOfficeWeatherData()
    }
    
    //MARK: - Networking
    /***************************************************************/
    
    func getWeatherDataAndUpdateWeatherData(url: String, parameters: [String : String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess{
                let weatherJSON: JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.descriptionLabel.text = "Connection Issues"
            }
        }
    }
    
    func getWeatherDataModel(url: String, parameters: [String : String]) -> WeatherDataModel {
        let tempWeatherDataModel = WeatherDataModel()
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess{
                let weatherJSON: JSON = JSON(response.result.value!)
                tempWeatherDataModel.city = weatherJSON["name"].stringValue
                tempWeatherDataModel.currentTemperature = Int(weatherJSON["main"]["temp"].double! - self.KELVIN_TO_CELCIUS_CONSTANT)
                tempWeatherDataModel.latitude = weatherJSON["coord"]["lat"].doubleValue
                tempWeatherDataModel.longitude = weatherJSON["coord"]["lon"].doubleValue
            }
        }
        return tempWeatherDataModel
    }

    //MARK: - JSON Parsing
    /***************************************************************/
   
    func updateWeatherData(json: JSON){
        
        if let temperatureResult = json["main"]["temp"].double {
            weatherDataModel.currentTemperature = Int(temperatureResult - KELVIN_TO_CELCIUS_CONSTANT)
            weatherDataModel.maxTemperature = Int(json["main"]["temp_max"].double! - KELVIN_TO_CELCIUS_CONSTANT)
            weatherDataModel.minTemperature = Int(json["main"]["temp_min"].double! - KELVIN_TO_CELCIUS_CONSTANT)
            weatherDataModel.humidity = Int(json["main"]["humidity"].intValue)
            weatherDataModel.description = json["weather"][0]["description"].stringValue
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            weatherDataModel.latitude = json["coord"]["lat"].doubleValue
            weatherDataModel.longitude = json["coord"]["lon"].doubleValue
            
            updateUI()
        }
        else {
            descriptionLabel.text = "Weather Unavailable"
        }
        
    }

    //MARK: - UI Updates
    /***************************************************************/
    
    
    func updateUIWithWeatherData() {
        currentTempLabel.text = "Current Temperature: \(weatherDataModel.currentTemperature)°"
        maxTempLabel.text = "Max Temperature: \(weatherDataModel.maxTemperature)°"
        minTempLabel.text = "Min Temperature: \(weatherDataModel.minTemperature)°"
        humidityLabel.text = "Humidity: \(weatherDataModel.humidity)%"
        descriptionLabel.text = weatherDataModel.description
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    func updateUI(){
        updateUIWithWeatherData()
        updateMap()
    }
    
    func updateMap(){
        let currentLocation = CLLocationCoordinate2DMake(weatherDataModel.latitude, weatherDataModel.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: currentLocation, span: span)
        mapView.setRegion(region, animated: false)
        mapView.mapType = .standard
        let annotation = MKPointAnnotation()
        annotation.coordinate = currentLocation
        annotation.title = weatherDataModel.city
        mapView.addAnnotation(annotation);
    }
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherDataAndUpdateWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        descriptionLabel.text = "Location Unavailable"
    }
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    func userEnteredANewCityName(city: String){
        let params : [String : String] = ["q": city, "appid" : APP_ID]
        getWeatherDataAndUpdateWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    //PrepareForSegue Method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.officeWeatherData = officeWeatherData
            destinationVC.delegate = self
        }
    }
    
    func populateOfficeWeatherData() {
        let officeCityNames = ["Stockholm", "Bengaluru", "Nairobi"]
        for cityName in officeCityNames{
            var tempWeatherData = WeatherDataModel()
            let params: [String : String] = ["q": cityName, "appid" : APP_ID]
            tempWeatherData = getWeatherDataModel(url: WEATHER_URL, parameters: params)
            officeWeatherData.append(tempWeatherData)
        }
    }
}


