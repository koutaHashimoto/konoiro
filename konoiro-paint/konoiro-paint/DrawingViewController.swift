//
//  DrawingViewController.swift
//  konoiro-paint
//
//  Created by 橋本晄汰 on 2026/07/28.
//

import UIKit
import ACEDrawingView
import CoreBluetooth

class DrawingViewController: UIViewController,BLEManagerDelegate, CBPeripheralDelegate, CBCentralManagerDelegate {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var drawingView: ACEDrawingView!
    @IBOutlet weak var flameView: UIImageView!
    
    @IBOutlet weak var penBtn: UIButton!
    @IBOutlet weak var eraserBtn: UIButton!
    
    var selectedItem: String?
    
    var colorlist:[UIColor] = []
    
    @IBOutlet weak var colorBtn1: UIButton!
    @IBOutlet weak var colorBtn2: UIButton!
    @IBOutlet weak var colorBtn3: UIButton!
    @IBOutlet weak var colorBtn4: UIButton!
    @IBOutlet weak var colorBtn5: UIButton!
    
    var colorBtnList:[UIButton?] {return [colorBtn1,colorBtn2,colorBtn3,colorBtn4,colorBtn5] }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageName = selectedItem {
            backgroundImageView.image = UIImage(named: imageName)
            
            
        }
        
        self.view.backgroundColor = UIColor(red: 255/255.0, green: 242/255.0, blue: 233/255.0, alpha: 1.0)

        
        self.initUI()
    }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BLEManager.shared.delegate = self
    }
    
    func initUI(){
        // お絵描きシートの初期設定
        drawingView.lineColor = .black        // 最初は黒色
        drawingView.lineWidth = 15.0           // 線の太さ
        self.penBtn.isSelected = true
        self.eraserBtn.isSelected = false
        self.drawingView.drawTool = ACEDrawingToolTypePen
        
        self.penBtn.backgroundColor = .white
        self .eraserBtn.backgroundColor = .white
        
        for btn in colorBtnList {
            btn?.setTitle("", for: .normal)
            btn?.layer.cornerRadius = 8 // 少し角丸にして可愛くする
            btn?.isHidden = true        // 最初は見えなくする
        }
        
        
    }
    
    func didReceiveNewColorFromAtom(_ newColor: UIColor) {
        // すでに5色集まっていたら何もしない
        guard colorlist.count < 5 else { return }
        
        // リストに新しい色を追加
        colorlist.append(newColor)
        
        // 追加された場所のボタンに色を塗って、画面に出現させる！
        let targetIndex = colorlist.count - 1
        if targetIndex < colorBtnList.count {
            let targetButton = colorBtnList[targetIndex]
            
            targetButton?.backgroundColor = newColor // 背景をその色にする
            targetButton?.isHidden = false           // ここで表示する！
        }
    }
    
    @IBAction func colorBtnAction(_ sender: UIButton) {
        self.drawingView.drawTool = ACEDrawingToolTypePen
        
        // 押されたボタンの背景色を、そのままペンの色にする！
        if let selectedColor = sender.backgroundColor {
            self.drawingView.lineColor = selectedColor
        }
        
        // ペンモードの見た目にする
        self.penBtn.isSelected = true
        self.eraserBtn.isSelected = false
    }
    
    @IBAction func penBtnAction(_ sender: Any)
    {
        self.drawingView.drawTool = ACEDrawingToolTypePen
        
        self.penBtn.isSelected = true
        self.eraserBtn.isSelected = false
        
        self.penBtn.setImage(UIImage(named: "pen"), for: .normal)
        self.eraserBtn.setImage(UIImage(named: "eraNone"), for: .normal)

    }
    
    @IBAction func eraserBtnAction(_ sender: Any)
    {
        self.drawingView.drawTool = ACEDrawingToolTypeEraser
        
        self.eraserBtn.isSelected = true
        self.penBtn.isSelected = false
        
        self.penBtn.setImage(UIImage(named: "penNone"), for: .normal)
        self.eraserBtn.setImage(UIImage(named: "era"), for: .normal)

    }
    
    
    @IBAction func finishBtn(_ sender: Any)
    {
        if self.view.window != nil{
            self.performSegue(withIdentifier: "toResult", sender: nil)
        }
    }
    
    
    @IBAction func resetBtn(_ sender: Any)
    {
        print("★ リセットボタンが押されたよ！") // 💡ここを追加
        colorlist.removeAll()
        
        for btn in colorBtnList {
            btn?.setTitle("", for: .normal)
            btn?.backgroundColor = .clear
            btn?.isHidden = true        // 最初は見えなくする
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResult" {
            if let nextVC = segue.destination as? finishViewController {
                nextVC.backgroundImage = self.backgroundImageView.image
                nextVC.lineImage = self.drawingView.image
                nextVC.flameImage = self.flameView.image
            }
        }
    }
    
    func bleManagerDidDisconnectPeripheral(bleManager:BLEManager)
    {
        if self.view.window != nil{
            self.performSegue(withIdentifier: "toStart", sender: nil)
        }
    }
    
    
    func bleManagerDidFoundCharacteristics(bleManager: BLEManager, characteristics: [CBCharacteristic])
    {
        print("Hi")
    }
    
    func bleManagerFoundPeripheral(bleManager: BLEManager, peripheral: CBPeripheral)
    {
        print("よろしく")
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        print("やあ")
    }
    
    //値を受け取る関数
    // 値を受け取る関数（パターンA：文字列パース版）
    func bleManagerDidUpdateValue(bleManager: BLEManager, characteristic: CBCharacteristic, data: Data) {
        print("こんにちは")
        guard let value = characteristic.value else { return }
        
        // 送られてきたデータを文字列に変換 (例: "R:255 G:87 B:51\n")
        let rawString = String(data: value, encoding: .utf8) ?? ""
        print("受信文字列: \(rawString)")
        
        // メインスレッドでUI更新
        DispatchQueue.main.async {
            if let receivedColor = UIColor(rgbString: rawString) {
                self.didReceiveNewColorFromAtom(receivedColor)
            } else {
                print("色の解析に失敗しました")
            }
        }
    }
}

    // MARK: - UIColor Extension (文字列パース用)
    extension UIColor {
        convenience init?(rgbString: String) {
            // 文字列から数字だけを抽出する
            let components = rgbString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            // 空白を除外して数字の配列にする (例: ["255", "", "", "87", "", "", "51"]) -> ["255", "87", "51"]
            let numbers = components.filter { !$0.isEmpty }.compactMap { Int($0) }
            
            // R, G, B の3つの数字がちゃんと取れているかチェック
            guard numbers.count >= 3 else { return nil }
            
            let r = CGFloat(numbers[0]) / 255.0
            let g = CGFloat(numbers[1]) / 255.0
            let b = CGFloat(numbers[2]) / 255.0
            
            self.init(red: r, green: g, blue: b, alpha: 1.0)
        }
    }
    
    

