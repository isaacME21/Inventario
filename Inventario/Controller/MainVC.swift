//
//  ViewController.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 10/27/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import SideMenu
import Firebase
class MainVC: UIViewController {
    
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var footer: UILabel!
    @IBOutlet weak var logo: UIImageView!
    let db = Firestore.firestore()
    //let MyDatabase = Database.database().reference()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
    
        
    }
    override func viewDidAppear(_ animated: Bool) {
        loadUserDefaults()
    }
    
    
    func loadUserDefaults()  {
        if let tituloTemp = UserDefaults.standard.object(forKey: "Titulo") {
            titulo.text = (tituloTemp as! String)
        }
        if let footerTemp = UserDefaults.standard.object(forKey: "Footer")  {
            footer.text = (footerTemp as! String)
        }
        if let imageTemp = UserDefaults.standard.object(forKey: "Image")  {
            logo.image = UIImage(data: imageTemp as! Data)
        }
        
        
        
    }
    
    
    
    
    
    
    
    
//    
//        func loadFireStoreData()  {
//    
//            let configRef = db.collection("\(String(describing: Auth.auth().currentUser!.email!))").document("Configuracion")
//    
//            configRef.getDocument { (document, error) in
//                if let document = document, document.exists {
//                    let dataDescription = document.data() ?? nil
//    
//                    self.titulo.text = dataDescription!["Titulo"] as? String
//                    self.footer.text = dataDescription!["Footer"] as? String
//                    let imageData = dataDescription!["Image"] as? Data
//                    self.logo.image = UIImage(data: imageData!)
//    
//                    print("Document data: \(String(describing: dataDescription))")
//                } else {
//                    print("Document does not exist")
//                }
//            }
//    
//        }

    
    
    
//    func RealTimeDatabase()  {
//        
//        
//        
//        MyDatabase.child(Auth.auth().currentUser!.uid).child("Configuracion").observe(.value, with: {
//            (snapshot) in
//            
//            print(snapshot)
//            
//            if let value = snapshot.value as? [String : AnyObject] {
//                
//                self.titulo.text = value["Titulo"] as? String
//                self.footer.text = value["Footer"] as? String
//                //let imageData = value["Image"] as? Data
//                //self.logo.image = UIImage(data: imageData!)
//                
//            }
//            
//        }) { (error) in
//            print(error.localizedDescription)
//        }
//    
//    
//
//
//}

}

