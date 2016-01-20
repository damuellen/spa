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
  
  @IBOutlet weak var trackingLabel: UILabel!
  
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
      self.datePicker.date = date
    }
  }
  
  func calculateSunPosition(date: NSDate) {
    let location = SolarPosition.Location(
      longitude: self.longitude ?? 7,
      latitude:  self.latitude ?? 51,
      elevation: self.altitude ?? 50)

    let result = SolarPosition.calculate(date, location: location, calculate: .ALL)
    
    let t = SolarPosition.trackingAngle(azimuth: result.azimuth, zenith: result.elevation)
    
    self.trackingLabel.text = t.stringValue
    refreshUILabels(result, location)
  }
  
  func refreshUILabels(result: SolarPosition.OutputValues, _ location: SolarPosition.Location) {
    
    self.sunrise.text        = result.sunrise.fractionalTime
    self.sunset.text         = result.sunset.fractionalTime
    self.suntransit.text     = result.suntransit.fractionalTime
    
    self.zenithLabel.text    = result.zenith.stringValue
    self.azimuth180.text     = result.azimuth180.stringValue
    self.azimuth.text        = result.azimuth.stringValue
    self.incidence.text      = result.incidence.stringValue
    
    self.longitudeLabel.text = location.longitude.stringValue
    self.latitudeLabel.text  = location.latitude.stringValue
    self.altitudeLabel.text  = String(format: "%.1f", arguments: [location.elevation]) + " m"
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

