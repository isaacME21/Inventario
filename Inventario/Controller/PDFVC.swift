//
//  PDFVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 5/17/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit
import TPPDF


class PDFVC: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    var reporte : [ReporteItem]?{
        didSet{
            print("Se arma")
        }
    }
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")!
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GeneratePDF()
    }
    
    
    func GeneratePDF()  {
        
        
        let document = PDFDocument(format: .a4)
        
        // Set document meta data
        document.info.title = "Reporte PDF"
        
        // Set spacing of header and footer
        document.layout.space.header = 5
        document.layout.space.footer = 5
        
        // Add custom pagination
        document.pagination = PDFPagination(container: .footerRight, style: PDFPaginationStyle.customClosure { (page, total) -> String in
            return "\(page) / \(total)"
            }, range: (1, 20), textAttributes: [
                .font: UIFont.boldSystemFont(ofSize: 15.0),
                .foregroundColor: UIColor.black
            ])
        
        // Add an image and scale it down. Image will not be drawn scaled, instead it will be scaled down and compressed to save file size.
        let logoImage = PDFImage(image: UIImage(named: "SexyLogo.png")!,
                                 caption: nil, size: CGSize(width: 400, height: 300),
                                 options: [.none])
        document.addImage(.contentCenter, image: logoImage)
        
        // Create and add an title as an attributed string for more customization possibilities
        let title = NSMutableAttributedString(string: "Reporte", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 50.0),
            .foregroundColor: UIColor(red: 0.171875, green: 0.2421875, blue: 0.3125, alpha: 1.0)
            ])
        document.addAttributedText(.contentCenter, text: title)
        
        // Add some spacing below title
        document.addSpace(space: 15.0)
        
        // Create a table
        
        let table = PDFTable()
        
        // Tables can contain Strings, Numbers, Images or nil, in case you need an empty cell. If you add a unknown content type, an error will be thrown and the rendering will stop.
        var tableData : [[Any?]] = [[Any]]()
        var aligmentsData : [[PDFTableCellAlignment]] = [[PDFTableCellAlignment]]()
        let titulo = [nil,"Nombre","Cantidad","Fecha"]
        let tituloAligment : [PDFTableCellAlignment] = [.center,.center,.center,.center]
        var index = 1

        tableData.append(titulo)
        aligmentsData.append(tituloAligment)

        for x in reporte!{
            var array : [Any?] = [Any]()
            var aligmentArray : [PDFTableCellAlignment] = [PDFTableCellAlignment]()
            let aligment : PDFTableCellAlignment = .center


            array.append(index)
            aligmentArray.append(aligment)
            array.append(x.nombre)
            aligmentArray.append(aligment)
            if x.cantidad == 0{
              array.append("N/A")
            }else{
             array.append(x.cantidad)
            }
            aligmentArray.append(aligment)
            array.append(formatter.string(from: x.fecha))
            aligmentArray.append(aligment)

            index = index + 1

            tableData.append(array)
            aligmentsData.append(aligmentArray)
        }
        
        do {
            try table.generateCells(
                data : tableData,
                alignments : aligmentsData
            )
        } catch PDFError.tableContentInvalid(let value) {
            // In case invalid input is provided, this error will be thrown.
            print("This type of object is not supported as table content: " + String(describing: (type(of: value))))
        } catch {
            // General error handling in case something goes wrong.
            print("Error while creating table: " + error.localizedDescription)
        }
        
        // The widths of each column is proportional to the total width, set by a value between 0.0 and 1.0, representing percentage.
        
        table.widths = [
            0.1, 0.25, 0.35, 0.3
        ]
        
        // To speed up table styling, use a default and change it
        let style = PDFTableStyleDefaults.simple
        // Simply set the amount of footer and header rows
        
        style.columnHeaderCount = 1
        style.footerCount = 1
        
        table.style = style
        
        
        // Set table padding and margin
        
        table.padding = 5.0
        table.margin = 10.0
        
        // In case of a linebreak during rendering we want to have table headers on each page.
        
        table.showHeadersOnEveryPage = true
        
        document.addTable(table: table)
        
        
        do {
            // Generate PDF file and save it in a temporary file. This returns the file URL to the temporary file
            let url = try PDFGenerator.generateURL(document: document, filename: "Example.pdf", progress: {
                (progressValue: CGFloat) in
                print("progress: ", progressValue)
            }, debug: false)
            
            // Load PDF into a webview from the temporary file
            webView.loadRequest(URLRequest(url: url))
        } catch {
            print("Error while generating PDF: " + error.localizedDescription)
        }
        
    }
 

}