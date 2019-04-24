//
//  AlmacenVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 1/3/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import Parse

class AlmacenVC: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var tabla: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet weak var almacen: UITextField!
    @IBOutlet weak var vendidos: UITextField!
    @IBOutlet weak var existencias: UITextField!
    
    
    let db = Firestore.firestore()
    let picker = UIPickerView()
    
    //TODO: - VARIABLES PARA UISERACHBAR
    var dataFiltered = [String]()
    var isSearching = false
    var items = [String]()
    var itemInfo = [String : NSDictionary]()
    var items2 = [String]()
    var itemInfo2 = [String : NSDictionary]()
    
    //MARK: REFRESH CONTROL
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(AlmacenVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.blue
        
        return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.returnKeyType = UIReturnKeyType.done
        //PickerView Categorias
        picker.delegate = self
        almacen.inputView = picker
        
        self.tabla.addSubview(self.refreshControl)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global(qos: .background).async {
            self.load(Collection: "Almacenes")
        }
        
    }
    
    //TODO: - HANDLE REFRESH
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        items2.removeAll()
        itemInfo2.removeAll()
        guard let alm = almacen.text else {return}
        self.loadOption2(Almacen: alm)
        refreshControl.endRefreshing()
    }
    
    
    
    //TODO: - TABLA DE aRTICULOS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching { return dataFiltered.count }
        return items2.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        
        if isSearching{ cell.textLabel?.text = dataFiltered[indexPath.row] }
        else { cell.textLabel?.text = items2[indexPath.row] }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let articulo = items2[indexPath.row]
        
        existencias.text = itemInfo2[articulo]!["Cantidad"] as? String
    }
    //TODO: - BUSQUEDA DE ARTICULOS
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tabla.reloadData()
        } else {
            isSearching = true
            dataFiltered = items2.filter({$0.contains(searchBar.text!)})
            tabla.reloadData()
        }
    }
    
    
    // MARK: UIPickerView Delegation
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        almacen.text = items[row]
        loadOption2(Almacen: items[row])
    }
    
    
    //TODO: - BOTONES
    @IBAction func salir(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func gestionar(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "gotoAlmacenes", sender: self)
    }
    
    
    //TODO: - Cargar informacion de Firebase
    func load(Collection: String) {
        db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection(Collection).getDocuments { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    self.items.append(document.documentID)
                    self.itemInfo[document.documentID] = document.data() as NSDictionary
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
                self.items2.removeAll()
                for document in QuerySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    self.items2.append(document.documentID)
                    self.itemInfo2[document.documentID] = document.data() as NSDictionary
                }
                self.tabla.reloadData()
            }
        }
    }
    

}
