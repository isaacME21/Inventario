//
//  DashboardVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 4/14/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class DashboardVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var tabla: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var almacen: UITextField!
    @IBOutlet weak var precioDeCompra: UITextField!
    @IBOutlet weak var precioDeVenta: UITextField!
    @IBOutlet weak var Existencias: UITextField!
    @IBOutlet weak var proovedor: UITextField!
    
    @IBOutlet weak var imagen: UIImageView!
    
    @IBOutlet weak var QRBarButton: UIBarButtonItem!
    
    let db = Firestore.firestore()
    let barCode = CodigosDeBarras()
    
    let picker = UIPickerView()
    
    //MARK: VARIABLES PARA UISERACHBAR
    var dataFiltered = [String]()
    var items = [String]()
    var isSearching = false
    var itemsInfo = [String : NSDictionary]()
    
    var almacenes = [String]()
    
    //MARK: REFRESH CONTROL
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(VizualizarArticulosVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.blue
        
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.returnKeyType = UIReturnKeyType.done
        picker.delegate = self
        almacen.inputView = picker
        
        self.tabla.addSubview(self.refreshControl)
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showConfig),
                                               name: NSNotification.Name("gotoConfiguracion"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showCatProd),
                                               name: NSNotification.Name("gotoCatProd"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showProovedores),
                                               name: NSNotification.Name("gotoProovedores"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showClientes),
                                               name: NSNotification.Name("gotoClientes"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showVisualizar),
                                               name: NSNotification.Name("gotoVisualizar"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showAlmacen),
                                               name: NSNotification.Name("gotoAlmacen"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showTraspaso),
                                               name: NSNotification.Name("gotoTraspaso"),
                                               object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global(qos: .background).async {
            //(self.items,self.itemInfo) = self.firebase.load(Collection: "Clientes")
            self.load(Collection: "Articulos")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if let itemScann = defaults.object(forKey: "itemScann") as? String {
            loadScann(item: itemScann)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        NotificationCenter.default.post(name: NSNotification.Name("HideSideMenu"), object: nil)
    }
    
    
    @IBAction func generateQRCode(_ sender: Any) {
        guard let imageQR = barCode.generateQRBarcode(from: nombre.text!) else {fatalError("No se encontro la imagen")}
        
        let image = imageQR
        let alert = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n", message: "", preferredStyle: .alert)
        
        let imgViewTitle = UIImageView(frame: CGRect(x: 8, y: 10, width: 250, height: 250))
        imgViewTitle.image = image
        
        alert.view.addSubview(imgViewTitle)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
    }
    
    
    
    //TODO: - HANDLE REFRESH
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        items.removeAll()
        itemsInfo.removeAll()
        self.load(Collection: "Articulos")
        refreshControl.endRefreshing()
    }
    
    //TODO: - TABLA DE ARTICULOS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return dataFiltered.count
        }
        
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        
        
        
        if isSearching{
            cell.textLabel?.text = dataFiltered[indexPath.row]
        }
        else {
            cell.textLabel?.text = items[indexPath.row]
        }
        
        
        return cell
    }
    
    //MOSTRAR INFORMACION AL TOCAR UNA CELDA
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        
        if let infoItem = itemsInfo[item] {
            let imageData = infoItem["Imagen"] as! Data
            imagen.image = UIImage(data: imageData)
            nombre.text = item
            proovedor.text = infoItem["Proovedores"] as? String
            precioDeVenta.text = infoItem["Precio de Venta"] as? String
            precioDeCompra.text = infoItem["Precio de Compra"] as? String
            
            
            if let itemImage = infoItem["Imagen"] {
                imagen.image = UIImage(data: itemImage as! Data)
            }
        }else{
            let alert = UIAlertController(title: "No existe la categoria", message: nil, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            
            self.present(alert, animated: true)
        }
        
        if almacen.text?.isEmpty == false{
            loadItemsFrom(almacen: almacen.text!, item: nombre.text!)
        }
        
    }
    
    //TODO: - BUSQUEDA DE CATEGORIAS
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tabla.reloadData()
        } else {
            isSearching = true
            dataFiltered = items.filter({$0.contains(searchBar.text!)})
            tabla.reloadData()
        }
    }
    
    
    
    
    // TODO: - UIPickerView Delegation
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return almacenes.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return almacenes[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        almacen.text = almacenes[row]
        loadItemsFrom(almacen: almacenes[row], item: nombre.text!)
    }
    
    @IBAction func salir(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //TODO: - Cargar informacion de Firebase
    func load(Collection: String) {
        let user = Auth.auth().currentUser!.email!
        items.removeAll()
        itemsInfo.removeAll()
        db.collection(user).document("Inventario").collection(Collection).getDocuments { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    self.items.append(document.documentID)
                    self.itemsInfo[document.documentID] = document.data() as NSDictionary
                }
                self.db.collection(user).document("Inventario").collection("Almacenes").getDocuments { (QuerySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in QuerySnapshot!.documents {
                            //print("\(document.documentID) => \(document.data())")
                            self.almacenes.append(document.documentID)
                        }
                    }
                    self.tabla.reloadData()
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    func loadItemsFrom(almacen : String, item : String) {
        let user = Auth.auth().currentUser!.email!
        db.collection(user).document("Inventario").collection("Almacenes").document(almacen).collection("Articulos").document(item).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                print("Document data: \(String(describing: dataDescription))")
                let existencias = dataDescription!["Cantidad"] as! Int
                DispatchQueue.main.async {
                    self.Existencias.text = "\(existencias)"
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func loadScann(item : String){
        let user = Auth.auth().currentUser!.email!
        db.collection(user).document("Inventario").collection("Articulos").document(item).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                print("Document data: \(String(describing: dataDescription))")
                let nombre = dataDescription!["Nombre"] as! String
                let precioCompra = dataDescription!["Precio de Compra"] as! String
                let precioVenta = dataDescription!["Precio de Venta"] as! String
                let proovedor = dataDescription!["Proovedores"] as! String
                DispatchQueue.main.async {
                    self.nombre.text = nombre
                    self.proovedor.text = proovedor
                    self.precioDeVenta.text = precioCompra
                    self.precioDeCompra.text = precioVenta
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    @objc func showConfig(){
        performSegue(withIdentifier: "gotoConfiguracion", sender: nil)
    }
    @objc func showCatProd(){
        performSegue(withIdentifier: "gotoCatProd", sender: nil)
    }
    @objc func showProovedores(){
        performSegue(withIdentifier: "gotoProovedores", sender: nil)
    }
    @objc func showClientes(){
        performSegue(withIdentifier: "gotoClientes", sender: nil)
    }
    @objc func showVisualizar(){
        performSegue(withIdentifier: "gotoVisualizar", sender: nil)
    }
    @objc func showAlmacen(){
        performSegue(withIdentifier: "gotoAlmacen", sender: nil)
    }
    @objc func showTraspaso(){
        performSegue(withIdentifier: "gotoTraspaso", sender: nil)
    }


}
