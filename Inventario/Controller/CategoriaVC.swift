//
//  CategoriaVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 11/5/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import SideMenu
import Firebase
import SVProgressHUD
import Parse

class CategoriaVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var categoria: UITextField!
    @IBOutlet weak var imagen: UIImageView!
    @IBOutlet weak var tabla: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    let db = Firestore.firestore()
    //let firebaseMethods = FirebaseMethods()
    
    let imagePicker = UIImagePickerController()
    let picker = UIPickerView()
    
    //MARK: VARIABLES PARA UISERACHBAR
    var dataFiltered = [String]()
    var isSearching = false
    var categorias = [String]()
    var categoriasInfo = [String : NSDictionary]()
    
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    //MARK: REFRESH CONTROL
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(CategoriaVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.blue
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageControl.currentPage = 0
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.5
        
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SwipeAction(swipe:)))
        leftSwipe.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(leftSwipe)
        
        
        //PickerView Categorias
        picker.delegate = self
        categoria.inputView = picker
        
        //MARK: INICIALIZACION DE VALIDACION
        nombre.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.allEditingEvents)
        
        
        nombre.layer.borderColor = UIColor.red.cgColor
        nombre.layer.borderWidth = 1
        
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
        categorias.removeAll()
        categoriasInfo.removeAll()
        self.loadFireStoreData()
        refreshControl.endRefreshing()
    }
    
    
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        categorias.removeAll()
    }
    

    
    //MARK: TABLA DE CATEGORIAS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return dataFiltered.count
        }
        
        return categorias.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        
        
        
        if isSearching{
            cell.textLabel?.text = dataFiltered[indexPath.row]
        }
        else {
            cell.textLabel?.text = categorias[indexPath.row]
        }
        
        
        return cell
    }
    
    //MOSTRAR INFORMACION AL TOCAR UNA CELDA
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cat = categorias[indexPath.row]
        
        if let infoCat = categoriasInfo[cat] {
            nombre.text = cat
            categoria.text = infoCat["Categoria"] as? String
            if let catImage = infoCat["Imagen"] {
                imagen.image = UIImage(data: catImage as! Data)
            }
        }else{
            let alert = UIAlertController(title: "No existe la categoria", message: nil, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            
            self.present(alert, animated: true)
        }
        validar()
    }
    
    //MARK: BUSQUEDA DE CATEGORIAS
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tabla.reloadData()
        } else {
            isSearching = true
            dataFiltered = categorias.filter({$0.contains(searchBar.text!)})
            tabla.reloadData()
        }
    }
    
    
    
    
    // MARK: UIPickerView Delegation
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categorias.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categorias[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoria.text = categorias[row]
    }
    

    
    
    
    //MARK: Funciones importantes
    //MARK: Metodo Importante
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("se supone que se tiene que cambiar la imagen")
            imagen.image = userPickedImage
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
    
    
    
    
    
    
    
    
    
    //MARK: Botones
    @IBAction func CameraTapped(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Escoge una Imagen", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor(red:0.82, green:0.64, blue:0.32, alpha:1.0)
        
        
        alert.addAction(UIAlertAction(title: "Camara", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Galeria", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancelar", style: .cancel, handler: nil))
        
        //Establecer donde se va a mostrar la alerta
        if let popoverController = alert.popoverPresentationController {
            
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
            
            //popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func BorrarFoto(_ sender: UIButton) {
        imagen.image = UIImage(named: "MarcoFotoBlack")
    }
    
    
    
    @IBAction func BorrarCategoria(_ sender: UIBarButtonItem) {
        
        if nombre.text?.isEmpty == false {
            deleteFireStoreData(Documento: nombre.text!)
            saveButton.isUserInteractionEnabled = false
            saveButton.alpha = 0.5
            categorias.removeAll()
            categoriasInfo.removeAll()
            nombre.text?.removeAll()
            categoria.text?.removeAll()
            imagen.image = UIImage(named: "MarcoFotoBlack")
            loadFireStoreData()
            nombre.layer.borderColor = UIColor.red.cgColor
            nombre.layer.borderWidth = 1
            
            
        } else{return}
    }
    
    
    
    @IBAction func Salir(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func BorrarCategorias(_ sender: UIButton) {
        categoria.text?.removeAll()
    }
    
    
    
    //MARK: Validacion
    
    @objc func textFieldDidChange(textField: UITextField) {
       validar()
    }
    
    func validar()  {
        
        nombre.layer.borderColor = UIColor.red.cgColor
        nombre.layer.borderWidth = 1
        
        if nombre.text?.isEmpty == false{
            saveButton.isUserInteractionEnabled = true
            saveButton.alpha = 1
            nombre.layer.borderWidth = 0
        } else {
            saveButton.isUserInteractionEnabled = false
            saveButton.alpha = 0.5
            nombre.layer.borderColor = UIColor.red.cgColor
        }
        
    }
    
    
    
    
    
    
    
    
    @IBAction func Save(_ sender: UIButton) {
        saveFireStoreData()
        categorias.removeAll()
        categoriasInfo.removeAll()
        loadFireStoreData()
        nombre.layer.borderColor = UIColor.red.cgColor
        nombre.layer.borderWidth = 1
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.5
    }
    
    
    //MARK: Firebase Methods
    func saveFireStoreData()  {
        if nombre.text?.isEmpty == false {
            db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Categorias").document(nombre.text!).setData([
                "Nombre" : nombre.text ?? "",
                "Categoria": categoria.text ?? "",
                "Imagen" : imagen.image?.jpegData(compressionQuality: 0.25) ?? ""] )
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    self.nombre.text?.removeAll()
                    self.tabla.reloadData()
                }
            }
            
        }
        
        if categoria.text?.isEmpty == false {
            db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Categorias").document(nombre.text!).setData([
                "Categoria": categoria.text!])
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    
                    self.categoria.text?.removeAll()
                    self.tabla.reloadData()
                }
            }
            
        }
        
        if imagen.image != UIImage(named: "MarcoFotoBlack") {
            db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Categorias").document(nombre.text!).setData([
                "Imagen" : imagen.image!.jpegData(compressionQuality: 0.25)!])
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    self.imagen.image = UIImage(named: "MarcoFotoBlack")
                    self.tabla.reloadData()
                }
            }
            
        }
        
    }


    func loadFireStoreData()  {

        db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Categorias").getDocuments { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    self.categorias.append(document.documentID)
                    self.categoriasInfo[document.documentID] = document.data() as NSDictionary
                    print(self.categorias)
                }
                self.tabla.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }


    func deleteFireStoreData(Documento : String)  {
        db.collection(Auth.auth().currentUser!.email!).document("Inventario").collection("Categorias").document(Documento).delete { (err) in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    
}



extension UIViewController {
    
    
    @objc func SwipeAction(swipe: UISwipeGestureRecognizer) {
        
        
        switch swipe.direction.rawValue {
        case 1:
            navigationController?.popToRootViewController(animated: true)
        case 2:
            performSegue(withIdentifier: "gotoRight", sender: self)
            
        default:
            break
        }
        
    }
    
}
