//
//  ViewController.swift
//  konoiro-color
//
//  Created by 橋本晄汰 on 2026/07/27.
//

import UIKit

class ViewController: UIViewController {
    
    var colorPicker = UIColorPickerViewController()
    var selectedColor = UIColor.white

    override func viewDidLoad() {
        super.viewDidLoad()
        colorPicker.delegate = self
        view.backgroundColor = selectedColor
        
        let touch = UITapGestureRecognizer(target: self, action: #selector(appearColorPicker))
        view.addGestureRecognizer(touch)
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            // ここで呼ぶことで、空振りせずにピッカーが表示されます
            appearColorPicker()
        }
    
    @IBAction func ReroadBtn(_ sender: Any)
    {
        appearColorPicker()
    }
    @objc func appearColorPicker() {
        colorPicker.supportsAlpha = false
        colorPicker.selectedColor = selectedColor
        present(colorPicker, animated: true)
    }
}

extension ViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
        view.backgroundColor = selectedColor
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        print("dismissed colorPicker")
    }
}


