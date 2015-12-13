//
//  ViewController.swift
//  spa
//
//  Created by Daniel Müllenborn on 13/12/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

  @IBOutlet weak var datePicker: UIDatePicker!
  
  @IBOutlet weak var zenithLabel: UILabel!
  @IBOutlet weak var azimuth180: UILabel!
  @IBOutlet weak var azimuth: UILabel!
  @IBOutlet weak var incidence: UILabel!
  @IBOutlet weak var suntransit: UILabel!
  @IBOutlet weak var sunrise: UILabel!
  @IBOutlet weak var sunset: UILabel!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var altitudeLabel: UILabel!
  
  var locationManager: CLLocationManager = CLLocationManager()
  
  var altitude: CLLocationDistance?
  var latitude: CLLocationDegrees?
  var longitude: CLLocationDegrees?
  
  func initLocationManager() {
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.requestLocation()
  }
  
  @IBAction func dateChanged(sender: UIDatePicker) {
    calculateSunPosition()
  }
  
  func calculateSunPosition() {
    let location = SolarPosition.Location(
      longitude: self.longitude ?? 7,
      latitude:  self.latitude  ?? 51,
      elevation: self.altitude  ?? 50)
    
    let date = self.datePicker.date

    let result = SolarPosition.calculate(date, location: location, calculate: .ALL)
    
    updateUILabels(result)
    updateUILabels(location)
  }
  
  func updateUILabels(result: SolarPosition.OutputValues) {
    
    let sunriseMin = 60 * (result.sunrise - Double(Int(result.sunrise)))
    let sunriseSec = 60 * (sunriseMin - Double(Int(sunriseMin)))
    let sunsetMin = 60 * (result.sunset - Double(Int(result.sunset)))
    let sunsetSec = 60 * (sunsetMin - Double(Int(sunsetMin)))
    
    self.sunrise.text = "\(Int(result.sunrise)) : \(Int(sunriseMin)) : \(Int(sunriseSec))"
    self.sunset.text = "\(Int(result.sunset)) : \(Int(sunsetMin)) : \(Int(sunsetSec))"
    
    self.zenithLabel.text   = String(format: "%.3f", arguments: [result.zenith]) + " deg"
    self.azimuth180.text    = String(format: "%.3f", arguments: [result.azimuth180]) + " deg"
    self.azimuth.text       = String(format: "%.3f", arguments: [result.azimuth]) + " deg"
    self.incidence.text     = String(format: "%.3f", arguments: [result.incidence]) + " deg"
    self.suntransit.text    = String(format: "%.3f", arguments: [result.suntransit]) + " deg"
  }
  
  func updateUILabels(location: SolarPosition.Location) {
    self.longitudeLabel.text  = String(format: "%.3f", arguments: [location.longitude]) + " deg"
    self.latitudeLabel.text   = String(format: "%.3f", arguments: [location.latitude]) + " deg"
    self.altitudeLabel.text   = String(format: "%.1f", arguments: [location.elevation]) + " m"
  }
  
  override func viewDidLoad() {
    self.view.addOrChangeGradientLayerWithColors(UIColor.fieryOrange())
    super.viewDidLoad()
    initLocationManager()
  }

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    altitude = locations.last?.altitude
    latitude = locations.last?.coordinate.latitude
    longitude = locations.last?.coordinate.longitude
    self.calculateSunPosition()
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    manager.stopUpdatingLocation()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

