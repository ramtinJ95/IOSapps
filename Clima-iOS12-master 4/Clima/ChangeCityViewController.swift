import UIKit
import MapKit
import CoreLocation


protocol ChangeCityDelegate{
    func userEnteredANewCityName(city: String)
}

class ChangeCityViewController: UIViewController {
    
    var officeWeatherData: Array<WeatherDataModel> = []
    var delegate : ChangeCityDelegate?
    

    @IBOutlet weak var changeCityTextField: UITextField!
    @IBOutlet weak var stockholmTempLabel: UILabel!
    @IBOutlet weak var bengaluruTempLabel: UILabel!
    @IBOutlet weak var nairobiTempLabel: UILabel!
    @IBOutlet weak var stockholmMapView: MKMapView!
    @IBOutlet weak var bengaluruMapView: MKMapView!
    @IBOutlet weak var nairobiMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    
    //MARK: - Set up view
    /***************************************************************/
    func setup() {
        updateLabels()
        updateMaps()
    }
    func updateLabels() {
        stockholmTempLabel.text = String(officeWeatherData[0].currentTemperature) + "°"
        bengaluruTempLabel.text = String(officeWeatherData[1].currentTemperature) + "°"
        nairobiTempLabel.text   = String(officeWeatherData[2].currentTemperature) + "°"
    }
    
    func updateMaps() {
        for i in 0...(officeWeatherData.count - 1){
            let currentLocation = CLLocationCoordinate2DMake(officeWeatherData[i].latitude, officeWeatherData[i].longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            let region = MKCoordinateRegion(center: currentLocation, span: span)
            switch (i) {
                
            case 0 :
                stockholmMapView.setRegion(region, animated: false)
                stockholmMapView.mapType = .standard
                let annotation = MKPointAnnotation()
                annotation.coordinate = currentLocation
                annotation.title = officeWeatherData[i].city
                stockholmMapView.addAnnotation(annotation)  
            case 1 :
                bengaluruMapView.setRegion(region, animated: false)
                bengaluruMapView.mapType = .standard
                let annotation = MKPointAnnotation()
                annotation.coordinate = currentLocation
                annotation.title = officeWeatherData[i].city
                bengaluruMapView.addAnnotation(annotation)
            case 2 :
                nairobiMapView.setRegion(region, animated: false)
                nairobiMapView.mapType = .standard
                let annotation = MKPointAnnotation()
                annotation.coordinate = currentLocation
                annotation.title = officeWeatherData[i].city
                nairobiMapView.addAnnotation(annotation)
            default:
                print("Look at your officeWeatherData array size, it seems to be different than expected")
            }
        }
    }
    
    //MARK: - Button Logic
    /***************************************************************/
    
    @IBAction func getStockholmWeatherDetails(_ sender: Any) {
        delegateHelper(cityName: "Stockholm")
    }
    
    @IBAction func getBengaluruWeatherDetails(_ sender: Any) {
        delegateHelper(cityName: "Bengaluru")
    }
    
    @IBAction func getNairobiWeatherDetails(_ sender: Any) {
        delegateHelper(cityName: "Nairobi")
    }
    

    
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        let cityName = changeCityTextField.text!
        delegateHelper(cityName: cityName)
    }
    
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func delegateHelper(cityName: String){
        //1 If we have a delegate set, call the method userEnteredANewCityName
        delegate?.userEnteredANewCityName(city: cityName)
        //2 dismiss the Change City View Controller to go back to the WeatherViewController
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
