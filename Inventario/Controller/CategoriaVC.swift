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

class CategoriaVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var categoria: UITextField!
    @IBOutlet weak var imagen: UIImageView!
    @IBOutlet weak var tabla: UITableView!
    
    
    let db = Firestore.firestore()
    let imagePicker = UIImagePickerController()
    var categorias = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageControl.currentPage = 0
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(SwipeAction(swipe:)))
        leftSwipe.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(leftSwipe)
        
        //loadFireStoreData()
        
        
    }
    
    
    
    
    //MARK: TABLA
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorias.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = categorias[indexPath.row]
        
        return cell
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
        nombre.text?.removeAll()
        categoria.text?.removeAll()
    }
    
    @IBAction func Salir(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
    
    //MARK: Firebase Methods
    @IBAction func Save(_ sender: UIButton) {
        
        if nombre.text?.isEmpty == false {
            db.collection("\(String(describing: Auth.auth().currentUser!.email!))").document("Inventario").collection("Categorias").document(nombre.text!).setData([
                "Nombre" : nombre.text ?? "",
                "Categoria": categoria.text ?? "",
                "Imagen" : imagen.image?.jpegData(compressionQuality: 0.25) ?? ""] )
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    self.categorias.append(self.nombre.text!)
                    self.nombre.text?.removeAll()
                    self.categoria.text?.removeAll()
                    self.imagen.image = UIImage(named: "MarcoFotoBlack")
                    self.tabla.reloadData()
                }
            }

        }
        
    }
    
    
    func loadFireStoreData()  {
        
        db.collection("\(String(describing: Auth.auth().currentUser!.email!))").document("Inventario").collection("Categorias").getDocuments { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    self.categorias.append(document.documentID)
                    print(self.categorias)
                }
                self.tabla.reloadData()
                
                
            }
        }
    }
    
}



extension UIViewController {
    
    
    @objc func SwipeAction(swipe: UISwipeGestureRecognizer) {
        
        
        switch swipe.direction.rawValue {
        case 1:
            performSegue(withIdentifier: "gotoLeft", sender: self)
        case 2:
            performSegue(withIdentifier: "gotoRight", sender: self)
            
        default:
            break
        }
        
    }
    
}
