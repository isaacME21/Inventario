//
//  POSVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 6/28/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase

class POSVC: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var articulos: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var existenciasTextField: UITextField!
    @IBOutlet weak var almacenTextField: UITextField!
    @IBOutlet weak var tabla: UITableView!
    @IBOutlet weak var totalTextField: UITextField!
    @IBOutlet weak var pagadoLabel: UILabel!
    @IBOutlet weak var efectivoButton: UIButton!
    @IBOutlet weak var tarjetaButton: UIButton!
    @IBOutlet weak var apartadoButton: UIButton!
    @IBOutlet weak var cambioTextField: UITextField!
    
    
    var articulosCollection = [ArticulosPOS]()
    var articulosComprados = [ArticulosPOS]()
    var almacenes = [String]()
    let db = Firestore.firestore()
    let almacenPicker : UIPickerView = UIPickerView()
    var totalString : String = ""
    var totalDouble : Double = 0.0
    var totalCompra : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        almacenPicker.delegate = self
        almacenTextField.delegate = self
        almacenTextField.inputView = almacenPicker
        tabla.register(UINib(nibName: "CustomTableViewCell", bundle: nil) , forCellReuseIdentifier: "cell")
        
        tarjetaButton.isEnabled = false
        efectivoButton.isEnabled = false
        tarjetaButton.backgroundColor = .red
        efectivoButton.backgroundColor = .red
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global().async {
            self.loadAlmacenes()
        }
    }
    
    //MARK CALCULADORA/PAD
    @IBAction func POS(_ sender: UIButton) {
        switch sender.tag{
        case 0:
            totalString = totalString + "1"
        case 1:
            totalString = totalString + "2"
        case 2:
            totalString = totalString + "3"
        case 3:
            totalString = totalString + "4"
        case 4:
            totalString = totalString + "5"
        case 5:
            totalString = totalString + "6"
        case 6:
            totalString = totalString + "7"
        case 7:
            totalString = totalString + "8"
        case 8:
            totalString = totalString + "9"
        case 9:
            totalString = totalString + "0"
        case 10:
            totalString = totalString + "."
        case 11:
            totalString.removeAll()
            totalDouble = 0.0
            totalCompra = 0.0
            efectivoButton.isEnabled = false
            efectivoButton.backgroundColor = .red
            tarjetaButton.isEnabled = false
            tarjetaButton.backgroundColor = .red
            cambioTextField.text = ""
        case 12:
            print("Pago en efectivo")
            articulosComprados.removeAll()
            tabla.reloadData()
            cambioTextField.text = "\(totalDouble - totalCompra)"
            #warning("Resolver problema con las existencias")
        case 13:
            print("Pago con tarjeta")
        default:
            print("Esa opcion no existe")
        }
        pagadoLabel.text = totalString
        //Convertir el total de la calduladora en Double
        if let totalTemp = Double(totalString){
            
            totalDouble = totalTemp
            //Si el array de articulos comprados no esta vacio obtener el total de la compra
            if articulosComprados.isEmpty == false{
                
                var total = 0.0
                for y in articulosComprados{
                    total = total + (y.precio! * Double(y.seleccionado))
                }
                //Si el total de la calculadora es mayor o igual al total de la compra, acccionar o no los botones
                if totalDouble >= total{
                    
                    totalCompra = total
                    efectivoButton.isEnabled = true
                    efectivoButton.backgroundColor = .green
                    tarjetaButton.isEnabled = true
                    tarjetaButton.backgroundColor = .green
                }
            }
        }
        
    }
    
    
    
    
    //MARK: TABLEVIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articulosComprados.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        cell.profilePhoto.image = articulosComprados[indexPath.row].image!
        cell.upLabel.text = "Articulo"
        cell.diaLabel.text = "Precio"
        cell.downLabel.text = articulosComprados[indexPath.row].name + " X\(articulosComprados[indexPath.row].seleccionado)"
        cell.mesLabel.text = "\(articulosComprados[indexPath.row].precio! * Double(articulosComprados[indexPath.row].seleccionado))"
    
        
        return cell
    }
    
    
    
    //Mark: SwipeAction en la derecha (BORRAR)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete : UIContextualAction = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let action : UIContextualAction = UIContextualAction(style: .destructive, title: "delete") { (action, view, completion) in
            self.articulosComprados.remove(at: indexPath.row)
            self.tabla.reloadData()
            completion(true)
        }
        action.image = UIImage(named: "Trash")
        action.backgroundColor = .red
        
        return action
    }
    
    
    // MARK: UIPickerView Delegation
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
        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global().async {
            self.loadArticulos(almacen: self.almacenes[row])
        }
    }
    
    
    // MARK: COLLECTION VIEW DELEGATE AND DATA SOURCE
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articulosCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let collection = collectionView.dequeueReusableCell(withReuseIdentifier: "collection", for: indexPath) as! ArticulosCollectionViewCell
        
        if let imageTemp = articulosCollection[indexPath.row].image{
            collection.image.image = imageTemp
        }
        collection.label.text = articulosCollection[indexPath.row].name
        
        return collection
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        articulosComprados.removeAll()
        articulosCollection[indexPath.row].comprado = true
        for x in articulosCollection{ if x.comprado == true{ articulosComprados.append(x)} }
        
        if  articulosCollection[indexPath.row].seleccionado < articulosCollection[indexPath.row].num {
            articulosCollection[indexPath.row].seleccionado = articulosComprados[indexPath.row].seleccionado + 1
            existenciasTextField.text = "\(articulosCollection[indexPath.row].num - articulosCollection[indexPath.row].seleccionado)"
            
            var total = 0.0
            for y in articulosComprados{ total = total + (y.precio! * Double(y.seleccionado)) }
            totalTextField.text = "\(total)"
        }
        tabla.reloadData()
    }
    
    
    //MARK: FIREBASE METHODS
    func loadAlmacenes(){
        db.collection("SexyRevolverData").document("Inventario").collection("Almacenes").getDocuments { (QuerySnapshot, err) in
            if let err : Error = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    self.almacenes.append(document.documentID)
                }
                print("Se cargaron los almacenes")
                self.loadArticulos(almacen: self.almacenes.first!)
            }
        }
    }
    func loadArticulos(almacen : String)  {
       articulosCollection.removeAll()
        db.collection("SexyRevolverData").document("Inventario").collection("Almacenes").document(almacen).collection("Articulos").getDocuments { (QuerySnapshot, err) in
            if let err : Error = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let existencia = data["Cantidad"] as! Int
                    let newItem = ArticulosPOS(nombre: document.documentID, numero: existencia)
                    self.articulosCollection.append(newItem)
                }
                print("se cargaron los articulos")
                self.loadPrecios()
                
            }
        }
    }
    
    func loadPrecios(){
        for item in articulosCollection{
            db.collection("SexyRevolverData").document("Inventario").collection("Articulos").document(item.name).getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data()
                    let precioTemp = dataDescription!["Precio de Venta"] as? String
                    item.precio = Double(precioTemp!)
                    print(precioTemp)
                } else {
                    print("Document does not exist")
                }
            }
        }
        print("Se cargaron los precios")
        self.loadImagenes()
    }
    
    
    func loadImagenes(){
        let numArticulos = articulosCollection.count
        var bandera = 0
        for articulo in articulosCollection{
            let storageReference : StorageReference = Storage.storage().reference()
            let profileImageRef : StorageReference = storageReference.child("Articulos").child(articulo.name)
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
                        articulo.image = UIImage(data: imageData as Data)
                        print("Se bajo la foto")
                        bandera = bandera + 1
                        
                        if bandera == numArticulos{
                            SVProgressHUD.dismiss()
                            self.collectionView.reloadData()
                        }
                    }catch{
                        print(error)
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }

}
