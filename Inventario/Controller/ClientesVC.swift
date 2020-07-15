//
//  ClientesVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 12/13/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class ClientesVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabla: UITableView!
    
    @IBOutlet weak var VipButton: UISwitch!
    
    @IBOutlet weak var clienteID: UITextField!
    @IBOutlet weak var tarjeta: UITextField!
    @IBOutlet weak var deudaMaxima: UITextField!
    @IBOutlet weak var deudaActual: UITextField!
    @IBOutlet weak var fecha: UITextField!
    
    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var apellido: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var telefono1: UITextField!
    @IBOutlet weak var telefono2: UITextField!
    @IBOutlet weak var direccion1: UITextField!
    @IBOutlet weak var direccion2: UITextField!
    @IBOutlet weak var ciudad: UITextField!
    @IBOutlet weak var pais: UITextField!
    @IBOutlet weak var CP: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var newEmail : UITextField?
    var password : UITextField?
    
    
    let firebase : FuncionesFirebase = FuncionesFirebase()
    let db : Firestore = Firestore.firestore()
    
    let datePicker : UIDatePicker = UIDatePicker()
    
    //TODO: - VARIABLES PARA UISERACHBAR
    var dataFiltered : [String] = [String]()
    var isSearching : Bool = false
    var items : [String] = [String]()
    var itemInfo : [String : NSDictionary] = [String : NSDictionary]()

    let errorColor = UIColor.red
    
    //MARK: REFRESH CONTROL
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl : UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(ClientesVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.blue
        
        return refreshControl
    }()
    
    //MARK: VARIABLES PARA BASE DE DATOS SECUNDARIA
    var users : [String] = [String]()
    var usersInfo : [String : NSDictionary] = [String : NSDictionary]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        borderTextFields1()
        colorTextFields()
        
        searchBar.returnKeyType = UIReturnKeyType.done
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.5
        
        
        //MARK: LOS DELEGATES SE DECLARARON EN EL STORYBOARD
        
        //TODO: - OBSERVADORES PARA VALIDACION
        clienteID.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        deudaMaxima.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        nombre.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        apellido.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        email.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        pass.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        telefono1.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        direccion1.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        ciudad.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        pais.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        CP.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        //TODO: - OBSERVADOR PARA DATEPICKER
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(ClientesVC.dateChange(DatePicker:)), for: .valueChanged)
        fecha.inputView = datePicker
        
        self.tabla.addSubview(self.refreshControl)
        
        do{ try Auth.auth().signOut() }
        catch{ print("Error al cerrar sesion") }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global(qos: .background).async {
            self.load()
        }
        
    }
    
    //TODO: - HANDLE REFRESH
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        items.removeAll()
        itemInfo.removeAll()
        self.load()
        refreshControl.endRefreshing()
    }
    
    //TODO: - BOTONES
    @IBAction func salir(_ sender: UIBarButtonItem) {
        if Auth.auth().currentUser != nil{
            dismiss(animated: true, completion: nil)
        }else{
            let correo = UserDefaults.standard.object(forKey: "UserName") as? String
            let pass = UserDefaults.standard.object(forKey: "Pass") as? String
            Auth.auth().signIn(withEmail: correo!, password: pass!) { (DataResult, error) in
                if error != nil{
                    print(error!)
                }
                else{
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func borrarCliente(_ sender: UIBarButtonItem) {
        
        if clienteID.text?.isEmpty == false{
            deleteFireStoreData(Documento: email.text!)
            saveButton.isUserInteractionEnabled = false
            saveButton.alpha = 0.5
            deleteTextFields()
            items.removeAll()
            itemInfo.removeAll()
            load()
            borderTextFields1()
            colorTextFields()
        }
        
        
    }
    @IBAction func agregarCliente(_ sender: UIBarButtonItem) {
        deleteTextFields()
        borderTextFields1()
        colorTextFields()
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.5
        
        let alert : UIAlertController = UIAlertController(title: "Ingresa Tus Credenciales", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: newEmail)
        alert.addTextField(configurationHandler: password)
        
        let OKAction : UIAlertAction = UIAlertAction(title: "Crear", style: .default, handler: self.crearUsuario)
        let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(OKAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
        
    }
    @IBAction func guardarCliente(_ sender: UIButton) {
        var vipStatus : Bool = false
        if VipButton.isOn == true {
            vipStatus = true
        }
        
        
        var data : [String : Any] = [String : Any]()
        data["ID"] = clienteID.text ?? ""
        data["Tarjeta"] = tarjeta.text ?? ""
        data["Deuda Actual"] = deudaActual.text ?? ""
        data["Deuda Maxima"] = deudaMaxima.text ?? ""
        data["Fecha"] = fecha.text ?? ""
        data["VIP Status"] = VipButton.isOn
        data["Nombre"] = nombre.text ?? ""
        data["Apellido"] = apellido.text ?? ""
        data["email"] = email.text ?? ""
        data["Pass"] = pass.text ?? ""
        data["Telefono 1"] = telefono1.text ?? ""
        data["Telefono 2"] = telefono2.text ?? ""
        data["Direccion 1"] = direccion1.text ?? ""
        data["Direccion 2"] = direccion2.text ?? ""
        data["Ciudad"] = ciudad.text ?? ""
        data["Pais"] = pais.text ?? ""
        data["CP"] = CP.text ?? ""
        data["VIP Status"] = vipStatus
        
        save(Document: clienteID.text!, Data: data)
        items.removeAll()
        itemInfo.removeAll()
        load()
        borderTextFields1()
        colorTextFields()
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.5
        VipButton.setOn(false, animated: true)
    }
    
    
    //TODO: - TABLA DE CLIENTES
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching { return dataFiltered.count }
        
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        
        if isSearching{ cell.textLabel?.text = dataFiltered[indexPath.row] }
        else { cell.textLabel?.text = items[indexPath.row] }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cliente : String = items[indexPath.row]
        
        if let infoItem : NSDictionary = itemInfo[cliente] {
            clienteID.text = cliente
            tarjeta.text = infoItem["Tarjeta"] as? String
            deudaActual.text = infoItem["Deuda Actual"] as? String
            deudaMaxima.text = infoItem["Deuda Maxima"] as? String
            fecha.text = infoItem["Fecha"] as? String
            nombre.text = infoItem["Nombre"] as? String
            apellido.text = infoItem["Apellido"] as? String
            email.text = infoItem["email"] as? String
            pass.text = infoItem["Pass"] as? String
            telefono1.text = infoItem["Telefono 1"] as? String
            telefono2.text = infoItem["Telefono 2"] as? String
            direccion1.text = infoItem["Direccion 1"] as? String
            direccion2.text = infoItem["Direccion 2"] as? String
            ciudad.text = infoItem["Ciudad"] as? String
            pais.text = infoItem["Pais"] as? String
            CP.text = infoItem["CP"] as? String
            let VIP = infoItem["VIP Status"] as? Bool
            if VIP == true{
                VipButton.setOn(true, animated: true)
            }
            validar()
        }else{
            let alert : UIAlertController = UIAlertController(title: "No existe el cliente", message: nil, preferredStyle: .alert)
            let OKAction : UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            
            self.present(alert, animated: true)
        }
        
        
    }
    
    
    
    //TODO: - BUSQUEDA DE CLIENTES
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
    
    //TODO: - FUNCION QUE SE ACTIVA CADA VEZ QUE EL TEXTO DENTRO DE UN TEXTFIELD HA CAMBIADO
    @objc func textFieldDidChange(textField: UITextField) { validar() }
    
    //TODO: - FUNCION PARA VALIDAR
    func validar()  {
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.5
        colorTextFields()
        borderTextFields1()
        
        var listo : Int = 0
        let textfields : [UITextField?] = [clienteID,nombre,apellido,email,telefono1,direccion1,ciudad,pais,CP,pass]
        
        for x in textfields {
            if (x?.text?.isEmpty)!{
                listo = listo - 1
            }else{
                listo = listo + 1
            }
        }
        
        
        
        if (clienteID.text?.isEmpty)! {
            clienteID.layer.borderColor = errorColor.cgColor
        }else{
            clienteID.layer.borderWidth = 0
        }
        
        
        if (nombre.text?.isEmpty)! {
            nombre.layer.borderColor = errorColor.cgColor
        }else {
            nombre.layer.borderWidth = 0
        }
        
        if (apellido.text?.isEmpty)! {
            apellido.layer.borderColor = errorColor.cgColor
        }else {
            apellido.layer.borderWidth = 0
        }
        
        
        if (email.text?.isValidEmail())!{
            email.layer.borderWidth = 0
        }else {
            listo = listo - 1
            email.layer.borderColor = errorColor.cgColor
        }
        
        if (pass.text?.isEmpty)!{
            pass.layer.borderColor = errorColor.cgColor
        }else {
            pass.layer.borderWidth = 0
        }
        
        
        if (telefono1.text?.isEmpty)! {
            telefono1.layer.borderColor = errorColor.cgColor
        }else {
            telefono1.layer.borderWidth = 0
        }
        
        if (direccion1.text?.isEmpty)! {
            direccion1.layer.borderColor = errorColor.cgColor
        }else {
            direccion1.layer.borderWidth = 0
        }
        
        if (ciudad.text?.isEmpty)! {
            ciudad.layer.borderColor = errorColor.cgColor
        }else {
            ciudad.layer.borderWidth = 0
        }
        
        if (pais.text?.isEmpty)! {
            pais.layer.borderColor = errorColor.cgColor
        }else {
            pais.layer.borderWidth = 0
        }
        
        if (CP.text?.isEmpty)! {
            CP.layer.borderColor = errorColor.cgColor
        }else {
            CP.layer.borderWidth = 0
        }
        
        
        if listo == 10{
            saveButton.isUserInteractionEnabled = true
            saveButton.alpha = 1
            borderTextFields2()
        }
    }
    
    
    //TODO: - RESTRINGIR LA ENTRADA DE ALGUNOS CARACTERES EN TEXTFIELDS
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == deudaMaxima {
            let caracteresPermitidos : CharacterSet = CharacterSet.decimalDigits
            let characterSet : CharacterSet = CharacterSet(charactersIn: string)
            return caracteresPermitidos.isSuperset(of: characterSet)
        }
        
        if textField == deudaActual {
            let caracteresPermitidos : CharacterSet = CharacterSet.decimalDigits
            let characterSet : CharacterSet = CharacterSet(charactersIn: string)
            return caracteresPermitidos.isSuperset(of: characterSet)
        }
        
        if textField == telefono1 {
            let caracteresPermitidos : CharacterSet = CharacterSet.decimalDigits
            let characterSet : CharacterSet = CharacterSet(charactersIn: string)
            return caracteresPermitidos.isSuperset(of: characterSet)
        }
        
        if textField == telefono2 {
            let caracteresPermitidos : CharacterSet = CharacterSet.decimalDigits
            let characterSet : CharacterSet = CharacterSet(charactersIn: string)
            return caracteresPermitidos.isSuperset(of: characterSet)
        }
        
        if textField == CP {
            let caracteresPermitidos : CharacterSet = CharacterSet.decimalDigits
            let characterSet : CharacterSet = CharacterSet(charactersIn: string)
            return caracteresPermitidos.isSuperset(of: characterSet)
        }
        
        if textField == email {
            let caracteresPermitidos : CharacterSet = CharacterSet.init(charactersIn: "abcdefghijklmnñopqrstuvwxyz@.")
            let characterSet : CharacterSet = CharacterSet(charactersIn: string)
            return caracteresPermitidos.isSuperset(of: characterSet)
        }
        
        let caracteresPermitidos : CharacterSet = CharacterSet.init(charactersIn: "abcdefghijklmnopqrstuvwxyz1234567890.,-/ ")
        let characterSet : CharacterSet = CharacterSet(charactersIn: string)
        return caracteresPermitidos.isSuperset(of: characterSet)
        
    }
    

    //TODO: - BORRAR TEXTFIELDS
    func deleteTextFields()  {
        clienteID.text?.removeAll()
        tarjeta.text?.removeAll()
        deudaMaxima.text?.removeAll()
        deudaActual.text?.removeAll()
        fecha.text?.removeAll()
        nombre.text?.removeAll()
        apellido.text?.removeAll()
        email.text?.removeAll()
        pass.text?.removeAll()
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
        clienteID.layer.borderWidth = 1.0
        deudaMaxima.layer.borderWidth = 1.0
        nombre.layer.borderWidth = 1.0
        apellido.layer.borderWidth = 1.0
        email.layer.borderWidth = 1.0
        pass.layer.borderWidth = 1.0
        telefono1.layer.borderWidth = 1.0
        direccion1.layer.borderWidth = 1.0
        ciudad.layer.borderWidth = 1.0
        pais.layer.borderWidth = 1.0
        CP.layer.borderWidth = 1.0
    }
    func borderTextFields2() {
        clienteID.layer.borderWidth = 0
        deudaMaxima.layer.borderWidth = 0
        nombre.layer.borderWidth = 0
        apellido.layer.borderWidth = 0
        email.layer.borderWidth = 0
        pass.layer.borderWidth = 0
        telefono1.layer.borderWidth = 0
        direccion1.layer.borderWidth = 0
        ciudad.layer.borderWidth = 0
        pais.layer.borderWidth = 0
        CP.layer.borderWidth = 0
    }
    //TODO: - COLOR TEXTFIELDS
    func colorTextFields() {
        clienteID.layer.borderColor = errorColor.cgColor
        deudaMaxima.layer.borderColor = errorColor.cgColor
        nombre.layer.borderColor = errorColor.cgColor
        apellido.layer.borderColor = errorColor.cgColor
        email.layer.borderColor = errorColor.cgColor
        pass.layer.borderColor = errorColor.cgColor
        telefono1.layer.borderColor = errorColor.cgColor
        direccion1.layer.borderColor = errorColor.cgColor
        ciudad.layer.borderColor = errorColor.cgColor
        pais.layer.borderColor = errorColor.cgColor
        CP.layer.borderColor = errorColor.cgColor
    }
    //TODO: INICIALIZACION DE TEXTFIELDS EN ALERTS
    func newEmail (textField: UITextField) {
        newEmail = textField
        newEmail?.placeholder = "User"
    }
    
    func password(textField: UITextField) {
        password = textField
        password?.placeholder = "Cotraseña"
        password?.isSecureTextEntry = true
    }
    
    
    //TODO: - GUARDAR EN FIREBASE
    func save(Document : String, Data : [String : Any]){
        db.collection("Users").document(Document).updateData(Data)
        { err in
            if let err : Error = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                self.deleteTextFields()
                self.saveButton.isUserInteractionEnabled = false
                self.saveButton.alpha = 0.5
            }
        }
    }
    //TODO: - Cargar informacion de Firebase
    func load() {
        db.collection("Users").getDocuments { (QuerySnapshot, err) in
            if let err : Error = err {
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
    //TODO: ELIMINAR INFORMACION DE FIREBASE
    func deleteFireStoreData(Documento : String)  {
        Auth.auth().signIn(withEmail: Documento, password: pass.text!) { (DataResult, error) in
            
            if error != nil{
                print(error!)
            }
            else{
                let user : User? = Auth.auth().currentUser
                
                user?.delete { error in
                    if let error : Error = error {
                        print(error)
                    } else {
                        print("Se borro la cuenta")
                    }
                }
            }
        }

        
        
        db.collection("Users").document(Documento).delete { (err) in
            if let err : Error = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    //TODO: CREAR USUARIO
    func crearUsuario(alert: UIAlertAction)  {
        Auth.auth().createUser(withEmail: newEmail!.text!, password: password!.text!) { (DataResult, Error) in
            
            if Error != nil{
                
                if Error!.localizedDescription == "The email address is already in use by another account."{
                    
                    let alert : UIAlertController = UIAlertController(title: "Error al registrar", message: "El e-mail ya esta en uso", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
                }
                
                let alert : UIAlertController = UIAlertController(title: "Error al registrar", message: "No ingresaste un correo o tu contraseña tiene menos de 6 caracteres", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
            }
            else{
                //Se guardo el usuario
                print("Registration Complete")
                
                let usuarioActual : User? = Auth.auth().currentUser
                let defaultData : [String : Any] = ["Nombre": "",
                                                    "Apellido": "",
                                                    "Cumpleaños":"",
                                                    "CP":"",
                                                    "ID":"",
                                                    "VIP Status":false,
                                                    "Vigencia":"10/19",
                                                    "Ciudad":"",
                                                    "Deuda Actual":"",
                                                    "Deuda Maxima":"",
                                                    "Direccion 1":"",
                                                    "Direccion 2":"",
                                                    "Fecha":"",
                                                    "Tarjeta":usuarioActual!.uid,
                                                    "Telefono 1":"",
                                                    "Telefono 2":"",
                                                    "email":self.newEmail!.text!,
                                                    "Pass":self.password!.text!]
                
                
                self.db.collection("Users").document(self.newEmail!.text!).setData(defaultData){ err in
                    if let err : Error = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                        self.items.removeAll()
                        self.itemInfo.removeAll()
                        self.load()
                        
                        do{
                            try Auth.auth().signOut()
                        }
                        catch{
                            print("Error al cerrar sesion")
                        }
                        
                    }
                }
            }
        }
    }
    
    
    //TODO: - FUNCION DE DATEPICKER
    @objc func dateChange(DatePicker: UIDatePicker){
        let dateFormat : DateFormatter = DateFormatter()
        dateFormat.dateFormat =  "MM/dd/yyyy"
        fecha.text = dateFormat.string(from: datePicker.date)
    }

}
extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex : NSRegularExpression = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
