//
//  FirebaseMethods.swift
//  Inventario
//
//  Created by Luis Isaac Maya on 12/14/18.
//  Copyright © 2018 Luis Isaac Maya. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SVProgressHUD

let db = Firestore.firestore()
let user = (String(Auth.auth().currentUser!.email!))

class FuncionesFirebase{
    
    
    //MARK: Guardar en Firebase
    func save(Collection : String, Document : String, Data : [String : Any]) -> Bool{
        var save = false
        db.collection(user).document("Inventario").collection(Collection).document(Document).setData(Data)
        { err in
            if let err = err {
                print("Error writing document: \(err)")
                save = false
            } else {
                print("Document successfully written!")
                save = true
            }
        }
        return save
    }
    
    //MARK: Cargar informacion de Firebase
    func load(Collection: String) -> ([String],[NSDictionary]) {
        var items = [String]()
        var itemInfo = [NSDictionary]()
        db.collection(user).document("Inventario").collection(Collection).getDocuments { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in QuerySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    items.append(document.documentID)
                    itemInfo.append(document.data() as NSDictionary)
                    print(items)
                }
            }
        }
        SVProgressHUD.dismiss()
        return (items, itemInfo)
    }
    
    
    //MARK: Borrar informacion de firebase
    
    func delete(Where : String, Document : String) -> Bool {
        var delete = false
        db.collection(user).document("Inventario").collection(Where).document(Document).delete { (err) in
            if let err = err {
                print("Error removing document: \(err)")
                delete = false
            } else {
                print("Document successfully removed!")
                delete = true
            }
        }
        return delete
    }
    
    
    
    
    
}
