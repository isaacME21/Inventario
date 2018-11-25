//
//  ProductoVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 11/5/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ProductoVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabla: UITableView!
    
    
    
    @IBOutlet weak var referencia: UITextField!
    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var categoria: UITextField!
    @IBOutlet weak var atributos: UITextField!
    @IBOutlet weak var impuestos: UITextField!
    @IBOutlet weak var precioDeVenta: UITextField!
    @IBOutlet weak var PrecioDeCompra: UITextField!
    @IBOutlet weak var beneficoBruto: UITextField!
    @IBOutlet weak var margen: UITextField!
    @IBOutlet weak var proovedores: UITextField!
    
    
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var codigoDeBarras: UIImageView!
    
    @IBOutlet weak var switchPDF417: UISwitch!
    @IBOutlet weak var switchQR: UISwitch!
    
    @IBOutlet weak var saveButton: UIButton!
    
    let db = Firestore.firestore()
    let imagePicker = UIImagePickerController()
    var barcode = CodigosDeBarras()
    
    //MARK: VARIABLES PARA UISERACHBAR
    var dataFiltered = [String]()
    var isSearching = false
    var items = [String]()
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        referencia.delegate = self
        nombre.delegate = self
        categoria.delegate = self
        atributos.delegate = self
        impuestos.delegate = self
        precioDeVenta.delegate = self
        PrecioDeCompra.delegate = self
        beneficoBruto.delegate = self
        margen.delegate = self
        proovedores.delegate = self
        
        //MARK: INICIALIZACION DE VALIDACION
        referencia.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        nombre.addTarget(self, action:  #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        categoria.addTarget(self, action:  #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        atributos.addTarget(self, action:  #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        impuestos.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        precioDeVenta.addTarget(self, action:  #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        PrecioDeCompra.addTarget(self, action:  #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        beneficoBruto.addTarget(self, action:  #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        margen.addTarget(self, action:  #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        proovedores.addTarget(self, action:  #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.5
        switchPDF417.isUserInteractionEnabled = false
        switchPDF417.alpha = 0.5
        switchQR.isUserInteractionEnabled = false
        switchQR.alpha = 0.5
        
        
        pageControl.currentPage = 1
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SwipeAction(swipe:)))
        rightSwipe.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(rightSwipe)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global(qos: .background).async {
            self.loadFireStoreData()
        }
    }
    
    
    
    
    
    
    
    

    
    //BOTONES
    
    @IBAction func addProduct(_ sender: UIBarButtonItem) {
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
        
        //Establecer donde se va a mostrar la alerta
        if let popoverController = alert.popoverPresentationController {
            
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
            
            //popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func DeleteAll(_ sender: UIButton) {
    }
    
    
    @IBAction func save(_ sender: UIButton) {
        save()
    }
    

  
    
    //MARK: TABLA DE ARTICULOS
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nombre.text = items[indexPath.row]
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
    
    
    
    
    
    
    
    
    
    
    //MARK: Funciones importantes
    //MARK: Metodo Importante
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("se supone que se tiene que cambiar la imagen")
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
    
    
    
    
    
    
    
    
    
    
    
    //MARK: QUITAR TECLADO
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    
    //MARK: VALIDACION
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        var opcion:Int = 2
        var listo = 0
        let textfields:[UITextField] = [referencia,nombre,categoria,atributos,impuestos,precioDeVenta,PrecioDeCompra,beneficoBruto,margen,proovedores]
        for x in textfields {
            if !((x.text?.isEmpty)!){
                listo = listo + 1
            } else{
                listo = listo - 1
            }
        }
        if switchQR.isOn{ opcion = 3 }
        if switchPDF417.isOn { opcion = 1 }
        
        
        
        
        if (referencia.text?.isEmpty)! {
            switchPDF417.isUserInteractionEnabled = false
            switchPDF417.alpha = 0.5
            switchQR.isUserInteractionEnabled = false
            switchQR.alpha = 0.5
        }else if listo == 10{
            saveButton.isUserInteractionEnabled = true
            saveButton.alpha = 1
        }else{
            switchPDF417.isUserInteractionEnabled = true
            switchPDF417.alpha = 1.0
            switchQR.isUserInteractionEnabled = true
            switchQR.alpha = 1.0
            guard let imageTemp = barcode.generadorDeCodigosDeBarra(Referencia: referencia.text!, op: opcion) else {fatalError("Barcode Error")}
            codigoDeBarras.image = imageTemp
        }
    }
 

    @IBAction func PDF417On(_ sender: UISwitch) {
        switchQR.setOn(false, animated: true)
        guard let imageTemp = barcode.generadorDeCodigosDeBarra(Referencia: referencia.text!, op: 1) else {fatalError("Barcode Error")}
        codigoDeBarras.image = imageTemp
    }
    
    @IBAction func codeQROn(_ sender: UISwitch) {
        switchPDF417.setOn(false, animated: true)
        guard let imageTemp = barcode.generadorDeCodigosDeBarra(Referencia: referencia.text!, op: 3) else {fatalError("Barcode Error")}
        codigoDeBarras.image = imageTemp
    }
   
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: METODOS DE FIRESTORE
    
    func save()  {
        db.collection("\(String(describing: Auth.auth().currentUser!.email!))").document("Inventario").collection("Articulos").document(nombre.text!).setData([
            "Nombre" : nombre.text!,
            "Referencia" : referencia.text!,
            "Codigo De Barras" : codigoDeBarras.image?.jpegData(compressionQuality: 0.25) ?? "",
            "Categoria" : categoria.text!,
            "Atributos": atributos.text!,
            "Impuestos": impuestos.text!,
            "Precio de Venta": precioDeVenta.text!,
            "Precio de Compra": PrecioDeCompra.text!,
            "BeneficioBruto": beneficoBruto.text!,
            "Margen": margen.text!,
            "Proovedores": proovedores.text!,
            "Imagen": image.image?.jpegData(compressionQuality: 0.25) ?? ""])
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                self.items.append(self.nombre.text!)
                self.nombre.text?.removeAll()
                //self.tabla.reloadData()
            }
        }
        
    }
    
    
    func loadFireStoreData()  {
        
        db.collection("\(String(describing: Auth.auth().currentUser!.email!))").document("Inventario").collection("Articulos").getDocuments { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    self.items.append(document.documentID)
                    print(self.items)
                }
                self.tabla.reloadData()
                SVProgressHUD.dismiss()
                
                
            }
        }
    }

    
    
    
    
}
