//
//  VizualizarArticulosVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 12/28/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class VizualizarArticulosVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabla: UITableView!
    
    
    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var almacen: UITextField!
    @IBOutlet weak var precioDeCompra: UITextField!
    @IBOutlet weak var precioDeVenta: UITextField!
    @IBOutlet weak var Existencias: UITextField!
    @IBOutlet weak var proovedor: UITextField!
    
    @IBOutlet weak var imagen: UIImageView!
    
    
    let db = Firestore.firestore()
    
    let picker = UIPickerView()
    
    //MARK: VARIABLES PARA UISERACHBAR
    var dataFiltered = [String]()
    var items = [String]()
    var isSearching = false
    var itemsInfo = [item]()
    
    var almacenes = ["Almacen 1","Almacen 2", "Almacen 3", "Almacen 4"]
    
    //MARK: REFRESH CONTROL
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(VizualizarArticulosVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.blue
        
        return refreshControl
    }()
    
    class item{
        var name = ""
        var precioDeCompra : String?
        var precioDeVenta : String?
        var proovedores : String?
        var imagen : UIImage?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.returnKeyType = UIReturnKeyType.done
        picker.delegate = self
        almacen.inputView = picker
        
        self.tabla.addSubview(self.refreshControl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global(qos: .background).async {
            //(self.items,self.itemInfo) = self.firebase.load(Collection: "Clientes")
            self.load(Collection: "Articulos")
        }
        
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
        var art : item?
        for x in itemsInfo{if x.name == items[indexPath.row]{ art = x}}
        
        if art != nil {
            if let itemImage = art?.imagen{
                imagen.image = itemImage
            }else{
                imagen.image = UIImage(named: "MarcoFotoBlack")
            }
            nombre.text = art!.name
            precioDeCompra.text = art?.precioDeCompra ?? ""
            precioDeVenta.text = art?.precioDeVenta ?? ""
            proovedor.text = art?.proovedores ?? ""
        }else{
            let alert = UIAlertController(title: "No existe la categoria", message: nil, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            
            self.present(alert, animated: true)
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
        }else{ alertInput() }
        
    }
    
    @IBAction func salir(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //TODO: - Cargar informacion de Firebase
    func load(Collection: String) {
        db.collection("SexyRevolverData").document("Inventario").collection(Collection).getDocuments { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    self.items.append(document.documentID)
                    let infoItem = document.data()
                    let itemObj = item()
                    itemObj.name = infoItem["Nombre"] as! String
                    itemObj.precioDeCompra = infoItem["Precio de Compra"] as? String
                    itemObj.precioDeVenta = infoItem["Precio de Venta"] as? String
                    itemObj.proovedores = infoItem["Proovedores"] as? String
                    
                    
                    let storageReference = Storage.storage().reference()
                    let profileImageRef = storageReference.child("Articulos").child(document.documentID)
                    // Fetch the download URL
                    profileImageRef.downloadURL { url, error in
                        if let error = error {
                            // Handle any errors
                            print("Error took place \(error.localizedDescription)")
                        } else {
                            // Get the download URL for 'images/stars.jpg'
                            print("Profile image download URL \(String(describing: url!))")
                            do {
                                let imageData : NSData = try NSData(contentsOf: url!)
                                itemObj.imagen = UIImage(data: imageData as Data)
                                print("Se bajo la foto")
                            } catch {
                                print(error)
                            }
                        }
                        self.itemsInfo.append(itemObj)
                    }
                }
                self.tabla.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }

}
