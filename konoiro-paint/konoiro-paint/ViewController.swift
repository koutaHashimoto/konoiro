//
//  ViewController.swift
//  konoiro-paint
//
//  Created by 橋本晄汰 on 2026/07/28.
//

import UIKit
import ACEDrawingView

struct paintItems {
    var name:String
    var ImageName:String
}

class ViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    var items: [paintItems] = [
        paintItems(name: "花火", ImageName: "花火"),
        paintItems(name: "ステンドグラス", ImageName: "ステンドグラス"),
        paintItems(name: "かき氷", ImageName: "かき氷")
    ]
        
    @IBOutlet weak var CollectionView: UICollectionView!
    
    // 選択したセルの値を保持する変数
    var selectedItem: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 255/255.0, green: 242/255.0, blue: 233/255.0, alpha: 1.0)
   
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    //セルに表示する内容を記載する
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        //storyboard上のセルを生成　storyboardのIdentifierで付けたものをここで設定する
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            
        let item = items[indexPath.row]
        
        // Tag 1: 画像ビュー, Tag 2: ラベル （ストーリーボードのタグ設定に合わせてください）
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            imageView.image = UIImage(named: item.ImageName)
            imageView.contentMode = .scaleAspectFit
        }
        
        if let label = cell.viewWithTag(2) as? UILabel {
            label.text = item.name
            label.textAlignment = .center
        }
        
        if let targetView = cell.viewWithTag(3) {
            targetView.layer.borderColor = UIColor.black.cgColor
            targetView.layer.borderWidth = 3.0
                }
            
        return cell
    }
    
    //セル選択時の処理
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 選択したセルの内容を保持
        selectedItem = items[indexPath.row].name


        //指定の遷移先に遷移する（最低限の処理）
        performSegue(withIdentifier: "showPaint", sender: nil)
    }


    
    // 遷移直前に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPaint" {
            if let secondVC = segue.destination as? DrawingViewController {
                secondVC.selectedItem = selectedItem
            }
        }
    }
}

