//
//  AdvertisModel.swift
//  konashi
//
//  Created by 小林芳樹 on 2015/11/17.
//  Copyright © 2015年 小林芳樹. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralModel: NSObject, CBPeripheralManagerDelegate {
    
    var peripheralManager: CBPeripheralManager!
    
    override init() {
        self.peripheralManager = CBPeripheralManager(delegate: nil, queue: nil, options: nil)
    }

    func advertising() {
        
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        print("state: \(peripheral.state)")
    }
    
}
