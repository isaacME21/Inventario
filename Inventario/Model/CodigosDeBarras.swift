//
//  CodigosDeBarras.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 11/24/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import Foundation
import UIKit

class CodigosDeBarras {
    
    func generadorDeCodigosDeBarra(Referencia : String , op : Int) -> UIImage?{
        
        switch op {
        case 1:
            return generatePDF417Barcode(from: Referencia)
        case 2:
            return generateCode128Barcode(from: Referencia)
        case 3:
            return generateQRBarcode(from: Referencia)
        case 4:
            return generateAztecBarcode(from: Referencia)
        default:
            return generatePDF417Barcode(from: Referencia)
        }
        
    }
    
    func generatePDF417Barcode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIPDF417BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    
    func generateCode128Barcode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    
    func generateQRBarcode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    func generateAztecBarcode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIAztecCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    
    
}
