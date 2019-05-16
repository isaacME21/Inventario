//
//  ArticuloInventario.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 5/11/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import Foundation
import UIKit

class ArticuloInventario {
    var nombre : String
    var cantidad : Int = 1
    
    init(nombre : String) {
        self.nombre = nombre
    }
}
