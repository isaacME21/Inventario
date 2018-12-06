//
//  LogInVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 11/8/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LogInVC: UIViewController {

    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var Correo: UITextField!
    @IBOutlet weak var Contraseña: UITextField!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var vista: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

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
    
    
    
    
    //MARK: Cargar la foto de configuracion
    override func viewDidAppear(_ animated: Bool) {
        let imageTemp = UserDefaults.standard.object(forKey: "Image")
        Image.image = UIImage(data: imageTemp as! Data)
    }
    
    
    
    //MARK: Metodo de firebase para el LogIn
    @IBAction func logIn(_ sender: UIButton) {
        let correoTemp = Correo.text
        let contraseñaTemp = Contraseña.text
        
        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global(qos: .background).async {
            
            Auth.auth().signIn(withEmail: correoTemp! , password: contraseñaTemp!) { (DataResult, error) in
                
                if error != nil{
                    print(error!)
                    
                    let alert = UIAlertController(title: "Error de Inicio de Sesion", message: "Lo sentimos, el usuario o la contraseña son incorrectos", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                    
                }
                else{
                    //Logeo exitoso
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "gotoMain", sender: self)
                }
            }

        }

    }
    
    
    

}
