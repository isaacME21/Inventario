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
    
    let db : Firestore = Firestore.firestore()
    let barCode : CodigosDeBarras = CodigosDeBarras()
    
    let picker : UIPickerView = UIPickerView()
    
    //MARK: VARIABLES PARA UISERACHBAR
    var dataFiltered : [String] = [String]()
    var items : [String] = [String]()
    var isSearching : Bool = false
    var itemsInfo : [item] = [item]()
    
    var almacenes : [String] = [String]()
    
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showReportes),
                                               name: NSNotification.Name("gotoReportes"),
                                               object: nil)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global(qos: .background).async {
            self.load(Collection: "Articulos")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //let defaults = UserDefaults.standard
        //guard let itemScann : String = defaults.object(forKey: "itemScann") as? String else {fatalError("error en itemScann")}
        //loadScann(item: itemScann)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("gotoConfiguracion"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("gotoCatProd"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("gotoProovedores"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("gotoClientes"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("gotoVisualizar"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("gotoAlmacen"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("gotoTraspaso"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("HideSideMenu"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ToggleSideMenu"), object: nil)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        NotificationCenter.default.post(name: NSNotification.Name("HideSideMenu"), object: nil)
    }
    
    
    @IBAction func generateQRCode(_ sender: Any) {
        guard let imageQR : UIImage = barCode.generateQRBarcode(from: nombre.text!) else {fatalError("No se encontro la imagen")}
        
        let image : UIImage = imageQR
        let alert : UIAlertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n", message: "", preferredStyle: .alert)
        
        let imgViewTitle : UIImageView = UIImageView(frame: CGRect(x: 8, y: 10, width: 250, height: 250))
        imgViewTitle.image  = image
        
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
        
        let cell : UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        
        
        
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
        var art : item?
        for x in itemsInfo{if x.name == items[indexPath.row]{ art = x}}
        
        if art != nil {
            if let itemImage : UIImage = art?.imagen{
                imagen.image = itemImage
            }else{
                imagen.image = UIImage(named: "MarcoFotoBlack")
            }
            nombre.text = art!.name
            precioDeCompra.text = art?.precioDeCompra ?? ""
            precioDeVenta.text = art?.precioDeVenta ?? ""
            proovedor.text = art?.proovedores ?? ""
        }else{
            let alert : UIAlertController  = UIAlertController(title: "No existe la categoria", message: nil, preferredStyle: .alert)
            let OKAction : UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
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
        if nombre.text != ""{
            almacen.text = almacenes[row]
            loadItemsFrom(almacen: almacenes[row], item: nombre.text!)
        }else{ alertInput() }
        
    }
    
    @IBAction func salir(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
    @objc func showReportes(){
        performSegue(withIdentifier: "gotoReportes", sender: nil)
    }
    
    //TODO: - Cargar informacion de Firebase
    func load(Collection: String) {
        items.removeAll()
        itemsInfo.removeAll()
        db.collection("SexyRevolverData").document("Inventario").collection(Collection).getDocuments { (QuerySnapshot, err) in
            if let err : Error = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    self.items.append(document.documentID)
                    let infoItem : [String : Any] = document.data()
                    let itemObj : item = item()
                    itemObj.name = infoItem["Nombre"] as! String
                    itemObj.precioDeCompra = infoItem["Precio de Compra"] as? String
                    itemObj.precioDeVenta = infoItem["Precio de Venta"] as? String
                    itemObj.proovedores = infoItem["Proovedores"] as? String

                    
                    let storageReference : StorageReference = Storage.storage().reference()
                    let profileImageRef : StorageReference = storageReference.child("Articulos").child(document.documentID)
                    // Fetch the download URL
                    profileImageRef.downloadURL { url, error in
                        if let error : Error = error {
                            // Handle any errors
                            print("Error took place \(error.localizedDescription)")
                        } else {
                            // Get the download URL for 'images/stars.jpg'
                            print("Profile image download URL \(String(describing: url!))")
                            do {
                                let imageData : NSData = try NSData(contentsOf: url!)
                                itemObj.imagen = UIImage(data: imageData as Data)
                                print("Se bajo la foto")
                                SVProgressHUD.dismiss()
                            } catch {
                                print(error)
                            }
                        }
                        self.itemsInfo.append(itemObj)
                    }
                    
                }
                self.db.collection("SexyRevolverData").document("Inventario").collection("Almacenes").getDocuments { (QuerySnapshot, err) in
                    if let err : Error = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in QuerySnapshot!.documents {
                            //print("\(document.documentID) => \(document.data())")
                            self.almacenes.append(document.documentID)
                        }
                    }
                    self.tabla.reloadData()
                }
            }
        }
    }
    
    func loadItemsFrom(almacen : String, item : String) {
        db.collection("SexyRevolverData").document("Inventario").collection("Almacenes").document(almacen).collection("Articulos").document(item).getDocument { (document, error) in
            if let document : DocumentSnapshot = document, document.exists {
                let dataDescription : [String : Any]? = document.data()
                print("Document data: \(String(describing: dataDescription))")
                let existencias : Int = dataDescription!["Cantidad"] as! Int
                DispatchQueue.main.async {
                    self.Existencias.text = "\(existencias)"
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func loadScann(item : String){
        db.collection("SexyRevolverData").document("Inventario").collection("Articulos").document(item).getDocument { (document, error) in
            if let document : DocumentSnapshot = document, document.exists {
                let dataDescription : [String : Any]? = document.data()
                print("Document data: \(String(describing: dataDescription))")
                let nombre : String = dataDescription!["Nombre"] as! String
                let precioCompra : String = dataDescription!["Precio de Compra"] as! String
                let precioVenta : String = dataDescription!["Precio de Venta"] as! String
                let proovedor : String = dataDescription!["Proovedores"] as! String
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
}
