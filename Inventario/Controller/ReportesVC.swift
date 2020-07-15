//
//  ReportesVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 5/12/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import FSCalendar
import SVProgressHUD

class ReportesVC: UIViewController,FSCalendarDataSource, FSCalendarDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var opcionTextfield: UITextField!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tabla: UITableView!
    @IBOutlet weak var reportes: UITextField!
    @IBOutlet weak var almacenes: UITextField!
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")!
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter
    }()
    

    
    let picker : UIPickerView = UIPickerView()
    let almacenPicker : UIPickerView = UIPickerView()
    let opciones : [String] = ["Entre fechas", "Dia","Año"]
    var opcion : Int = 0
    var reporte : Int = 0
    var almacenOpcion : [String] = [String]()
    var itemArray : [CodigoItem] = [CodigoItem]()
    
    var reportesArray : [ReporteItem] = [ReporteItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //PickerView Opciones
        picker.delegate = self
        almacenPicker.delegate = self
        almacenes.delegate = self
        reportes.delegate = self
        reportes.inputView = picker
        almacenes.inputView = almacenPicker
        almacenes.isEnabled = false
        almacenes.isHidden = true
        
        tabla.register(UINib(nibName: "CustomViewCell", bundle: nil) , forCellReuseIdentifier: "cell")
        tabla.allowsMultipleSelection = true
        tabla.allowsSelectionDuringEditing = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global(qos: .background).async {
            self.load(Collection: "Almacenes")
        }
    }
    
    @IBAction func salir(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func generarReporte(_ sender: UIButton) {
        var fechasArray : [Date] = calendar.selectedDates
        var fechasSorted : [Date] = [Date]()
        
        
        fechasSorted = fechasArray.sorted(by: { $0 < $1 })
        fechasArray = fechasSorted

        
        for x in fechasSorted {print(formatter.string(from: x))}
        
        switch reporte {
        case 1:
            loadPedidos(Fechas: fechasSorted)
        case 2:
            loadArticulos(Fechas: fechasSorted)
        case 3:
            loadUsuarios(Fechas: fechasSorted)
        case 5:
            loadVentas(Fechas: fechasSorted)
        default:
            alertInput()
        }
        
    }
    
    @IBAction func crearPDF(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "gotoPDF", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! PDFVC
        destinationVC.reporte = reportesArray
        if reporte == 1 || reporte == 5{
            destinationVC.reportePedidos = 1
        }
        else if reporte == 4{
            destinationVC.codigo = itemArray
            destinationVC.reportePedidos = 2
        }
    }
    
    
    @IBAction func opciones(_ sender: UIBarButtonItem) {
        let alert : UIAlertController = UIAlertController(title: "Seleccione una Opcion", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor(red:0.82, green:0.64, blue:0.32, alpha:1.0)
        
        
        alert.addAction(UIAlertAction(title: "Pedidos", style: .default, handler: { _ in
            self.pedidos()
        }))
        alert.addAction(UIAlertAction(title: "Articulos", style: .default, handler: { _ in
            self.articulos()
        }))
        
//        alert.addAction(UIAlertAction(title: "Usuarios", style: .default, handler: { _ in
//            self.usuarios()
//        }))
        
        alert.addAction(UIAlertAction(title: "Codigo de Barras", style: .default, handler: { _ in
            self.codigoDeBarras()
        }))
        
        alert.addAction(UIAlertAction(title: "Ventas", style: .default, handler: { _ in
            self.ventas()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancelar", style: .cancel, handler: nil))
        
        
        guard let popoverController = alert.popoverPresentationController  else{ fatalError("Error en popoverController") }
        popoverController.barButtonItem = sender
        
        present(alert, animated: true, completion: nil)
    }
    
    //TODO: - FUNCIONES DEL MENU
    func pedidos()  {
        self.title = "Reporte de Peidos"
        almacenes.isEnabled = true
        almacenes.isHidden = false
        reporte = 1
    }
    
    func articulos()  {
        self.title = "Reporte de Articulos"
        almacenes.isEnabled = false
        almacenes.isHidden = true
        almacenes.text?.removeAll()
        reporte = 2
    }
    
    func usuarios()  {
        self.title = "Reporte de Usuarios"
        almacenes.isEnabled = false
        almacenes.isHidden = true
        almacenes.text?.removeAll()
        reporte = 3
    }
    
    func codigoDeBarras(){
        self.title = "Generar Codigo de Barras"
        loadArticulos(Collection: "Articulos")
        loadArticulos(Collection: "Zapatos")
        reporte = 4
    }
    
    func ventas(){
        self.title = "Reporte de Ventas"
        almacenes.isEnabled = false
        almacenes.isHidden = true
        almacenes.text?.removeAll()
        reporte = 5
    }
    
    
    // MARK: UIPickerView Delegation
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == picker{
           return opciones.count
        }else{
            return almacenOpcion.count
        }
        
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == picker{
            return opciones[row]
        }else{
            return almacenOpcion[row]
        }
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == picker{
            reportes.text = opciones[row]
            for x in calendar.selectedDates{calendar.deselect(x)}
            
            //MARK: CHECA LA OPCION Y EN BASE A ESO PERMITE SELECCIONAR UNA SOLA FECHA O 2 FECHAS AL MISMO TIEMPO
            if opciones[row] == "Dia"{
                opcion = 2
            }else if opciones[row] == "Año"{
                opcion = 3
            }else {
                opcion = 1
            }
        }else{
            almacenes.text = almacenOpcion[row]
        }
    }
    
    //TODO: TABLEVIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reporte != 4{
            return reportesArray.count
        }else{
            return itemArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if reporte == 4{
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell2" )
            cell.textLabel?.text = itemArray[indexPath.row].name!
            cell.accessoryType = itemArray[indexPath.row].selected ? .checkmark : .none
            return cell
        }else{
            let cell : CustomViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomViewCell
            cell.Articulo.text = reportesArray[indexPath.row].nombre
            cell.cantidadUpLabel.text = "Fecha"
            cell.Cantidad.text = formatter.string(from: reportesArray[indexPath.row].fecha)
            
            cell.Articulo.adjustsFontSizeToFitWidth = true
            cell.Cantidad.adjustsFontSizeToFitWidth = true
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if itemArray[indexPath.row].selected == true{
            itemArray[indexPath.row].selected = false
        }else{
            itemArray[indexPath.row].selected = true
        }
        tableView.reloadData()
    }
    
    
    //TODO: CALENDAR METHODS
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        //MARK: CHECA QUE OPCION SE SELECCIONO Y PERMITE SELECCIONAR UNA FECHA O 2 FECHAS SIMULTANEAMENTE
        switch opcion {
        case 1:
          if calendar.selectedDates.count > 2{calendar.deselect(calendar.selectedDates[0])}
        case 2:
            if calendar.selectedDates.count > 1{calendar.deselect(calendar.selectedDates[0])}
        case 3:
            if calendar.selectedDates.count > 1{calendar.deselect(calendar.selectedDates[0])}
        default:
            calendar.deselect(calendar.selectedDates[0])
        }
    
        //print("calendar did select date \(self.formatter.string(from: date))")
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    

    //TODO: LOAD PEDIDOS
    func loadPedidos(Fechas : [Date])  {
        reportesArray.removeAll()
        let reference : CollectionReference = db.collection("Pedidos En Espera")
        loadOpcion(reference: reference, Fechas: Fechas)
    }
    //TODO: LOAD ARTICULOS
    func loadArticulos(Fechas : [Date])  {
        reportesArray.removeAll()
        let reference : CollectionReference = db.collection("SexyRevolverData").document("Inventario").collection("Articulos")
        loadOpcion(reference: reference, Fechas: Fechas)
        let reference2 : CollectionReference = db.collection("SexyRevolverData").document("Inventario").collection("Zapatos")
        loadOpcion(reference: reference2, Fechas: Fechas)
    }
    //TODO: LOAD USUARIOS
    func loadUsuarios(Fechas : [Date])  {
        reportesArray.removeAll()
        let reference : CollectionReference = db.collection("Users")
        loadOpcion(reference: reference, Fechas: Fechas)
    }
    func loadVentas(Fechas : [Date]) {
        reportesArray.removeAll()
        let reference : CollectionReference = db.collection("Compras")
        loadOpcion(reference: reference, Fechas: Fechas)
    }
    
    
    //TODO: FUNCION PARA CARGAR LAS OPCIONES
    func loadOpcion(reference : CollectionReference , Fechas : [Date])  {
        
        if opcion == 1{
            if reporte == 5 {
                print("Entro en la opcion correcta")
                let startOfDate = Fechas[0].startOfDay
                let endOfDate = Fechas[1].endOfDay
                reference
                    .whereField("Fehca", isGreaterThanOrEqualTo: startOfDate)
                    .whereField("Fehca", isLessThanOrEqualTo: endOfDate)
                    .getDocuments{ (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID)")
                                let data = document.data()
                                let fecha = data["Fehca"] as! Timestamp
                                let item : ReporteItem = ReporteItem()
                                item.nombre = document.documentID
                                item.fecha = fecha.dateValue()
                                item.almacen = ""
                                
                                if let cantidadArray = data["ItemsCantidad"] as? NSMutableArray{
                                    var cantidadTemp : [Int] = [Int]()
                                    for x in cantidadArray{cantidadTemp.append(x as! Int)}
                                    item.cantidad = cantidadTemp
                                }
                                
                                if let articulosArray = data["ItemsNombre"] as? NSMutableArray{
                                    var articulosTemp : [String] = [String]()
                                    for x in articulosArray{articulosTemp.append(x as! String)}
                                    item.articulos = articulosTemp
                                }
                                
                                
                                
                                self.reportesArray.append(item)
                            }
                            self.tabla.reloadData()
                        }
                }
            }else{
                let startOfDate = Fechas[0].startOfDay
                let endOfDate = Fechas[1].endOfDay
                reference
                    .whereField("Fecha", isGreaterThanOrEqualTo: startOfDate)
                    .whereField("Fecha", isLessThanOrEqualTo: endOfDate)
                    .getDocuments{ (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID)")
                                let data = document.data()
                                let fecha = data["Fecha"] as! Timestamp
                                let item : ReporteItem = ReporteItem()
                                item.nombre = document.documentID
                                item.fecha = fecha.dateValue()
                                
                                if let cantidadArray = data["Articulos"] as? NSMutableArray{
                                    var cantidadTemp : [Int] = [Int]()
                                    for x in cantidadArray{cantidadTemp.append(x as! Int)}
                                    
                                    item.cantidad = cantidadTemp
                                }
                                
                                if let articulosArray = data["ArticuloOrden"] as? NSMutableArray{
                                    var articulosTemp : [String] = [String]()
                                    for x in articulosArray{articulosTemp.append(x as! String)}
                                    
                                    item.articulos = articulosTemp
                                }
                                
                                if let almacenDestino = data["Almacen 2"] as? String{
                                    item.almacen = almacenDestino
                                }
                                
                                self.reportesArray.append(item)
                            }
                            if self.almacenes.text?.isEmpty == false{
                                var array : [ReporteItem] = [ReporteItem]()
                                for x in self.reportesArray{
                                    if x.almacen == self.almacenes.text{
                                        array.append(x)
                                    }
                                }
                                self.reportesArray = array
                            }
                            self.tabla.reloadData()
                        }
                }
            }
            
            
        }else if opcion == 2{
            if reporte == 5{
                print("Entro en la opcion correcta")
                let startOfDate = Fechas[0].startOfDay
                let endOfDate = Fechas[0].endOfDay
                reference
                    .whereField("Fehca", isGreaterThanOrEqualTo: startOfDate)
                    .whereField("Fehca", isLessThanOrEqualTo: endOfDate)
                    .getDocuments{ (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID)")
                                let data = document.data()
                                let fecha = data["Fehca"] as! Timestamp
                                let item : ReporteItem = ReporteItem()
                                item.nombre = document.documentID
                                item.fecha = fecha.dateValue()
                                item.almacen = ""
                                
                                if let cantidadArray = data["ItemsCantidad"] as? NSMutableArray{
                                    var cantidadTemp : [Int] = [Int]()
                                    for x in cantidadArray{cantidadTemp.append(x as! Int)}
                                    item.cantidad = cantidadTemp
                                }
                                
                                if let articulosArray = data["ItemsNombre"] as? NSMutableArray{
                                    var articulosTemp : [String] = [String]()
                                    for x in articulosArray{articulosTemp.append(x as! String)}
                                    item.articulos = articulosTemp
                                }
                                
                                
                                
                                self.reportesArray.append(item)
                            }
                            self.tabla.reloadData()
                        }
                }
            }else{
                let startOfDate = Fechas[0].startOfDay
                let endOfDate = Fechas[0].endOfDay
                reference
                    .whereField("Fecha", isGreaterThanOrEqualTo: startOfDate)
                    .whereField("Fecha", isLessThanOrEqualTo: endOfDate)
                    .getDocuments{ (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID)")
                                let data = document.data()
                                let fecha = data["Fecha"] as! Timestamp
                                let item : ReporteItem = ReporteItem()
                                item.nombre = document.documentID
                                item.fecha = fecha.dateValue()
                                
                                if let cantidadArray = data["Articulos"] as? NSMutableArray{
                                    var cantidadTemp : [Int] = [Int]()
                                    for x in cantidadArray{cantidadTemp.append(x as! Int)}
                                    
                                    item.cantidad = cantidadTemp
                                }
                                
                                if let articulosArray = data["ArticuloOrden"] as? NSMutableArray{
                                    var articulosTemp : [String] = [String]()
                                    for x in articulosArray{articulosTemp.append(x as! String)}
                                    
                                    item.articulos = articulosTemp
                                }
                                
                                if let almacenDestino = data["Almacen 2"] as? String{
                                    item.almacen = almacenDestino
                                }
                                
                                self.reportesArray.append(item)
                            }
                            if self.almacenes.text?.isEmpty == false{
                                var array : [ReporteItem] = [ReporteItem]()
                                for x in self.reportesArray{
                                    if x.almacen == self.almacenes.text{
                                        array.append(x)
                                    }
                                }
                                self.reportesArray = array
                            }
                            self.tabla.reloadData()
                        }
                }
            }
            
        }else{
            if reporte == 5 {
                print("Entro en la opcion correcta")
                reference
                    .whereField("Fehca", isLessThanOrEqualTo: Fechas[0])
                    .getDocuments{ (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID)")
                                let data = document.data()
                                let fecha = data["Fehca"] as! Timestamp
                                let item : ReporteItem = ReporteItem()
                                item.nombre = document.documentID
                                item.fecha = fecha.dateValue()
                                item.almacen = ""
                                
                                if let cantidadArray = data["ItemsCantidad"] as? NSMutableArray{
                                    var cantidadTemp : [Int] = [Int]()
                                    for x in cantidadArray{cantidadTemp.append(x as! Int)}
                                    item.cantidad = cantidadTemp
                                }
                                
                                if let articulosArray = data["ItemsNombre"] as? NSMutableArray{
                                    var articulosTemp : [String] = [String]()
                                    for x in articulosArray{articulosTemp.append(x as! String)}
                                    item.articulos = articulosTemp
                                }
                                
                                
                                
                                self.reportesArray.append(item)
                            }
                            self.tabla.reloadData()
                        }
                }
            }else{
                reference.whereField("Fecha", isLessThanOrEqualTo: Fechas[0])
                    .getDocuments{ (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                print("\(document.documentID)")
                                let data = document.data()
                                let fecha = data["Fecha"] as! Timestamp
                                let item : ReporteItem = ReporteItem()
                                item.nombre = document.documentID
                                item.fecha = fecha.dateValue()
                                
                                if let cantidadArray = data["Articulos"] as? NSMutableArray{
                                    var cantidadTemp : [Int] = [Int]()
                                    for x in cantidadArray{cantidadTemp.append(x as! Int)}
                                    
                                    item.cantidad = cantidadTemp
                                }
                                
                                if let articulosArray = data["ArticuloOrden"] as? NSMutableArray{
                                    var articulosTemp : [String] = [String]()
                                    for x in articulosArray{articulosTemp.append(x as! String)}
                                    
                                    item.articulos = articulosTemp
                                }
                                
                                if let almacenDestino = data["Almacen 2"] as? String{
                                    item.almacen = almacenDestino
                                }
                                
                                self.reportesArray.append(item)
                            }
                            if self.almacenes.text?.isEmpty == false{
                                var array : [ReporteItem] = [ReporteItem]()
                                for x in self.reportesArray{
                                    if x.almacen == self.almacenes.text{
                                        array.append(x)
                                    }
                                }
                                self.reportesArray = array
                            }
                            self.tabla.reloadData()
                        }
                }
            }
        }
    }
    
    
    //TODO: - Cargar informacion de Firebase
    func load(Collection: String) {
        db.collection("SexyRevolverData").document("Inventario").collection(Collection).getDocuments { (QuerySnapshot, err) in
            if let err : Error = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    self.almacenOpcion.append(document.documentID)
                }
                SVProgressHUD.dismiss()
                self.tabla.reloadData()
            }
        }
    }
    
    func loadArticulos(Collection: String) {
        db.collection("SexyRevolverData").document("Inventario").collection(Collection).getDocuments { (QuerySnapshot, err) in
            if let err : Error = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                        let newItem = CodigoItem()
                        newItem.name = document.documentID
                        self.itemArray.append(newItem)
                }
                SVProgressHUD.dismiss()
                self.tabla.reloadData()
            }
        }
    }
    
}
