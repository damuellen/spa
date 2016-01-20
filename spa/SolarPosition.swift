//
//  SolarPosition.swift
//  spa
//
//  Created by Daniel Müllenborn on 13/12/15.
//  Copyright © 2015 Daniel Müllenborn. All rights reserved.
//

import Foundation

typealias FractionalTime = Double

extension FractionalTime {
  var fractionalTime: String {
    let min = 60 * (self - Double(Int(self)))
    let sec = 60 * (min - Double(Int(min)))
    return "\(Int(self)):\(Int(min)):\(Int(sec))"
  }
}

typealias Degree = Double

extension Degree {
  var stringValue: String {
    let nf = NSNumberFormatter()
    nf.numberStyle = .DecimalStyle
    return nf.stringFromNumber(self)!
  }
}

public func deg2rad(degrees:Double) -> Double {
  return Double((M_PI / 180)) * degrees
}

public func rad2deg(radians:Double) -> Double {
  return radians * Double((180 / M_PI))
}

public final class SolarPosition {

  struct InputValues {
    var year: Int
    var month: Int
    var day: Int
    var hour: Int
    var minute: Int
    var second: Int
    var timezone: Double
    var delta_t: Double
    var longitude: Double
    var latitude: Double
    var elevation: Double
    var pressure: Double
    var temperature: Double
    var slope: Double
    var azm_rotation: Double
    var atmos_refract: Double
  }
  
  struct OutputValues {
    var zenith: Degree
    var azimuth180: Degree
    var azimuth: Degree
    var incidence: Degree
    var elevation: Degree
    var suntransit: FractionalTime
    var sunrise: FractionalTime
    var sunset: FractionalTime
  }
  
  struct Location {
    var longitude: Double
    var latitude: Double
    var elevation: Double
  }
  
  enum Output: Int32 {
    case ZA, ZA_INC, ZA_RTS, ALL
  }
  
  enum InvalidInput: ErrorType {
    case  year, month, day, hour, minute, second, pressure, temperature, delta_t, timezone, longitude, latitude, atmos_refract, elevation, slope, azm_rotation
  }
  
  static func estimateDelta_T(date: NSDate) -> Double {
    var ΔT = 62.92 + 0.32217 * (Double(date.year) - 2000)
    ΔT += 0.005589 * (Double(date.year) - 2000) ** 2
    return ΔT
  }
  
  static func calculate(date: NSDate, location: Location, calculate: Output) -> OutputValues {
    
    let timeZone = Double(NSTimeZone.localTimeZone().secondsFromGMT) / 3600
    let ΔT = estimateDelta_T(date)
    
    let values = InputValues(year: date.year, month: date.month, day: date.day, hour: date.hours, minute: date.minutes, second: date.seconds, timezone: timeZone, delta_t: ΔT, longitude: location.longitude, latitude: location.latitude, elevation: location.elevation, pressure: 1000, temperature: 20, slope: 0, azm_rotation: 0, atmos_refract: 0.5667)
    let result = SolarPosition.calculate(values, calculate: calculate)
    return result
  }
  
  static func trackingAngle(azimuth az: Degree, zenith el: Degree) -> Degree {
    
    let azimuth = deg2rad(az)
    let zenith = deg2rad(el)
    
    let rad = atan(tan(M_PI/2-zenith)*sqrt(cos(azimuth)*cos(azimuth)))
    
    return rad2deg(rad)
  }

  private static func calculate(input: InputValues, calculate: Output) -> OutputValues{

    var data = spa_data()
    data.year          = Int32(input.year)
    data.month         = Int32(input.month)
    data.day           = Int32(input.day)
    data.hour          = Int32(input.hour)
    data.minute        = Int32(input.minute)
    data.second        = Int32(input.second)
    data.timezone      = input.timezone
    data.delta_t       = input.delta_t
    data.longitude     = input.longitude
    data.latitude      = input.latitude
    data.elevation     = input.elevation
    data.pressure      = input.pressure
    data.temperature   = input.temperature
    data.slope         = input.slope
    data.azm_rotation  = input.azm_rotation
    data.atmos_refract = input.atmos_refract
    data.function      = calculate.rawValue
    
    let _ = spa_calculate(&data)
    /*
    switch result {
    case 0:
      break
    case 1:
      throw InvalidInput.year
    case 2:
      throw InvalidInput.month
    case 3:
      throw InvalidInput.day
    case 4:
      throw InvalidInput.hour
    case 5:
      throw InvalidInput.minute
    case 6:
      throw InvalidInput.second
    case 7:
      throw InvalidInput.delta_t
    case 8:
      throw InvalidInput.timezone
    case 9:
      throw InvalidInput.longitude
    case 10:
      throw InvalidInput.latitude
    case 11:
      throw InvalidInput.atmos_refract
    case 12:
      throw InvalidInput.elevation
    case 13:
      throw InvalidInput.year
    case 14:
      throw InvalidInput.slope
    case 15:
      throw InvalidInput.azm_rotation
    default:
      break
    }
    */
    
  return OutputValues(
      zenith: data.zenith,
      azimuth180: data.azimuth180,
      azimuth: data.azimuth,
      incidence: data.incidence,
      elevation:  data.e,
      suntransit: data.suntransit,
      sunrise: data.sunrise,
      sunset: data.sunset)
  }

}
