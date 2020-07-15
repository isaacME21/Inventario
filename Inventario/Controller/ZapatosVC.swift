//
//  ZapatosVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 7/26/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ZapatosVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //TEXTFIELDS OUTLETS
    @IBOutlet weak var referenciaTextField: UITextField!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var tallaTextField: UITextField!
    @IBOutlet weak var proovedorTextField: UITextField!
    @IBOutlet weak var impuestosTextField: UITextField!
    @IBOutlet weak var precioDeCompraTextField: UITextField!
    @IBOutlet weak var precioDeVentaTextField: UITextField!
    @IBOutlet weak var beneficioBrutoTextField: UITextField!
    @IBOutlet weak var margenTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var descripcionTextField: UITextField!
    
    
    //TABLE OUTLET
    @IBOutlet weak var tabla: UITableView!
    
    //SEARCH BAR OUTLET
    @IBOutlet weak var searchBar: UISearchBar!
    
    //IMAGE OUTLET
    @IBOutlet weak var zapatoView: UIImageView!
    @IBOutlet weak var camaraButton: UIButton!
    @IBOutlet weak var deleteImageButton: UIButton!
    
    
    //PICKERVIEWS
    let tallaPicker : UIPickerView = UIPickerView()
    let proovedorPicker : UIPickerView = UIPickerView()
    let taxPicker : UIPickerView = UIPickerView()
    let imagePicker : UIImagePickerController = UIImagePickerController()
    
    let db = Firestore.firestore()
    
    //MARK: ARRAYS DE PRUEBA
    let tallasZapato = ["22.5","23","23.5","24","24.5","25","25.5","26","27"]
    let impuestosArray : [String] = ["10","16","20"]
    var proovedoresArray : [String] = [String]()
    var zapatos = [Zapatos]()
    
    //MARK: VARIABLES PARA UISERACHBAR
    var dataFiltered : [Zapatos] = [Zapatos]()
    var isSearching : Bool = false
    
    let errorColor = UIColor.red
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //PICKER VIEW CONFIG
        imagePicker.delegate = self
        
        tallaPicker.delegate = self
        tallaTextField.inputView = tallaPicker
        
        proovedorPicker.delegate = self
        proovedorTextField.inputView = proovedorPicker
        
        taxPicker.delegate = self
        impuestosTextField.inputView = taxPicker
        
        //MARK: INICIALIZACION DE VALIDACION
        referenciaTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        nombreTextField.addTarget(self, action:  #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        tallaTextField.addTarget(self, action:  #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        impuestosTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        precioDeVentaTextField.addTarget(self, action:  #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        precioDeCompraTextField.addTarget(self, action:  #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        beneficioBrutoTextField.addTarget(self, action:  #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        margenTextField.addTarget(self, action:  #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        proovedorTextField.addTarget(self, action:  #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        descripcionTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.5
        
        borderTextFields1()
        colorTextFields()
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global(qos: .background).async {
            self.loadZapatos()
        }
    }
    
    //MARK: BUSQUEDA DE ARTICULOS
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tabla.reloadData()
        } else {
            isSearching = true
            dataFiltered = zapatos.filter({$0.zapatoName!.contains(searchBar.text!)})
            tabla.reloadData()
        }
    }
    
    
    
    @IBAction func camaraTapped(_ sender: UIButton) {
        let alert : UIAlertController = UIAlertController(title: "Escoge una Imagen", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor(red:0.82, green:0.64, blue:0.32, alpha:1.0)
        
        
        alert.addAction(UIAlertAction(title: "Camara", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Galeria", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancelar", style: .cancel, handler: nil))
        
        //Establecer donde se va a mostrar la alerta
        guard let popoverController = alert.popoverPresentationController else { fatalError("Error en popOverController")}
        
        popoverController.sourceView = self.view
        popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        popoverController.permittedArrowDirections = []
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteImage(_ sender: UIButton) {
        zapatoView.image = UIImage(named: "MarcoFotoBlack")
    }
    
    
    @IBAction func save(_ sender: UIButton) {
        var saveData = [String : Any] ()
        
        saveData["Referencia"] = referenciaTextField.text
        saveData["Nombre"] = nombreTextField.text
        saveData["Talla"] = tallaTextField.text
        saveData["Proovedor"] = proovedorTextField.text
        saveData["Atributos"] = descripcionTextField.text
        saveData["Precio De Compra"] = precioDeCompraTextField.text
        saveData["Precio De Venta"] = precioDeVentaTextField.text
        saveData["Beneficio Bruto"] = beneficioBrutoTextField.text
        saveData["Margen"] = margenTextField.text
        saveData["Impuestos"] = impuestosTextField.text
        saveData["Fecha"] = Date()
        

        self.saveZapatos(name: self.nombreTextField.text!, data: saveData)
        
    }
    
    @IBAction func agregarZapato(_ sender: UIBarButtonItem) {
        deleteTextfields()
        validacion()
    }
    
    @IBAction func eliminarZapato(_ sender: UIBarButtonItem) {
        if nombreTextField.text?.isEmpty == false{
            deleteFireStoreData(Documento: nombreTextField.text!)
        }
    }
    
    //MARK: VALIDACION
    @objc func textFieldDidChange(textField: UITextField) {
        validacion()
    }
    //MARK: VALIDACION
    func validacion(){
        saveButton.isUserInteractionEnabled = false
        saveButton.alpha = 0.5
        colorTextFields()
        borderTextFields1()
        
        var listo : Int = 0
        
        let textfields:[UITextField] = [referenciaTextField,nombreTextField,tallaTextField,impuestosTextField,precioDeVentaTextField,precioDeCompraTextField,beneficioBrutoTextField,margenTextField,proovedorTextField, descripcionTextField]
        
        for x in textfields {
            if !((x.text?.isEmpty)!){
                listo = listo + 1
            } else{
                listo = listo - 1
            }
        }

        
        if (nombreTextField.text?.isEmpty)! {
            nombreTextField.layer.borderColor = errorColor.cgColor
        }else{
            nombreTextField.layer.borderWidth = 0
        }
        
        if (tallaTextField.text?.isEmpty)! {
            tallaTextField.layer.borderColor = errorColor.cgColor
        }else {
            tallaTextField.layer.borderWidth = 0
        }
        
        
        if (impuestosTextField.text?.isEmpty)! {
            impuestosTextField.layer.borderColor = errorColor.cgColor
        }else{
            impuestosTextField.layer.borderWidth = 0
        }
        
        if (precioDeVentaTextField.text?.isEmpty)!{
            precioDeVentaTextField.layer.borderColor = errorColor.cgColor
        }else{
            precioDeVentaTextField.layer.borderWidth = 0
        }
        
        if (beneficioBrutoTextField.text?.isEmpty)! {
            beneficioBrutoTextField.layer.borderColor = errorColor.cgColor
        }else{
            beneficioBrutoTextField.layer.borderWidth = 0
        }
        
        if (margenTextField.text?.isEmpty)! {
            margenTextField.layer.borderColor = errorColor.cgColor
        }else{
            margenTextField.layer.borderWidth = 0
        }
        
        if (proovedorTextField.text?.isEmpty)! {
            proovedorTextField.layer.borderColor = errorColor.cgColor
        }else{
            proovedorTextField.layer.borderWidth = 0
        }
        
        if (descripcionTextField.text?.isEmpty)! {
            descripcionTextField.layer.borderColor = errorColor.cgColor
        }else{
            descripcionTextField.layer.borderWidth = 0
        }
        
        
        if (precioDeCompraTextField.text?.isEmpty)!{
            precioDeCompraTextField.layer.borderColor = errorColor.cgColor
        }else {
            precioDeVentaTextField.text = "\(precioVenta())"
            beneficioBrutoTextField.text = "\(margenBruto())"
            margenTextField.text = "\(porcentajeBruto())"
            precioDeCompraTextField.layer.borderWidth = 0
        }
        
        
        if (referenciaTextField.text?.isEmpty)! {
            referenciaTextField.layer.borderColor = errorColor.cgColor
        }else{
            referenciaTextField.layer.borderWidth = 0
        }
        
        if listo == 10{
            saveButton.isUserInteractionEnabled = true
            saveButton.alpha = 1
        }
        
    }
    
    
    
    //MARK: CALCULAR PRECIO DE VENTA, MARGEN BRUTO Y PORCENTAJE BRUTO
    func precioVenta() -> Double{
        let compra : Double = (precioDeCompraTextField.text! as NSString).doubleValue
        let costoMXN = compra * 20.5
        let MUO = costoMXN / 2
        let factorUtilidad = costoMXN * 4
        let MUOFactor = MUO + factorUtilidad
        let PVMC = (MUOFactor * 0.07) + MUOFactor
        
        return PVMC
    }
    func margenBruto() -> Double{
        let compra : Double = (precioDeCompraTextField.text! as NSString).doubleValue
        let costoMXN = compra * 20.5
        let MUO = costoMXN / 2
        let factorUtilidad = costoMXN * 4
        let MUOFactor = MUO + factorUtilidad
        let PVMC = (MUOFactor * 0.07) + MUOFactor
        let margenBruto = PVMC - costoMXN
        
        return margenBruto
    }
    func porcentajeBruto() -> Double{
        let compra : Double = (precioDeCompraTextField.text! as NSString).doubleValue
        let venta : Double = compra * 4.7
        let margenBruto : Double = venta - compra
        let x : Double = margenBruto / venta
        let porcentajeBruto : Double = Double(round(1000*x)/1000)
        return porcentajeBruto * 100
    }

    //MARK: BORRAR LOS TEXTFIELDS
    func deleteTextfields(){
        nombreTextField.text?.removeAll()
        referenciaTextField.text?.removeAll()
        impuestosTextField.text?.removeAll()
        precioDeVentaTextField.text?.removeAll()
        precioDeCompraTextField.text?.removeAll()
        beneficioBrutoTextField.text?.removeAll()
        margenTextField.text?.removeAll()
        proovedorTextField.text?.removeAll()
        descripcionTextField.text?.removeAll()
        tallaTextField.text?.removeAll()
    }
    //TODO: - BORDER TEXTFIELDS
    func borderTextFields1() {
        nombreTextField.layer.borderWidth = 1.0
        referenciaTextField.layer.borderWidth = 1.0
        impuestosTextField.layer.borderWidth = 1.0
        precioDeVentaTextField.layer.borderWidth = 1.0
        precioDeCompraTextField.layer.borderWidth = 1.0
        beneficioBrutoTextField.layer.borderWidth = 1.0
        margenTextField.layer.borderWidth = 1.0
        proovedorTextField.layer.borderWidth = 1.0
        descripcionTextField.layer.borderWidth = 1.0
        tallaTextField.layer.borderWidth = 1.0
    }
    func borderTextFields2() {
        nombreTextField.layer.borderWidth = 0
        referenciaTextField.layer.borderWidth = 0
        impuestosTextField.layer.borderWidth = 0
        precioDeVentaTextField.layer.borderWidth = 0
        precioDeCompraTextField.layer.borderWidth = 0
        beneficioBrutoTextField.layer.borderWidth = 0
        margenTextField.layer.borderWidth = 0
        proovedorTextField.layer.borderWidth = 0
        descripcionTextField.layer.borderWidth = 0
        tallaTextField.layer.borderWidth = 0
    }
    //TODO: - COLOR TEXTFIELDS
    func colorTextFields() {
        nombreTextField.layer.borderColor = errorColor.cgColor
        referenciaTextField.layer.borderColor = errorColor.cgColor
        impuestosTextField.layer.borderColor = errorColor.cgColor
        precioDeVentaTextField.layer.borderColor = errorColor.cgColor
        precioDeCompraTextField.layer.borderColor = errorColor.cgColor
        beneficioBrutoTextField.layer.borderColor = errorColor.cgColor
        margenTextField.layer.borderColor = errorColor.cgColor
        proovedorTextField.layer.borderColor = errorColor.cgColor
        descripcionTextField.layer.borderColor = errorColor.cgColor
        tallaTextField.layer.borderColor = errorColor.cgColor
    }
    
    
    
    //MARK: TABLEVIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
            return dataFiltered.count
        }else{
            return zapatos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching{
            let cell : UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
            cell.textLabel?.text = dataFiltered[indexPath.row].zapatoName
            
            return cell
        }else {
            let cell : UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
            cell.textLabel?.text = zapatos[indexPath.row].zapatoName
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var zapato : Zapatos?
        if isSearching{
            zapato = dataFiltered[indexPath.row]
        }else{
            zapato = zapatos[indexPath.row]
        }
        
        
        referenciaTextField.text = zapato!.referencia
        nombreTextField.text = zapato!.zapatoName
        tallaTextField.text = zapato!.talla
        proovedorTextField.text = zapato!.proovedor
        descripcionTextField.text = zapato!.descripcion
        precioDeVentaTextField.text = zapato!.precioDeVenta
        precioDeCompraTextField.text = zapato!.precioDeCompra
        margenTextField.text = zapato!.margen
        beneficioBrutoTextField.text = zapato!.beneficioBruto
        impuestosTextField.text = zapato!.impuestos
        
        loadImages(name: nombreTextField.text!)
        
        validacion()
        
    }
    
    
    
    //MARK: PICKERVIEW METHODS
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == tallaPicker{
            return tallasZapato.count
        }else if pickerView == proovedorPicker{
            return proovedoresArray.count
        }else{
            return impuestosArray.count
        }
        
    }
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == tallaPicker{
           return tallasZapato[row]
        }else if pickerView == proovedorPicker{
            return proovedoresArray[row]
        }else{
            return impuestosArray[row]
        }

    }
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == tallaPicker{
            tallaTextField.text = tallasZapato[row]
        }else if pickerView == proovedorPicker{
            proovedorTextField.text = proovedoresArray[row]
        }else {
            impuestosTextField.text = impuestosArray[row]
        }
        
        validacion()
    }

    
    //MARK: IMAGEPICKER METHODS
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else{fatalError("Error en userPickerImage")}
        
        zapatoView.image = userPickedImage
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func openCamera(){
        
        if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            let alert : UIAlertController  = UIAlertController(title: "Advertencia", message: "No tienes Camara", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    func openGallary(){
        
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
  
    
    
    
    //Firebase Methods
    func loadZapatos(){
        zapatos.removeAll()
        proovedoresArray.removeAll()
        
        db.collection("SexyRevolverData").document("Inventario").collection("Zapatos").getDocuments { (QuerySnapshot, err) in
            if let err : Error = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    
                    let newZapato = Zapatos(name: document.documentID)
                    newZapato.zapatoName = data["Nombre"] as? String
                    newZapato.referencia = data["Referencia"] as? String ?? ""
                    newZapato.talla = data["Talla"] as? String ?? ""
                    newZapato.proovedor = data["Proovedor"] as? String ?? ""
                    newZapato.descripcion = data["Atributos"] as? String ?? ""
                    newZapato.precioDeCompra = data["Precio De Compra"] as? String ?? ""
                    newZapato.precioDeVenta = data["Precio De Venta"] as? String ?? ""
                    newZapato.margen = data["Margen"] as? String ?? ""
                    newZapato.beneficioBruto = data["Beneficio Bruto"] as? String ?? ""
                    newZapato.impuestos = data["Impuestos"] as? String ?? ""
                    
                    
                    self.zapatos.append(newZapato)
                }
                //MARK: CARGAR PROOVEDORES
                self.db.collection("SexyRevolverData").document("Inventario").collection("Proovedores").getDocuments { (QuerySnapshot, err) in
                    if let err : Error = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in QuerySnapshot!.documents {
                            //print("\(document.documentID) => \(document.data())")
                            self.proovedoresArray.append(document.documentID)
                        }
                        self.tabla.reloadData()
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
        
    }
    
    func loadImages(name : String){
        let storageReference : StorageReference = Storage.storage().reference()
        let profileImageRef : StorageReference = storageReference.child("Zapatos").child(name)
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
                    self.zapatoView.image = UIImage(data: imageData as Data)
                    print("Se bajo la foto")
                } catch {
                    print(error)
                }
            }
        }
    }
    
    
    func saveZapatos(name : String, data : [String : Any]){
        db.collection("SexyRevolverData").document("Inventario").collection("Zapatos").document(name).setData(data){ err in
            if let err : Error = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                self.saveButton.isUserInteractionEnabled = false
                self.saveButton.alpha = 0.5
                self.loadZapatos()
            }
            if self.zapatoView.image != UIImage(named: "MarcoFotoBlack"){
                let imageData = self.zapatoView.image?.jpegData(compressionQuality: 0.25)
                self.uploadProfileImage(imageData: imageData!, name: name)
            }
        }
    }
    
    func deleteFireStoreData(Documento : String)  {
        db.collection("SexyRevolverData").document("Inventario").collection("Zapatos").document(Documento).delete { (err) in
            if let err : Error = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                self.deleteTextfields()
                self.loadZapatos()
                
                let storageReference : StorageReference = Storage.storage().reference()
                let profileImageRef : StorageReference = storageReference.child("Zapatos").child(Documento)
                //Removes image from storage
                profileImageRef.delete { error in
                    if let error : Error = error {
                        print(error)
                    } else {
                        print("File successfully removed!")
                    }
                }
            }
        }
    }
    
    func uploadProfileImage(imageData: Data , name : String){
        let storageReference : StorageReference = Storage.storage().reference()
        let profileImageRef : StorageReference = storageReference.child("Zapatos").child(name)
        
        let uploadMetaData : StorageMetadata = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        profileImageRef.putData(imageData, metadata: uploadMetaData) { (uploadedImageMeta, error) in
            if error != nil
            {
                print("Error took place \(String(describing: error?.localizedDescription))")
                return
            } else {
                print("Meta data of uploaded image \(String(describing: uploadedImageMeta))")
                self.zapatoView.image = UIImage(named: "MarcoFotoBlack")
            }
        }
    }
    
    

}
