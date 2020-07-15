 //
//  PDFVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 5/17/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit
import TPPDF
import WebKit
import SVProgressHUD
import MessageUI
import Firebase

class PDFVC: UIViewController, WKNavigationDelegate, MFMailComposeViewControllerDelegate {
    
    var webView : WKWebView!
    var reportePedidos : Int = 0
    var PDF : URL?
    var barcode : CodigosDeBarras = CodigosDeBarras()
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    var reporte : [ReporteItem]?{
        didSet{
            print("Se arma")
        }
    }
    
    var codigo : [CodigoItem]?{
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
        if reportePedidos == 0{
            GeneratePDF()
        }else if reportePedidos == 1{
            GeneratePedidos()
        }else if reportePedidos == 2{
            generarCodigos()
        }
        
    }
    
    @IBAction func sendMail(_ sender: UIBarButtonItem) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([Auth.auth().currentUser!.email!])
            mail.setMessageBody("<p>Reporte generado desde la app</p>", isHTML: true)
            guard let reportePDF = PDF else {fatalError("Error al tratar de enviar el pdf")}
            var pdfData : Data?
            do{
               pdfData = try Data(contentsOf: reportePDF)
            }catch{ print(error) }
            mail.addAttachmentData(pdfData!, mimeType: "application/pdf", fileName: "Reporte")
            present(mail, animated: true)
        } else {
            showMailError()
        }
    }
    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "No se pudo enviar el correo", message: "Tu dispositivo no esta configurado para enviar correos", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
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
        guard let imageTemp = barcode.generadorDeCodigosDeBarra(Referencia: "Hola", op: 3) else {fatalError("Barcode Error")}
        let logoImage = PDFImage(image: UIImage(named: "SexyLogo")!,
                                 caption: nil, size: CGSize(width: 100, height: 100),
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
            if x.cantidad == nil{
              array.append("N/A")
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
            0.1, 0.35, 0.25, 0.3
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
                SVProgressHUD.showProgress(Float(progressValue))
                print("progress: ", progressValue)
                if Float(progressValue) == 1 {
                    SVProgressHUD.dismiss()
                }
            }, debug: false)
            
            // Load PDF into a webview from the temporary file
            PDF = url
            webView.load(URLRequest(url: url))
        } catch {
            print("Error while generating PDF: " + error.localizedDescription)
        }
        
    }
 
    
    func GeneratePedidos(){
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
        guard let imageTemp = barcode.generadorDeCodigosDeBarra(Referencia: "Hola", op: 3) else {fatalError("Barcode Error")}
        let logoImage = PDFImage(image: UIImage(named: "SexyLogo")!,
                                 caption: nil, size: CGSize(width: 100, height: 100),
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
        
        // Create a tables
        for x in reporte!{
            let title = NSMutableAttributedString(string: x.nombre + "  " + x.almacen! , attributes: [
                .font: UIFont.boldSystemFont(ofSize: 18.0),
                .foregroundColor: UIColor(red: 0.171875, green: 0.2421875, blue: 0.3125, alpha: 1.0)
                ])
                document.addAttributedText(.contentCenter, text: title)
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
            
            for articulos in x.articulos!{
                var array : [Any?] = [Any]()
                var aligmentArray : [PDFTableCellAlignment] = [PDFTableCellAlignment]()
                let aligment : PDFTableCellAlignment = .center
                
                array.append(index)
                aligmentArray.append(aligment)
                array.append(articulos)
                aligmentArray.append(aligment)
                let indexTemp = x.articulos!.firstIndex(of: articulos)
                array.append(x.cantidad![indexTemp!])
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
            table.widths = [0.1, 0.35, 0.25, 0.3]
            
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
            document.addSpace(space: 15.0)
        }
        do {
            // Generate PDF file and save it in a temporary file. This returns the file URL to the temporary file
            let url = try PDFGenerator.generateURL(document: document, filename: "Example.pdf", progress: {
                (progressValue: CGFloat) in
                SVProgressHUD.showProgress(Float(progressValue))
                print("progress: ", progressValue)
                if Float(progressValue) == 1 {
                    SVProgressHUD.dismiss()
                }
            }, debug: false)
            
            // Load PDF into a webview from the temporary file
            PDF = url
            webView.load(URLRequest(url: url))
        } catch {
            print("Error while generating PDF: " + error.localizedDescription)
        }
        
    }
    
    
    func generarCodigos(){
        
        let document = PDFDocument(format: .a4)
        var imagenes : [PDFImage] = []
        
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
        for x in codigo!{
            if x.selected == true{
                guard let imageTemp = barcode.generadorDeCodigosDeBarra(Referencia: x.name!, op: 3) else {fatalError("Barcode Error")}
                let newImage = PDFImage(image: imageTemp,
                                        caption: nil, size: CGSize(width: 100, height: 100),
                                        options: [.none])
                imagenes.append(newImage)
            }
        }
        
        let logoImage = PDFImage(image: UIImage(named: "SexyLogo")!,
                                 caption: nil, size: CGSize(width: 100, height: 100),
                                 options: [.none])
        document.addImage(.contentCenter, image: logoImage)
        document.addImagesInRow(images: imagenes)
        
        
        
        do {
            // Generate PDF file and save it in a temporary file. This returns the file URL to the temporary file
            let url = try PDFGenerator.generateURL(document: document, filename: "Example.pdf", progress: {
                (progressValue: CGFloat) in
                SVProgressHUD.showProgress(Float(progressValue))
                print("progress: ", progressValue)
                if Float(progressValue) == 1 {
                    SVProgressHUD.dismiss()
                }
            }, debug: false)
            
            // Load PDF into a webview from the temporary file
            PDF = url
            webView.load(URLRequest(url: url))
        } catch {
            print("Error while generating PDF: " + error.localizedDescription)
        }
        
    }
    

}
