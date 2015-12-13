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
  
  var timer: NSTimer?
  
  func initLocationManager() {
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.requestLocation()
  }
  
  @IBAction func dateChanged(sender: UIDatePicker) {
    let date = self.datePicker.date
    calculateSunPosition(date)
    timer?.invalidate()
  }
  
  @IBAction func refresh(sender: AnyObject) {
    timer?.invalidate()
    timer = Timer.scheduledTimer(1, repeats: true) { _ in
    let date = NSDate()
      self.calculateSunPosition(date)
    }
  }
  
  func calculateSunPosition(date: NSDate) {
    let location = SolarPosition.Location(
      longitude: self.longitude ?? 7,
      latitude:  self.latitude  ?? 51,
      elevation: self.altitude  ?? 50)

    let result = SolarPosition.calculate(date, location: location, calculate: .ALL)
    
    updateUILabels(result)
    updateUILabels(location)
  }
  
  func updateUILabels(result: SolarPosition.OutputValues) {
    
    self.sunrise.text     = result.sunrise.convertFractionalTime()
    self.sunset.text      = result.sunset.convertFractionalTime()
    self.suntransit.text  = result.suntransit.convertFractionalTime()
    
    self.zenithLabel.text   = result.zenith.convertDegrees()
    self.azimuth180.text    = result.azimuth180.convertDegrees()
    self.azimuth.text       = result.azimuth.convertDegrees()
    self.incidence.text     = result.incidence.convertDegrees()
  }
  
  func updateUILabels(location: SolarPosition.Location) {
    self.longitudeLabel.text  = location.longitude.convertDegrees()
    self.latitudeLabel.text   = location.latitude.convertDegrees()
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
    self.calculateSunPosition(NSDate())
  }
  
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    manager.stopUpdatingLocation()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

