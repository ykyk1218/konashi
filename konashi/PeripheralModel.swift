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
    
    let peripheralManager: CBPeripheralManager! // = CBPeripheralManager(delegate: nil, queue: nil, options: nil)
    let advertisementData: Dictionary = [CBAdvertisementDataLocalNameKey: "Test Devise"]
    
    let serviceUUID = CBUUID(string: NSUUID().UUIDString)
    let service: CBMutableService!
    
    let characteristicUUID = CBUUID(string: NSUUID().UUIDString)
    let properties: CBCharacteristicProperties!
    let permissions: CBAttributePermissions!
    
    let characteristic: CBMutableCharacteristic!
    
    override init() {

        self.peripheralManager = CBPeripheralManager(delegate: nil, queue: nil, options: nil)
        
        //キャラクタリスティックの作成
        properties = [CBCharacteristicProperties.Notify,
            CBCharacteristicProperties.Read,
            CBCharacteristicProperties.Write]
        permissions = [CBAttributePermissions.Readable,
            CBAttributePermissions.Writeable]
        
        self.characteristic = CBMutableCharacteristic(type: self.characteristicUUID, properties: properties, value: nil, permissions: permissions)
        
        //サービスの作成
        self.service = CBMutableService(type: self.serviceUUID, primary: true)
        
        //サービスのキャラクタリスティックを追加
        self.service.characteristics = [self.characteristic]
        
        super.init()
        self.peripheralManager.delegate = self
    }

    func advertising() {
        //ペリフェラルにサービスを追加
        self.peripheralManager.addService(service)
        
        print("アドバタイズボタンクリック")
        
        //self.peripheralManager = CBPeripheralManager(delegate: nil, queue: nil, options: nil)
        let enumName = "CBPeripheralManagerState"
        var valueName = ""
        switch self.peripheralManager.state {
        case .PoweredOff:
            valueName = enumName + "PoweredOff"
        case .PoweredOn:
            valueName = enumName + "PoweredOn"
        case .Resetting:
            valueName = enumName + "Resetting"
        case .Unauthorized:
            valueName = enumName + "Unauthorized"
        case .Unknown:
            valueName = enumName + "Unknown"
        case .Unsupported:
            valueName = enumName + "Unsupported"
        }
        print(valueName)
        
        //if self.peripheralManager.isAdvertising {
            self.peripheralManager.startAdvertising(self.advertisementData)
        //}
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        //サービスを追加した時に呼ばれる
        if (error != nil) {
            print("サービスの追加に失敗しました error:  \(error)")
            return
        }
        
        print("サービスを追加")
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        //呼び出しのリクエストがあった時に呼ばれる
        print("呼び出しリクエスト")
        
        //if request.characteristic.UUID.isEqual(self.characteristic.UUID) {
            request.value = self.characteristic.value
            self.peripheralManager.respondToRequest(request, withResult: CBATTError.Success)
        //}
        
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        print(error)
        print("アドバタイズ開始")
    }
    
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        print("state: \(peripheral.state)")
    }
    
}
