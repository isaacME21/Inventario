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
import SVProgressHUD



class ConfigurationVC:UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var Titulo: UITextField!
    @IBOutlet weak var MainImage: UIImageView!
    @IBOutlet weak var Footer: UITextField!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let imagePicker = UIImagePickerController()
    let db = Firestore.firestore()
    @IBOutlet weak var scroll: UIScrollView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        
        //MARK: Observadores para ajustar teclado
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        scroll.keyboardDismissMode = .onDrag
        
    }
    
    //MARK: Ajustar Teclado
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scroll.contentInset = UIEdgeInsets.zero
        } else {
            scroll.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        scroll.scrollIndicatorInsets = scroll.contentInset
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
        SVProgressHUD.showSuccess(withStatus: "Completado")
        

 
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
