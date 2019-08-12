//
//  CustomViewCell.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 1/31/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit

class CustomViewCell: UITableViewCell {
    

    @IBOutlet weak var Articulo: UILabel!
    @IBOutlet weak var Cantidad: UILabel!
    @IBOutlet weak var articuloUpLabel: UILabel!
    @IBOutlet weak var cantidadUpLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    
}
