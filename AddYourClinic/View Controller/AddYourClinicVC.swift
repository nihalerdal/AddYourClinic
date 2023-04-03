//
//  AddYourClinicVC.swift
//  AddYourClinic
//
//  Created by Nihal Erdal on 4/1/23.
//

import UIKit
import MapKit
import CoreLocation

class AddYourClinicVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var AddYourClinic: UIButton!
    
    var addressModel = AddressModel()
    var locationManager: CLLocationManager?
    var region:  MKCoordinateRegion?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkIfLocationServicesIsEnabled()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        mapView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(handleTap(gesture: )))
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
   
    @objc func handleTap(gesture: UITapGestureRecognizer ){
        if gesture.state == .ended{
            
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            if mapView.annotations.count == 1{
                mapView.removeAnnotation(mapView.annotations.last!)
            }
            
            addAnnotaion(coordinate: coordinate)
            print("pin: \(coordinate.latitude), \(coordinate.longitude)")
            
        }
    }
    
    func checkIfLocationServicesIsEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            locationManager?.delegate = self
        }else{
            print("Show an alert to turn it on")
        }
    }
    
    @IBAction func addClinic(_ sender: Any) {
        Client.createHealthProvider(city:addressModel.city ,
                                    country: addressModel.country,
                                    name: addressModel.name,
                                    state: addressModel.state,
                                    streetAddress: addressModel.streetAddress,
                                    zipCode: addressModel.zipCode)
        { response, error in
            
            if error == nil {
                guard let response = response else {return}
                print(response)
            }else{
                print(error?.localizedDescription ?? "Unable to complete succesfully")
            }
        }
    }
        
    func addAnnotaion(coordinate: CLLocationCoordinate2D){
        
        let annotaion  = MKPointAnnotation()
        annotaion.coordinate = coordinate
        mapView.addAnnotation(annotaion)
        mapView.setCenter(mapView.centerCoordinate, animated: true)
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude,
                                  longitude: coordinate.longitude)
        geoCoder.reverseGeocodeLocation(location) { placemark, error in
            if error == nil{
                guard let placemark = placemark else {return}
                let location = placemark[0]
                annotaion.title = location.name
                if let city = location.addressDictionary!["City"] as? String{
                    self.addressModel.city = city
                }
                if let country = location.addressDictionary!["Country"] as? String{
                    self.addressModel.country = country
                }
                if let name = location.addressDictionary!["Name"] as? String{
                    self.addressModel.name = name
                }
                if let state = location.addressDictionary!["State"] as? String{
                    self.addressModel.state = state
                }
                if let streetAddress = location.addressDictionary!["Street"] as? String{
                    self.addressModel.streetAddress = streetAddress
                }
                if let zipCode = location.addressDictionary!["ZIP"] as? String{
                    self.addressModel.zipCode = zipCode
                }
                print(self.addressModel)
            }
        }
    }
    
    func checkLocationAuthorization(){
        guard let locationManager = locationManager else {return}
        
        switch locationManager.authorizationStatus{
            
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                print("Your location is restricted")
            case .denied:
                print("You have denied location permission for this app. Please go into settings to change it.")
            case .authorizedAlways, .authorizedWhenInUse:
                region = MKCoordinateRegion(center: locationManager.location!.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                addAnnotaion(coordinate: locationManager.location!.coordinate)
                mapView.setRegion(region!, animated: true)
            @unknown default:
            break
        }
    }
    
    //MARK : get notified if permission settings changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

}
