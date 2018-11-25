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
