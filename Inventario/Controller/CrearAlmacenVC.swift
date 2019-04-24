//
//  CrearAlmacenVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 1/3/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import Parse


class CrearAlmacenVC: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabla: UITableView!
    
    
    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var direccion1: UITextField!
    @IBOutlet weak var direccion2: UITextField!
    @IBOutlet weak var ciudad: UITextField!
    @IBOutlet weak var pais: UITextField!
    @IBOutlet weak var codigoPostal: UITextField!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
     let imagePicker = UIImagePickerController()
    let db = Firestore.firestore()
    
    //TODO: - VARIABLES PARA UISERACHBAR
    var dataFiltered = [String]()
    var isSearching = false
    var items = [String]()
    var itemInfo = [String : NSDictionary]()
    
    //MARK: REFRESH CONTROL
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(ClientesVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.blue
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.returnKeyType = UIReturnKeyType.done
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        //TODO: - OBSERVADORES PARA VALIDACION
        nombre.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        nombre.layer.borderWidth = 1.0
        nombre.layer.borderColor = UIColor.red.cgColor
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global(qos: .background).async {
            self.load(Collection: "Almacenes")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        items.removeAll()
        itemInfo.removeAll()
    }
    
    //TODO: - HANDLE REFRESH
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        items.removeAll()
        itemInfo.removeAll()
        self.load(Collection: "Almacenes")
        refreshControl.endRefreshing()
    }
    
    
    //TODO: - TABLA DE ALMACENES
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
        let cliente = items[indexPath.row]
        
        if let infoItem = itemInfo[cliente] {
            nombre.text = infoItem["Nombre"] as? String
            direccion1.text = infoItem["Direccion 1"] as? String
            direccion2.text = infoItem["Direccion 2"] as? String
            ciudad.text = infoItem["Ciudad"] as? String
            pais.text = infoItem["Pais"] as? String
            codigoPostal.text = infoItem["CP"] as? String
            validar()
        }else{
            let alert = UIAlertController(title: "No existe el cliente", message: nil, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            
            self.present(alert, animated: true)
        }
        
        
    }
    //TODO: - BUSQUEDA DE ARTICULOS
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
    
    //MARK: Metodo Importante
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image.image = userPickedImage
        }
        
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func openCamera(){
        
        if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            let alert  = UIAlertController(title: "Advertencia", message: "No tienes Camara", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary(){
        
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func deleteTexfields(){
        nombre.text?.removeAll()
        direccion1.text?.removeAll()
        direccion2.text?.removeAll()
        ciudad.text?.removeAll()
        pais.text?.removeAll()
        codigoPostal.text?.removeAll()
    }
    
    //TODO: - FUNCION QUE SE ACTIVA CADA VEZ QUE EL TEXTO DENTRO DE UN TEXTFIELD HA CAMBIADO
    @objc func textFieldDidChange(textField: UITextField) { validar() }
    
    //TODO: - FUNCION PARA VALIDAR
    func validar()  {
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.5
        nombre.layer.borderWidth = 1.0
        nombre.layer.borderColor = UIColor.red.cgColor
       
        
        if (nombre.text?.isEmpty)!{
            nombre.layer.borderColor = UIColor.red.cgColor
        }else{
            nombre.layer.borderWidth = 0
            saveButton.isUserInteractionEnabled = true
            saveButton.alpha = 1
        }
        
    }
    
    //TODO: - RESTRINGIR LA ENTRADA DE ALGUNOS CARACTERES EN TEXTFIELDS
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == codigoPostal {
            let caracteresPermitidos = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return caracteresPermitidos.isSuperset(of: characterSet)
        }
        
        let caracteresPermitidos = CharacterSet.init(charactersIn: "abcdefghijklmnopqrstuvwxyz1234567890.,-/ ")
        let characterSet = CharacterSet(charactersIn: string)
        return caracteresPermitidos.isSuperset(of: characterSet)
        
    }
    

    @IBAction func agregarAlmacen(_ sender: UIBarButtonItem) {
        deleteTexfields()
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.5
        image.image = UIImage(named: "MarcoFotoBlack")
        nombre.layer.borderWidth = 1.0
        nombre.layer.borderColor = UIColor.red.cgColor
        
    }
    @IBAction func guardarTodo(_ sender: UIButton) {
        var data = [String : Any]()
        data["Nombre"] = nombre.text ?? ""
        data["Direccion 1"] = direccion1.text ?? ""
        data["Direccion 2"] = direccion2.text ?? ""
        data["Ciudad"] = ciudad.text ?? ""
        data["Pais"] = pais.text ?? ""
        data["CP"] = codigoPostal.text ?? ""
        
        save(Collection: "Almacenes", Document: nombre.text!, Data: data)
        items.removeAll()
        itemInfo.removeAll()
        load(Collection: "Almacenes")
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.5
        image.image = UIImage(named: "MarcoFotoBlack")
        nombre.layer.borderWidth = 1.0
        nombre.layer.borderColor = UIColor.red.cgColor
        
    }
    @IBAction func eliminarAlmacen(_ sender: UIBarButtonItem) {
        
        if nombre.text?.isEmpty == false {
            deleteFireStoreData(Documento: nombre.text!)
            saveButton.isUserInteractionEnabled = false
            saveButton.alpha = 0.5
            deleteTexfields()
            items.removeAll()
            itemInfo.removeAll()
            load(Collection: "Almacenes")
            image.image = UIImage(named: "MarcoFotoBlack")
            nombre.layer.borderWidth = 1.0
            nombre.layer.borderColor = UIColor.red.cgColor
            
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Escoge una Imagen", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor(red:0.82, green:0.64, blue:0.32, alpha:1.0)
        
        
        alert.addAction(UIAlertAction(title: "Camara", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Galeria", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancelar", style: .cancel, handler: nil))
        
        
        if let popoverController = alert.popoverPresentationController {
            
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
            
        }
        
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func eliminarImagen(_ sender: UIButton) {
        image.image = UIImage(named: "MarcoFotoBlack")
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
    

    
    //TODO: - GUARDAR EN FIREBASE
    func save(Collection : String, Document : String, Data : [String : Any]){
        db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection(Collection).document(Document).setData(Data)
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                self.image.image = UIImage(named: "MarcoFotoBlack")
                self.deleteTexfields()
                self.saveButton.isUserInteractionEnabled = false
                self.saveButton.alpha = 0.5
            }
        }
    }
    
    //TODO: ELIMINAR INFORMACION DE FIREBASE
    func deleteFireStoreData(Documento : String)  {
        db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Almacenes").document(Documento).delete { (err) in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
}
