//
//  PairingViewController.swift
//  konoiro-paint
//
//  Created by 橋本晄汰 on 2026/07/28.
//

import UIKit
import CoreBluetooth

class PairingViewController: UIViewController, BLEManagerDelegate, CBPeripheralDelegate, CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    let bleManager = BLEManager.shared
    var centralManager: CBCentralManager?
    
    var bleArray = [String]()
    var bleItems = [CBPeripheral]()
    var selectedPeripheral: CBPeripheral?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print("hello")
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        self.tableView.reloadData()
        print("bye")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.bleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //セルの名前
        let identifire = "BLEItemsName"
        //セルの再利用
        var cell = tableView.dequeueReusableCell(withIdentifier: identifire)
        
        if(cell == nil)
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifire)
        }
        //セルのラベルに文字を入れる
        cell?.textLabel?.text = self.bleArray[indexPath.row]
        
        //戻り値が非オプショナル型なので強制的アンラップを使って非オプショナル型にする
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        self.selectedPeripheral = self.bleItems[indexPath.row]
        //selectedPeripheral?.nameはデバイス名、使いやすくするためにperipheralNameに入れる
        //peripheralName == "BleTest"名前が一致したら
        //let peripheral = self.selectedPeripheralはperipheralに代入
        if let peripheralName = self.selectedPeripheral?.name,peripheralName == "bletest_C885414E81F0",let peripheral = self.selectedPeripheral
        {
            self.centralManager?.stopScan()
            
            //BLEManagerの関数connectにperipheralを入れる
            self.bleManager.connect(peripheral: peripheral)
            self.performSegue(withIdentifier: "showNext", sender: nil)
        }else
        {
            let alert = UIAlertController(title: "選択されたデバイスが見つかりませんでした",
                                          message: nil,
                                          preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "接続に戻る", style: .default)
            
            alert.addAction(okAction)
            self.present(alert, animated: true)
            
        }
    }
    
    func bleManagerFoundPeripheral(bleManager: BLEManager, peripheral: CBPeripheral)
    {
        print("発見しました")
        if let peripheralName = peripheral.name, peripheral.name != nil
        {   //配列にデバイス名を入れる
            self.bleArray.append(peripheralName)
            //配列にペリフェラルを入れる

            self.bleItems.append(peripheral)
            //ここで再読み込み
            self.tableView.reloadData()
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        switch (central.state)
        {
            case .poweredOn:
                //スキャンをする
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
                break
            
            default:
                break
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        print(peripheral.name)
        
        print(peripheral.identifier.uuidString)
        
        if let peripheralName = peripheral.name, peripheral.name != nil, !self.bleItems.contains(where:{ $0 == peripheral})
        {   //配列にデバイス名を入れる
            self.bleArray.append(peripheralName)
            //配列にペリフェラルを入れる
            self.bleItems.append(peripheral)
            
            self.tableView.reloadData()
        }
        
    }
    
    
    
}
