//
//  GestionInventarioVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 1/8/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import Parse


class GestionInventarioVC: UIViewController,UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UISearchBarDelegate, UITextFieldDelegate {
    
    
    class articulo {
        var nombre : String
        var cantidad : Int = 1
        
        init(nombre : String) {
            self.nombre = nombre
        }
    }

    
    @IBOutlet weak var tabla: UITableView!
    @IBOutlet weak var tabla2: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    

    @IBOutlet weak var almacen: UITextField!
    @IBOutlet weak var almacen2: UITextField!
    @IBOutlet weak var numArticulo: UITextField!
    
  
    @IBOutlet weak var almacenConstraint: NSLayoutConstraint!
    @IBOutlet weak var almacenConstrain2: NSLayoutConstraint!
    
    
    
    
    
    var index = 0
    var index2 = 0
    var opcion = 1
    
    
    let db = Firestore.firestore()
    let picker = UIPickerView()
    
    //TODO: - VARIABLES PARA UISERACHBAR
    var dataFiltered = [String]()
    var isSearching = false
    var dataFiltered2 = [String]()
    var isSearching2 = false
    
    //MARK: VARIABLES PARA ALMACENAR INFORMACION
    var Almacenes = [String]()
    var AlmacenesInfo = [String : NSDictionary]()
    var Articulos = [String]()
    var Articulos2 = [articulo]()
    var Articulos3 = [articulo]()
    
    //MARK: REFRESH CONTROL
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(GestionInventarioVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.blue
        
        return refreshControl
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.returnKeyType = UIReturnKeyType.done
        
        //PickerView Categorias
        picker.delegate = self
        almacen.inputView = picker
        almacen2.inputView = picker
        
        
        self.tabla.addSubview(self.refreshControl)
        tabla.register(UINib(nibName: "CustomViewCell", bundle: nil) , forCellReuseIdentifier: "cell")
        tabla2.register(UINib(nibName: "CustomViewCell", bundle: nil) , forCellReuseIdentifier: "cell2")
        
        
        tabla2.rowHeight = UITableView.automaticDimension
        tabla2.estimatedRowHeight = 150.0
        
        almacenConstrain2.constant = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global(qos: .background).async {
            self.loadAlmacenes()
            self.loadArticulos()
        }
        
    }
    
