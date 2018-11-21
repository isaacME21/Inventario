//
//  ConfigurationVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 10/31/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import CoreData
import Firebase



class ConfigurationVC:UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var Titulo: UITextField!
    @IBOutlet weak var MainImage: UIImageView!
    @IBOutlet weak var Footer: UITextField!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let imagePicker = UIImagePickerController()
    let db = Firestore.firestore()
    
    
    //let MyDatabase = Database.database().reference()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
    }
    
    
    //MARK: Quitar teclado
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    
    
    //MARK: Metodo Importante
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            MainImage.image = userPickedImage
        }
        
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    //MARK: Funciones de Botones


    @IBAction func CameraTapped(_ sender: UIBarButtonItem) {
        
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
            popoverController.barButtonItem = sender
        }
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    
    
    @IBAction func Save(_ sender: UIButton) {
        
        UserDefaults.standard.set(MainImage.image?.pngData() ?? "", forKey: "Image")
        UserDefaults.standard.set(Titulo.text ?? "", forKey: "Titulo")
        UserDefaults.standard.set(Footer.text ?? "", forKey: "Footer")
        print("Se guardo Exitosamente")
        
        
        //        db.collection("\(String(describing: Auth.auth().currentUser!.email!))").document("Configuracion").setData([
        //            "Titulo" : Titulo.text ?? "",
        //            "Footer": Footer.text ?? "",
        //            "Image" : MainImage.image?.jpegData(compressionQuality: 0.25) ?? ""] )
        //        { err in
        //                if let err = err {
        //                    print("Error writing document: \(err)")
        //                } else {
        //                    print("Document successfully written!")
        //                }
        //        }

        
        
//        MyDatabase.child("\(String(describing: Auth.auth().currentUser!.uid))").child("Configuracion").setValue([
//            "Titulo" : Titulo.text ?? "",
//            "Footer": Footer.text ?? ""])
//            "Image" : MainImage.image?.jpegData(compressionQuality: 0.25) ?? ""])
        
    }
    
    
    
    
    
    
    
    @IBAction func Salir(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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
    
    
    
    
}