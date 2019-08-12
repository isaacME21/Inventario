//
//  ArticulosPOS.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 6/30/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import Foundation
import UIKit

class ArticulosPOS {
    var image : UIImage?
    var name : String
    var num : Int
    var precio : Double?
    var seleccionado : Int = 0
    var comprado : Bool = false
    
    init(nombre : String, numero : Int) {
        self.name = nombre
        self.num = numero
    }
}
