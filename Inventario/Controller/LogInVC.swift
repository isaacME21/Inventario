//
//  LogInVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 11/8/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase

class LogInVC: UIViewController {

    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var Correo: UITextField!
    @IBOutlet weak var Contraseña: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    //MARK: Quitar teclado
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    //MARK: Cargar la foto de configuracion
    override func viewDidAppear(_ animated: Bool) {
        let imageTemp = UserDefaults.standard.object(forKey: "Image")
        Image.image = UIImage(data: imageTemp as! Data)
    }
    
    
    
    //MARK: Metodo de firebase para el LogIn
    @IBAction func logIn(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: Correo.text!, password: Contraseña.text!) { (DataResult, error) in
            
            if error != nil{
                print(error!)
                
                let alert = UIAlertController(title: "Error de Inicio de Sesion", message: "Lo sentimos, el usuario o la contraseña son incorrectos", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true)
            }
            else{
                //Logeo exitoso
                
                self.performSegue(withIdentifier: "gotoMain", sender: self)
            }
        }

    }
    
    
    
    
    

    
    
  

}
