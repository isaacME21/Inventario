//
//  TraspasoEnEsperaVC.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 4/26/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import UIKit
import Firebase

class TraspasoEnEsperaVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var tabla: UITableView!
    let db : Firestore = Firestore.firestore()
    let months : [String] = ["ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEPT","OCT","NOV","DEC"]
    var Pedidos : [Pedido] = [Pedido]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabla.register(UINib(nibName: "CustomTableViewCell", bundle: nil) , forCellReuseIdentifier: "cell")
    }
    override func viewWillAppear(_ animated: Bool) {
        load()
    }
    
    //TODO: TABLEVIEW METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Pedidos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let calendario : Calendar = Calendar(identifier: .gregorian)
        let month : Int = calendario.component(.month, from: Pedidos[indexPath.row].fecha)
        let day : Int = calendario.component(.day, from: Pedidos[indexPath.row].fecha)
        
        let cell : CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.upLabel.text = "ID"
        cell.downLabel.text = Pedidos[indexPath.row].id
        cell.downLabel.minimumScaleFactor = 0.7
        cell.downLabel.adjustsFontSizeToFitWidth = true
        cell.diaLabel.text = "\(day)"
        cell.mesLabel.text = months[month - 1]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pedido : Pedido = Pedidos[indexPath.row]
        var pedidoText : String = ""
        
        for (index, x) in pedido.articulosorden.enumerated(){
            pedidoText = pedidoText + "\n\(x) -> \(pedido.articulos[index])"
        }
        
        let alert : UIAlertController = UIAlertController(title: "Detalles del pedido", message: pedidoText , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
    }
    
    //Mark: SwipeAction en la derecha
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete : UIContextualAction = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        let action : UIContextualAction = UIContextualAction(style: .destructive, title: "delete") { (action, view, completion) in
            self.UpdateAlmacen(Almacen: self.Pedidos[indexPath.row].almacen1, Pedido: self.Pedidos[indexPath.row])
            completion(true)
        }
        action.image = UIImage(named: "Trash")
        action.backgroundColor = .red
        
        return action
    }
    
    //MARK: SwipeAction a la izquierda
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let complete : UIContextualAction  = completeAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [complete])
    }
    
    
    func completeAction(at indexPath: IndexPath) -> UIContextualAction {
        let action : UIContextualAction = UIContextualAction(style: .destructive, title: "ReAgendar") { (action, view, completion) in
            self.UpdateAlmacen(Almacen: self.Pedidos[indexPath.row].almacen2, Pedido: self.Pedidos[indexPath.row])
            completion(true)
        }
        action.image = UIImage(named: "tick")
        action.backgroundColor = .green
        
        return action
    }
    
    
    //TODO: LOAD DATA
    func load(){
        Pedidos.removeAll()
        db.collection("Pedidos En Espera").getDocuments { (querySnapshot, err) in
            if let err : Error = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    let data : [String : Any] = document.data()
                    let activo = data["Activo"] as! Bool
                    
                    if activo == true{
                        let orden : Pedido = Pedido()
                        let fecha : Timestamp = data["Fecha"] as! Timestamp
                        
                        let brookenArticulos : NSMutableArray = (data["Articulos"] as! NSMutableArray)
                        let brookenOrdenArticulos : NSMutableArray = (data["ArticuloOrden"] as! NSMutableArray)
                        
                        var articulosFixed : [Int] = [Int]()
                        var articulosOrdenFixed : [String] = [String]()
                        
                        for x in brookenArticulos{articulosFixed.append(x as! Int)}
                        for y in brookenOrdenArticulos{articulosOrdenFixed.append(y as! String)}
                        
                        orden.almacen1 = data["Almacen 1"] as! String
                        orden.almacen2 = data["Almacen 2"] as! String
                        orden.articulos = articulosFixed
                        orden.articulosorden = articulosOrdenFixed
                        orden.fecha = fecha.dateValue()
                        orden.id = document.documentID
                        
                        self.Pedidos.append(orden)
                    }
                }
                self.tabla.reloadData()
            }
        }
    }
    
    //MARK: Actualiza el almacen 1 o 2
    func UpdateAlmacen(Almacen : String, Pedido : Pedido){
        var articulos : [String : Int] = [String:Int]()
        
        db.collection("SexyRevolverData").document("Inventario").collection("Almacenes").document(Almacen).collection("Articulos").getDocuments { (QuerySnapshot, err) in
            if let err : Error = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data : [String : Any] = document.data()
                    let cantidad : Int = data["Cantidad"] as! Int
                    articulos[document.documentID] = cantidad
                }
                //MARK: Se actualizan la cantidad de articulos del almacen a enviar
                for (index,item) in Pedido.articulosorden.enumerated(){
                    self.db.collection("SexyRevolverData").document("Inventario").collection("Almacenes").document(Almacen).collection("Articulos").document(item).setData([
                        "Cantidad":  articulos[item] == nil ? Pedido.articulos[index]  : (Pedido.articulos[index] + articulos[item]!)
                    ]) { err in
                        if let err : Error = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                }
            }
            self.borrarPedidoEnEspera(id: Pedido.id)
        }
    }
    
    func borrarPedidoEnEspera(id : String){
        db.collection("Pedidos En Espera").document(id).updateData([
            "Activo": false
        ]){ err in
            if let err : Error = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                self.load()
            }
        }
    }
    
}
