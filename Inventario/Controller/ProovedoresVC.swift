//
//  ProovedoresVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 12/10/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class ProovedoresVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    

    
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabla: UITableView!
    
    @IBOutlet weak var proovedorID: UITextField!
    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var apellido: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var telefono1: UITextField!
    @IBOutlet weak var telefono2: UITextField!
    
    
    @IBOutlet weak var direccion1: UITextField!
    @IBOutlet weak var direccion2: UITextField!
    @IBOutlet weak var ciudad: UITextField!
    @IBOutlet weak var pais: UITextField!
    @IBOutlet weak var CP: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    class proovedor{
        var name = ""
        var ID : String?
        var apellido : String?
        var email : String?
        var telefono1 : String?
        var telefono2 : String?
        var direccion1 : String?
        var direccion2 : String?
        var ciudad : String?
        var pais : String?
        var CP: String?
    }
    
    let db = Firestore.firestore()
    
    //MARK: REFRESH CONTROL
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(ProovedoresVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.blue
        
        return refreshControl
    }()
    
    //MARK: VARIABLES PARA UISERACHBAR
    var dataFiltered = [String]()
    var isSearching = false
    var items = [String]()
    var itemInfo = [proovedor]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: DELEGATES
        proovedorID.delegate = self
        nombre.delegate = self
        apellido.delegate = self
        email.delegate = self
        telefono1.delegate = self
        telefono2.delegate = self
        direccion1.delegate = self
        direccion2.delegate = self
        ciudad.delegate = self
        pais.delegate = self
        CP.delegate = self
        searchBar.delegate = self
        
        
        //MARK: OBSERVADORES PARA VALIDACION
        proovedorID.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        searchBar.returnKeyType = UIReturnKeyType.done
        
        
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.5
       
        proovedorID.layer.borderColor = UIColor.red.cgColor
        proovedorID.layer.borderWidth = 1
        
         self.tabla.addSubview(self.refreshControl)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global(qos: .background).async {
            self.loadFireStoreData()
        }
    }
    
    
    //TODO: - HANDLE REFRESH
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        items.removeAll()
        itemInfo.removeAll()
        self.loadFireStoreData()
        refreshControl.endRefreshing()
    }
    
    //MARK: BOTONES
    @IBAction func GotoMain(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func BorrarProovedor(_ sender: UIBarButtonItem) {
        
        if proovedorID.text?.isEmpty == false {
            deleteFireStoreData(Documento: proovedorID.text!)
            saveButton.isUserInteractionEnabled = false
            saveButton.alpha = 0.5
            deleteTextFields()
            items.removeAll()
            itemInfo.removeAll()
            loadFireStoreData()
            borderTextFields1()
            colorTextFields()
        }
       
    }
    
    
    
    @IBAction func AgregarProovedor(_ sender: UIBarButtonItem) {
        deleteTextFields()
        borderTextFields1()
        colorTextFields()
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.5
    }
    @IBAction func Save(_ sender: UIButton) {
        save()
        items.removeAll()
        itemInfo.removeAll()
        loadFireStoreData()
        borderTextFields1()
        colorTextFields()
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.5

    }
    
    
    
    
    //MARK: BUSQUEDA DE ARTICULOS
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
    
    //MARK: TABLA DE PROOVEDORES
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching { return dataFiltered.count }
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
    
        if isSearching{ cell.textLabel?.text = dataFiltered[indexPath.row] }
        else { cell.textLabel?.text = items[indexPath.row] }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var proove : proovedor?
        for x in itemInfo{if x.ID == items[indexPath.row]{ proove = x}}
        
        if proove != nil {
            proovedorID.text = proove?.ID ?? ""
            nombre.text = proove?.name ?? ""
            apellido.text = proove?.apellido ?? ""
            email.text = proove?.email ?? ""
            telefono1.text = proove?.telefono1 ?? ""
            telefono2.text = proove?.telefono2 ?? ""
            direccion1.text = proove?.direccion1 ?? ""
            direccion2.text = proove?.direccion2 ?? ""
            ciudad.text = proove?.ciudad ?? ""
            pais.text = proove?.pais ?? ""
            CP.text = proove?.CP ?? ""
            validar()
        }else {
            let alert = UIAlertController(title: "No existe el proovedor", message: nil, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            
            self.present(alert, animated: true)
        }
        
       
 
    }
    
    
    
    //MARK: VALIDACION
    @objc func textFieldDidChange(textField: UITextField) {
        validar()
    }
    
    func validar()  {
        proovedorID.layer.borderColor = UIColor.red.cgColor
        proovedorID.layer.borderWidth = 1
        
        if (proovedorID.text?.isEmpty)!{
            saveButton.isUserInteractionEnabled = false
            saveButton.alpha = 0.5
            proovedorID.layer.borderColor = UIColor.red.cgColor
        }else{
            saveButton.isUserInteractionEnabled = true
            saveButton.alpha = 1
            proovedorID.layer.borderWidth = 0
        }
    }
    
    //TODO: - RESTRINGIR LA ENTRADA DE ALGUNOS CARACTERES EN TEXTFIELDS
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == telefono1 {
            let caracteresPermitidos = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return caracteresPermitidos.isSuperset(of: characterSet)
        }
        
        if textField == telefono2 {
            let caracteresPermitidos = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return caracteresPermitidos.isSuperset(of: characterSet)
        }
        
        if textField == CP {
            let caracteresPermitidos = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return caracteresPermitidos.isSuperset(of: characterSet)
        }
        
        if textField == email {
            let caracteresPermitidos = CharacterSet.init(charactersIn: "abcdefghijklmnñopqrstuvwxyz@.")
            let characterSet = CharacterSet(charactersIn: string)
            return caracteresPermitidos.isSuperset(of: characterSet)
        }
        
        let caracteresPermitidos = CharacterSet.init(charactersIn: "abcdefghijklmnopqrstuvwxyz1234567890.,- ")
        let characterSet = CharacterSet(charactersIn: string)
        return caracteresPermitidos.isSuperset(of: characterSet)
        
    }
    
    //MARK: BORRAR TEXTFIELDS
    
    func deleteTextFields()  {
        proovedorID.text?.removeAll()
        nombre.text?.removeAll()
        apellido.text?.removeAll()
        email.text?.removeAll()
        telefono1.text?.removeAll()
        telefono2.text?.removeAll()
        direccion1.text?.removeAll()
        direccion2.text?.removeAll()
        ciudad.text?.removeAll()
        pais.text?.removeAll()
        CP.text?.removeAll()
    }
    //TODO: - BORDER TEXTFIELDS
    func borderTextFields1() {
        proovedorID.layer.borderWidth = 1.0
    }
    func borderTextFields2() {
        proovedorID.layer.borderWidth = 0

    }
    //TODO: - COLOR TEXTFIELDS
    func colorTextFields() {
        proovedorID.layer.borderColor = UIColor.red.cgColor
    }
    
    
    
    //MARK: METODOS DE FIRESTORE
    
    func save()  {
        var data = [String : Any]()
        data["ID"] = proovedorID.text!
        data["Nombre"] = nombre.text ?? ""
        data["Apellido"] = apellido.text ?? ""
        data["email"] = email.text ?? ""
        data["Telefono 1"] = telefono1.text ?? ""
        data["Telefono 2"] = telefono2.text ?? ""
        data["Direccion 1"] = direccion1.text ?? ""
        data["Direccion 2"] = direccion2.text ?? ""
        data["Ciudad"] = ciudad.text ?? ""
        data["Pais"] = pais.text ?? ""
        data["CP"] = CP.text ?? ""
        
        
        
        db.collection("SexyRevolverData").document("Inventario").collection("Proovedores").document(proovedorID.text!).setData(data)
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                self.deleteTextFields()
                self.saveButton.isUserInteractionEnabled = false
                self.saveButton.alpha = 0.5
            }
        }

    }
    
    func loadFireStoreData()  {
        
        //MARK: CARGAR PROOVEDORES
        db.collection("SexyRevolverData").document("Inventario").collection("Proovedores").getDocuments { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    self.items.append(document.documentID)
                    let infoItem = document.data()
                    let item = proovedor()
                    item.name = infoItem["Nombre"] as! String
                    item.apellido = infoItem["Aoellido"] as? String
                    item.ID = infoItem["ID"] as? String
                    item.email = infoItem["email"] as? String
                    item.telefono1 = infoItem["Telefono 1"] as? String
                    item.telefono2 = infoItem["Telefono 2"] as? String
                    item.direccion1 = infoItem["Direccion 1"] as? String
                    item.direccion2 = infoItem["Direccion 2"] as? String
                    item.ciudad = infoItem["Ciudad"] as? String
                    item.pais = infoItem["Pais"] as? String
                    item.CP = infoItem["CP"] as? String
                    self.itemInfo.append(item)
                }
                self.tabla.reloadData()
                SVProgressHUD.dismiss()
                
                
            }
        }
    }
    
    func deleteFireStoreData(Documento : String)  {
        db.collection("SexyRevolverData").document("Inventario").collection("Proovedores").document(Documento).delete { (err) in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
        
        
}


