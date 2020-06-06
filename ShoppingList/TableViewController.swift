//
//  TableViewController.swift
//  ShoppingList
//
//  Created by Usuário Convidado on 25/08/2018.
//  Copyright © 2018 FIAP. All rights reserved.
//

import UIKit
import Firebase

class TableViewController: UITableViewController {

    let collection = "shoppingList"
    let firestore: Firestore = {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        let firestore = Firestore.firestore()
        firestore.settings = settings
        return firestore
    }()
    var firestoreListener: ListenerRegistration!
    var shoppingList: [ShoppingItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Auth.auth().currentUser?.displayName
        loadItems()
    }
    
    private func loadItems() {
        firestoreListener = firestore
                            .collection(collection)
                            .order(by: "name", descending: false)
                            .addSnapshotListener(includeMetadataChanges: true, listener: { (snapshot, error) in
                
                                if error != nil {
                                    print(error!)
                                    return
                                }

                                guard let snapshot = snapshot else {return}
                                print("Documentos alterados:", snapshot.documentChanges.count)
                                
                                if snapshot.metadata.isFromCache || snapshot.documentChanges.count > 0 {
                                    self.showItems(snapshot: snapshot)
                                }
                                
                            })
    }
    
    func showItems(snapshot: QuerySnapshot) {
        shoppingList.removeAll()
        for document in snapshot.documents {
            let id = document.documentID
            let data = document.data()
            let name = (data["name"] as? String) ?? ""
            let quantity = (data["quantity"] as? Int) ?? 0
            let shoppingItem = ShoppingItem(name: name, quantity: quantity, id: id)
            shoppingList.append(shoppingItem)
        }
        tableView.reloadData()
    }
    
    func showAlertForItem(_ item: ShoppingItem?) {
        let alert = UIAlertController(title: "Produto", message: "Entre com as informações do produto abaixo", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Nome"
            textField.text = item?.name
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Quantidade"
            textField.text = "\(item?.quantity ?? 1)"
            textField.keyboardType = .numberPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            guard let name = alert.textFields?.first?.text,
                let quantity = alert.textFields?.last?.text else {return}
            
            let data: [String: Any] = [
                "name": name,
                "quantity": Int(quantity) ?? 0
            ]
            
            if let item = item {
                //Edição
                self.firestore.collection(self.collection).document(item.id).updateData(data)
            } else {
                //Criação
                self.firestore.collection(self.collection).addDocument(data: data)
            }
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addItem(_ sender: Any) {
        showAlertForItem(nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let shoppingItem = shoppingList[indexPath.row]
        cell.textLabel?.text = shoppingItem.name
        cell.detailTextLabel?.text = "\(shoppingItem.quantity)"
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let shoppingItem = shoppingList[indexPath.row]
            firestore.collection(collection).document(shoppingItem.id).delete()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shoppingItem = shoppingList[indexPath.row]
        showAlertForItem(shoppingItem)
    }
    
}
