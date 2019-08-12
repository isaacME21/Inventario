//
//  File.swift
//  Inventario
//
//  Created by DW Software on 7/31/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit

class Zapatos {
    var zapatoName : String?
    var talla : String = ""
    var proovedor : String = ""
    var referencia : String = ""
    var precioDeVenta : String = ""
    var precioDeCompra : String = ""
    var beneficioBruto : String = ""
    var margen : String = ""
    var impuestos : String = ""
    
    init(name : String) {
        self.zapatoName = name
    }
}
