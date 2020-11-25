//
//  LocationModel.swift
//  PGJManager-iOS
//
//  Created by Kevin on 2019/1/11.
//  Copyright © 2019 fg. All rights reserved.
//

import UIKit
import HandyJSON
import CoreLocation

class LocationModel: NSObject, HandyJSON {
    var location: CLLocation?
    var placemark: CLPlacemark?
    
//    var gaoDeLocation: CLLocation? {
//        if let coordinate = location?.coordinate {
//            let coor = AMapCoordinateConvert(coordinate, .GPS)
//            return CLLocation(latitude: coor.latitude, longitude: coor.longitude)
//        }
//        return nil
//    }
    required override init() { }
}

extension LocationModel {
    /// 地址
    var addressDesc: String? {
        return placemark?.locality ?? placemark?.name ?? placemark?.country
    }
    /// 经度
    var longitude: Double? {
        return location?.coordinate.longitude
    }
    /// 纬度
    var latitude: Double? {
        return location?.coordinate.latitude
    }
}
