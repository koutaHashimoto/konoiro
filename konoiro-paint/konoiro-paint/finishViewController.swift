//
//  finishViewController.swift
//  konoiro-paint
//
//  Created by 橋本晄汰 on 2026/07/29.
//

import UIKit
import Photos


class finishViewController: UIViewController
{
    
    @IBOutlet weak var CompletedImage: UIImageView!
    var backgroundImage: UIImage?//背景の部分
    var lineImage: UIImage?//線の部分
    var flameImage : UIImage?
    var finalCombinedImage: UIImage?//完成作品
    
    

    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 255/255.0, green: 242/255.0, blue: 233/255.0, alpha: 1.0)

        
        guard let lineImage:UIImage = self.lineImage, let backgroundImage:UIImage = self.backgroundImage, let flameImage:UIImage = self.flameImage else
        {
            print("NotImage")
            return
        }
        
        
        let newSize = CGSize(width:backgroundImage.size.width, height:backgroundImage.size.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, backgroundImage.scale)
        flameImage.draw(in: CGRect(x:0,y:0,width:newSize.width,height:newSize.height))
        
        
        backgroundImage.draw(in: CGRect(x:50,y:50,width:newSize.width-100 ,height:newSize.height-100 ))
        lineImage.draw(in: CGRect(x:50,y:50,width:newSize.width-100 ,height:newSize.height-100 ),blendMode:CGBlendMode.normal, alpha:1.0)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
                
        self.finalCombinedImage = newImage
                
                
        let screenWidth:CGFloat = view.frame.size.width
        let screenHeight:CGFloat = view.frame.size.height
        CompletedImage.image = newImage
        let newRect = CGRect(x:0, y:0, width:500, height:500)
        CompletedImage.frame = newRect
        CompletedImage.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
        self.view.addSubview(CompletedImage)

            }

            
            override func didReceiveMemoryWarning() {
                super.didReceiveMemoryWarning()
            }
    
    
    @IBAction func downloadBtn(_ sender: Any)
    {
        guard let image = CompletedImage.image else { return }

            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                guard status == .authorized || status == .limited else {
                    return
                }

                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            print("保存成功")
                        } else {
                            print(error?.localizedDescription ?? "保存失敗")
                        }
                    }
                }
            }
    }
    


}
