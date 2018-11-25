//
//  ViewController.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 10/27/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import UIKit
import SideMenu
import SVProgressHUD
class MainVC: UIViewController {
    
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var footer: UILabel!
    @IBOutlet weak var logo: UIImageView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
    
        
    }
    override func viewDidAppear(_ animated: Bool) {
        SVProgressHUD.show(withStatus: "Cargando")
        DispatchQueue.global(qos: .background).async {
            self.loadUserDefaults()
        }
        
    }
    
    
    func loadUserDefaults()  {
        if let tituloTemp = UserDefaults.standard.object(forKey: "Titulo") {
            DispatchQueue.main.async {
                self.titulo.text = (tituloTemp as! String)
            }
        }
        if let footerTemp = UserDefaults.standard.object(forKey: "Footer")  {
            DispatchQueue.main.async {
                self.footer.text = (footerTemp as! String)
            }
            
        }
        if let imageTemp = UserDefaults.standard.object(forKey: "Image")  {
            DispatchQueue.main.async {
                self.logo.image = UIImage(data: imageTemp as! Data)
            }
        }
        SVProgressHUD.dismiss()
        
        
    }

}

