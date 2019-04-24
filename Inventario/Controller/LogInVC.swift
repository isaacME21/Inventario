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
import Parse

class LogInVC: UIViewController {

    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var Titulo: UILabel!
    @IBOutlet weak var Footer: UILabel!
    
    var email : UITextField?
    var password : UITextField?
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: VIEWDIDAPPEAR PARA CARGAR LA INFORMACION GUARDADA EN CONFIGURACION
    override func viewDidAppear(_ animated: Bool) {
        print("ViewDidAppear")
        
        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global(qos: .background).async {
            self.loadUserDefaults()
        }
        
    }
    
    //MARK: METODO PARA CARGAR INFORMACION DESDE PLIST
    func loadUserDefaults()  {
        if let tituloTemp = UserDefaults.standard.object(forKey: "Titulo") {
            DispatchQueue.main.async {
                self.Titulo.text = (tituloTemp as! String)
            }
        }
        if let footerTemp = UserDefaults.standard.object(forKey: "Footer")  {
            DispatchQueue.main.async {
                self.Footer.text = (footerTemp as! String)
            }
            
        }
        if let imageTemp = UserDefaults.standard.object(forKey: "Image")  {
            DispatchQueue.main.async {
                self.Image.image = UIImage(data: imageTemp as! Data)
            }
        }
        SVProgressHUD.dismiss()
    }
    
    
    
    
    
    //MARK: Metodo de firebase para el LogIn
    @IBAction func logIn(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Ingresa Tus Credenciales", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: email)
        alert.addTextField(configurationHandler: password)
        
        let OKAction = UIAlertAction(title: "Sign In", style: .default, handler: self.logIn)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(OKAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
        

    }
    
    
    //MARK: INICIALIZACION DE TEXTFIELDS EN ALERTS
    func email (textField: UITextField) {
        email = textField
        email?.placeholder = "User"
    }
    func password(textField: UITextField) {
        password = textField
        password?.placeholder = "Cotraseña"
        password?.isSecureTextEntry = true
    }
    
    
    //MARK: METODO FIREBASE LOG IN
    func logIn(alert: UIAlertAction) {
        
        let UserNameTemp = email!.text
        let contraseñaTemp = password!.text
        DispatchQueue.global().async {
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: UserNameTemp!, password: contraseñaTemp!) { (DataResult, error) in
                
                if error != nil{
                    print(error!)
                    
                    let alert = UIAlertController(title: "Error de Inicio de Sesion", message: "Lo sentimos, el usuario o la contraseña son incorrectos", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.present(alert, animated: true)
                    }
                    
                }
                else{
                    //Logeo exitoso
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = "ADMIN"
                    changeRequest?.commitChanges { (error) in
                        if let err = error {
                            print("DisplayName no se cambio: \(err)")
                        } else {
                            print("DisplayName se cambio")
                        }
                    }
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "gotoMain", sender: self)
                }
            }
        }
        
    }
        
    

    
    

}
