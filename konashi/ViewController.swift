//
//  ViewController.swift
//  konashi
//
//  Created by 小林芳樹 on 2015/11/08.
//  Copyright © 2015年 小林芳樹. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation
import AudioToolbox

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, CLLocationManagerDelegate {
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var settingCharacteristic: CBCharacteristic!
    var outputCharacteristic: CBCharacteristic!
    var locationManager: CLLocationManager!
    
    let peripheralModel:PeripheralModel = PeripheralModel()
    
    let stateLbl:UILabel = UILabel(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 100, 30, 200, 50))
    let connectBtn:UIButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 100, 80, 200, 50))
    
    let advertisBtn:UIButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 100, 130, 200, 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.startUpdatingHeading()
        
        self.stateLbl.text = "未接続"
        self.connectBtn.setTitle("接続する", forState: UIControlState.Normal)
        self.connectBtn.addTarget(self, action: "startConnect", forControlEvents: .TouchUpInside)
        self.connectBtn.backgroundColor = UIColor.redColor()
        
        self.advertisBtn.setTitle("アドバタイズする", forState: UIControlState.Normal)
        self.advertisBtn.addTarget(self.peripheralModel, action: "advertising", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(self.stateLbl)
        self.view.addSubview(self.connectBtn)
        
    }
    
    func startConnect() {
        if (self.peripheral != nil) {
            self.centralManager.connectPeripheral(self.peripheral, options: nil)
        }
    }
    
    func killConnect() {
        if (self.peripheral != nil) {
            self.centralManager.cancelPeripheralConnection(self.peripheral)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func centralManagerDidUpdateState(central: CBCentralManager) {
        //CentralManagerの状態変化を取得
        print("state: \(central.state)")
        
        switch (central.state) {
        case CBCentralManagerState.PoweredOn:
                self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
        default:
                break

        }
        
    }
    
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        //周辺デバイスが見つかると呼ばれる
        print("発見したBLEデバイス： \(peripheral)")
        
        self.peripheral = peripheral
        
//        self.centralManager.connectPeripheral(self.peripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        //周辺デバイスに接続したときに呼ばれる
        print("接続成功！")
        self.stateLbl.text = "接続成功"
        
        self.peripheral.delegate = self
        peripheral.readRSSI()
        peripheral.discoverServices(nil)
        
        self.connectBtn.addTarget(self, action: "killConnect", forControlEvents: .TouchUpInside)
        self.connectBtn.setTitle("接続を切る", forState: UIControlState.Normal)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        //接続が失敗した時に呼ばれる
        print("接続失敗")
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        //接続が切れた時に呼ばれる
        print("接続が切れました")
        
        self.connectBtn.setTitle("接続する", forState: UIControlState.Normal)
        self.connectBtn.addTarget(self, action: "startConnect", forControlEvents: .TouchUpInside)
    }
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        //接続したペリフェラルからサービスが見つかった時に呼ばれる
        let services: NSArray = peripheral.services!
        print("\(services.count)個のサービスを発見！\(services)")
        
        for obj in services {
            if let service  = obj as? CBService {
                //キャラクタリスティックを探索開始
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        // キャラクタリスティックが見つかった時に呼ばれる
        let characteristics: NSArray = service.characteristics!
        print("\(characteristics.count)個のキャラクタリスティックを発見！")
        
        //書き込むデータ
        var value: CUnsignedChar = 0x01 << 1
        let data:NSData = NSData(bytes: &value, length: 1)
        
        for obj in characteristics {
            if let characteristic = obj as? CBCharacteristic {
                
                if characteristic.UUID.isEqual(CBUUID(string: "3000")) {
                    self.settingCharacteristic = characteristic
                    self.peripheral.writeValue(data, forCharacteristic: self.settingCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)
                    
                }else if characteristic.UUID.isEqual(CBUUID(string: "3002")) {
                    self.outputCharacteristic = characteristic
                    self.peripheral.writeValue(data, forCharacteristic: self.outputCharacteristic, type: CBCharacteristicWriteType.WithoutResponse)

                }
                /*
                if characteristic.properties == CBCharacteristicProperties.Read {
                    //読み出し可能なプロパティのみを取り出す
                    peripheral.readValueForCharacteristic(characteristic)
                }else if characteristic.properties == CBCharacteristicProperties.Write {
                    //書き込み可能なプロパティのみを取り出す
                    peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
                }
                */
            }
        }
        

    }
    
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        //キャラクタリスティックのvalueを取り出した
        print("読み出し成功！service uuid: \(characteristic.service.UUID), characteristic uuid \(characteristic.UUID), value: \(characteristic.value)")
        
        //if characteristic.UUID.isEqual(<#T##object: AnyObject?##AnyObject?#>)
    }
    
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("書き込み完了！")
    }
    
    func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
        print("RSSI: " + String(RSSI))
        if Int(RSSI) < -50 {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //コンパス機能を使って方位を変更すると同時にrssiを取得するようにする
        if self.peripheral != nil{
            self.peripheral.readRSSI()
        }

    }
    

}