    //TODO: - HANDLE REFRESH
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        Articulos.removeAll()
        self.loadArticulos()
        refreshControl.endRefreshing()
    }
    
    
    //TODO: - TABLA DE ARTICULOS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //MARK: ENTRADA
        if opcion == 1{
            if tableView == tabla{
                if isSearching { return dataFiltered.count }
                return Articulos.count
            }
            
            if tableView == tabla2 {
                return Articulos2.count
            }
        }
        //MARK: SALIDA
        if opcion == 2{
            if tableView == tabla{
                return Articulos3.count
            }
            
            if tableView == tabla2 {
                return Articulos2.count
            }
        }
        
        //MARK: TRASPASO
        if opcion == 3{
            if tableView == tabla{
                return Articulos3.count
            }
            
            if tableView == tabla2 {
                return Articulos2.count
            }
        }
        
        
        return 1
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //MARK: ENTRADA
        if opcion == 1{
            if tableView == tabla{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomViewCell
                
                if isSearching{
                    cell.Articulo.text = dataFiltered[indexPath.row]
                    cell.Cantidad.text = " "
                }else {
                    cell.Articulo.text = Articulos[indexPath.row]
                    cell.Cantidad.text = " "
                }
                return cell
            }
            
            
            if tableView == tabla2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! CustomViewCell
                
                cell.Articulo.text = Articulos2[indexPath.row].nombre
                cell.Cantidad.text = String(Articulos2[indexPath.row].cantidad)
                return cell
            }
        }
        //MARK: SALIDA
        if opcion == 2{
            if tableView == tabla{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomViewCell
                
                cell.Articulo.text = Articulos3[indexPath.row].nombre
                cell.Cantidad.text = String(Articulos3[indexPath.row].cantidad)
                return cell
            }
            
            
            if tableView == tabla2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! CustomViewCell
                
                cell.Articulo.text = Articulos2[indexPath.row].nombre
                cell.Cantidad.text = String(Articulos2[indexPath.row].cantidad)
                return cell
            }
            
        }
        //MARK: TRASPASO
        if opcion == 3{
            if tableView == tabla{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomViewCell
                
                cell.Articulo.text = Articulos3[indexPath.row].nombre
                cell.Cantidad.text = String(Articulos3[indexPath.row].cantidad)
                return cell
            }
            
            
            if tableView == tabla2{
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! CustomViewCell
                
                cell.Articulo.text = Articulos2[indexPath.row].nombre
                cell.Cantidad.text = String(Articulos2[indexPath.row].cantidad)
                return cell
            }
        }
        
        
        
        
        return UITableViewCell()
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        index2 = indexPath.row
        
        if opcion == 1{
            var bandera = 0
            
            if tableView == tabla{
                
                for articulo in Articulos2{
                    if articulo.nombre == Articulos[indexPath.row]{
                        bandera = 1
                        numArticulo.text = "\(articulo.cantidad)"
                    }
                }
                
                if bandera == 0 {
                    let enviarArticulo = articulo(nombre: Articulos[indexPath.row])
                    Articulos2.append(enviarArticulo)
                    numArticulo.text = "\(enviarArticulo.cantidad)"
                    
                }
            }
            
            for (num,object) in Articulos2.enumerated(){
                if object.nombre == Articulos[indexPath.row]{
                    index = num
                }
            }
            
            tabla2.reloadData()
        }
        
        
        
        
        if opcion != 1{
            var bandera = 0
            
            if tableView == tabla{
                
                for articulo in Articulos2{
                    if articulo.nombre == Articulos3[indexPath.row].nombre{
                        bandera = 1
                        numArticulo.text = "\(articulo.cantidad)"
                    }
                }
                
                if bandera == 0 {
                    let enviarArticulo = articulo(nombre: Articulos[indexPath.row])
                    Articulos2.append(enviarArticulo)
                    Articulos3[index2].cantidad = Articulos3[index2].cantidad - 1
                    numArticulo.text = "\(enviarArticulo.cantidad)"
                    
                }
            }
            
            for (num,object) in Articulos2.enumerated(){
                if object.nombre == Articulos3[indexPath.row].nombre{
                    index = num
                }
            }
            
            tabla2.reloadData()
            tabla.reloadData()
        }
        
        
        
    
    }
    //TODO: - BUSQUEDA DE ARTICULOS
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if opcion == 1{
            if searchBar.text == nil || searchBar.text == "" {
                isSearching = false
                view.endEditing(true)
                tabla.reloadData()
            } else {
                isSearching = true
                dataFiltered = Articulos.filter({$0.contains(searchBar.text!)})
                tabla.reloadData()
            }
        }
        
    }
    
    // MARK: UIPickerView Delegation
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Almacenes.count
    }
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Almacenes[row]
    }
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if almacen.isEditing == true {
            almacen.text = Almacenes[row]
            if opcion != 1{ loadOption2(Almacen: almacen.text!) }
        }
        
        if almacen2.isEditing == true {
            almacen2.text = Almacenes[row]
        }
        
        
    }
    
    
    @IBAction func mas(_ sender: UIButton) {
        print(index)
        if numArticulo.text != "" {
            print("Entro a la funcion")
            
            
            if opcion == 1{
                var cantidad = Int(numArticulo.text!)
                cantidad = cantidad! + 1
                Articulos2[index].cantidad = cantidad!
                numArticulo.text = "\(cantidad!)"
                tabla2.reloadData()
            }else{
                var cantidad = Int(numArticulo.text!)
                let cantidad2  = Articulos3[index2].cantidad - 1
                
                if cantidad2 >= 0 {
                    cantidad = cantidad! + 1
                    Articulos2[index].cantidad = cantidad!
                    Articulos3[index2].cantidad = cantidad2
                    numArticulo.text = "\(cantidad!)"
                    tabla2.reloadData()
                    tabla.reloadData()
                }
            }
        }
    }
    @IBAction func menos(_ sender: UIButton) {
        print(index)
        if numArticulo.text != "" {
            print("Entro a la funcion")
            
            if opcion == 1 {
                var cantidad = Int(numArticulo.text!)
                cantidad = cantidad! - 1
                if cantidad! >= 0 {
                    Articulos2[index].cantidad = cantidad!
                    numArticulo.text = "\(cantidad!)"
                    tabla2.reloadData()
                }else{
                    cantidad = 0
                }
                
            }else{
                var cantidad = Int(numArticulo.text!)
                cantidad = cantidad! - 1
                if cantidad! >= 0 {
                    Articulos2[index].cantidad = cantidad!
                    Articulos3[index2].cantidad = Articulos3[index2].cantidad + 1
                    numArticulo.text = "\(cantidad!)"
                    tabla2.reloadData()
                    tabla.reloadData()
                }else{
                    cantidad = 0
                }
            }
            
            
            
            
        }
        
    }
    @IBAction func opciones(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Escoge una Opcion", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor(red:0.82, green:0.64, blue:0.32, alpha:1.0)
        
        
        alert.addAction(UIAlertAction(title: "Entrada", style: .default, handler: { _ in
            self.entrada()
        }))
        alert.addAction(UIAlertAction(title: "Salida", style: .default, handler: { _ in
            self.salida()
        }))
        
        alert.addAction(UIAlertAction(title: "Traspaso", style: .default, handler: { _ in
            self.traspaso()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancelar", style: .cancel, handler: nil))
        
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        
        
        present(alert, animated: true, completion: nil)
        
        
        
        
    }
    @IBAction func salir(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func Enviar(_ sender: UIButton) {
        
            if Articulos2.isEmpty == false {
                let x = almacen.text!
                let y = almacen2.text!
                
                if opcion == 1{
                    SVProgressHUD.show(withStatus: "Cargando")
                    DispatchQueue.global(qos: .background).async {
                        self.save(Almacen: x)
                    }
                }else if opcion == 2{
                    SVProgressHUD.show(withStatus: "Cargando")
                    DispatchQueue.global(qos: .background).async {
                        self.saveOption2(Almacen: x)
                }
                }else{
                    SVProgressHUD.show(withStatus: "Cargando")
                    DispatchQueue.global(qos: .background).async {
                        self.saveOption3(Almacen1: x, Almacen2: y)
                }
            }
        }

    }
    
    //TODO: - FUNCIONES DEL MENU
    func entrada()  {
        //navBar.title = "Entrada"
        almacenConstrain2.constant = 0
        opcion = 1
        Articulos2.removeAll()
        tabla2.reloadData()
        loadArticulos()
    }
    
    func salida()  {
        //navBar.title = "Salida"
        almacenConstrain2.constant = 0
        opcion = 2
        Articulos2.removeAll()
        tabla2.reloadData()
        almacen.text = Almacenes.first
        if almacen.text?.isEmpty == false {
            loadOption2(Almacen: almacen.text!)
        }
    }
    
    func traspaso()  {
        //navBar.title = "Traspaso"
        almacenConstrain2.constant = 320
        opcion = 3
        Articulos2.removeAll()
        tabla2.reloadData()
        almacen.text = Almacenes.first
        if almacen.text?.isEmpty == false {
            loadOption2(Almacen: almacen.text!)
        }
    }
    

    //TODO: - Cargar informacion de Firebase
    func loadAlmacenes() {
        db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Almacenes").getDocuments { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    self.Almacenes.append(document.documentID)
                    self.AlmacenesInfo[document.documentID] = document.data() as NSDictionary
                }
                self.tabla.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func loadArticulos() {
        db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Articulos").getDocuments { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.Articulos.removeAll()
                for document in QuerySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    self.Articulos.append(document.documentID)
                }
                self.tabla.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func loadOption2(Almacen : String)  {
            db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Almacenes").document(Almacen).collection("Articulos").getDocuments { (QuerySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.Articulos3.removeAll()
                    for document in QuerySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let data = document.data()
                        let newArticulo = articulo(nombre: document.documentID)
                        newArticulo.cantidad = data["Cantidad"] as! Int
                        self.Articulos3.append(newArticulo)
                }
                    self.tabla.reloadData()
            }
        }
    }
    
    func save(Almacen: String)  {
        
        var articulos = [String:Int]()
        
            
        db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Almacenes").document(Almacen).collection("Articulos").getDocuments { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    self.Articulos.append(document.documentID)
                    
                    let cantidad = data["Cantidad"] as! Int
                    articulos[document.documentID] = cantidad
                }
                
                
                for item in self.Articulos2{
                    self.db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Almacenes").document(Almacen).collection("Articulos").document(item.nombre).setData([
                        "Cantidad":  articulos[item.nombre] == nil ? item.cantidad  : (item.cantidad + articulos[item.nombre]!)
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                }
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func saveOption2(Almacen: String) {
        
        for item in Articulos3{
            //MARK: BORRAR EL DOCUMENTO SI EL ARTICULO ESTA EN 0
            if item.cantidad == 0{
                db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Almacenes").document(Almacen).collection("Articulos").document(item.nombre).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
            }else{
                //MARK: ACTUALIZAR LOS DOCUMENTOS
                db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Almacenes").document(Almacen).collection("Articulos").document(item.nombre).setData([
                    "Cantidad":  item.cantidad
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
            }
        }
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            self.loadOption2(Almacen: self.almacen.text!)
            self.Articulos2.removeAll()
            self.tabla.reloadData()
            self.tabla2.reloadData()
        }
    }
    
    
    func saveOption3(Almacen1 : String, Almacen2 : String)  {
        
        var articulos = [String:Int]()
        
        
        db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Almacenes").document(Almacen2).collection("Articulos").getDocuments { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    self.Articulos.append(document.documentID)
                    
                    let cantidad = data["Cantidad"] as! Int
                    articulos[document.documentID] = cantidad
                }
                
                
                for item in self.Articulos2{
                    self.db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Almacenes").document(Almacen2).collection("Articulos").document(item.nombre).setData([
                        "Cantidad":  articulos[item.nombre] == nil ? item.cantidad  : (item.cantidad + articulos[item.nombre]!)
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                }
                for item in self.Articulos3{
                    //MARK: BORRAR EL DOCUMENTO SI EL ARTICULO ESTA EN 0
                    if item.cantidad == 0{
                        self.db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Almacenes").document(Almacen1).collection("Articulos").document(item.nombre).delete() { err in
                            if let err = err {
                                print("Error removing document: \(err)")
                            } else {
                                print("Document successfully removed!")
                            }
                        }
                    }else{
                        //MARK: ACTUALIZAR LOS DOCUMENTOS
                        self.db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Almacenes").document(Almacen1).collection("Articulos").document(item.nombre).setData([
                            "Cantidad":  item.cantidad
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.loadOption2(Almacen: self.almacen.text!)
                    self.Articulos2.removeAll()
                    self.tabla.reloadData()
                    self.tabla2.reloadData()
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    

}
