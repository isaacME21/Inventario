//
//  AlertController+Image.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 4/15/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit

extension UIAlertController{
    
    func addImage(image : UIImage)  {
        let maxSize = CGSize(width: 300, height: 300)
        let imgSize = image.size
        
        var ratio : CGFloat!
        if imgSize.width > imgSize.height{
            ratio = maxSize.width / imgSize.width
        }else{
            ratio = maxSize.height / imgSize.height
        }
        
        let scaledSize = CGSize(width: imgSize.width * ratio, height: imgSize.height * ratio)
        var resizedImage = image.imageWithSize(scaledSize)
        
        if imgSize.height > imgSize.width{
            let left = (maxSize.width - resizedImage.size.width) / 2
            resizedImage = resizedImage.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -left, bottom: 0, right: 0))
        }
        
        
        let imageAction = UIAlertAction(title: "", style: .default, handler: nil)
        imageAction.isEnabled = false
        imageAction.setValue(resizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        self.addAction(imageAction)
    }
}
