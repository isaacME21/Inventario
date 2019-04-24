//
//  RoundedImageView.swift
//  SmartCare
//
//  Created by Luis Isaac Maya on 2/9/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedImage: UIImageView {
    override init(image: UIImage?) {
        super.init(image: image)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.height / 2
        self.clipsToBounds = true
    }
}
