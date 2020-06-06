//
//  ViewController.swift
//  ShoppingList
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfName: UITextField!
    
    lazy var auth = Auth.auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func login(_ sender: UIButton) {
        auth.signIn(withEmail: tfEmail.text!, password: tfPassword.text!) { [weak self] (result, error) in
            guard let self = self else {return}
            if let error = error {
                print(error)
            } else {
                print("Usuário logado com sucesso!!!")
                self.updateUserAndProceed()
            }
        }
    }
    
    @IBAction func signup(_ sender: UIButton) {
        auth.createUser(withEmail: tfEmail.text!, password: tfPassword.text!) { [weak self] (result, error) in
            guard let self = self else {return}
            if let error = error {
                print(error)
            } else {
                print("Conta criada com sucesso!!")
                self.updateUserAndProceed()
            }
            
        }
    }
    
    func updateUserAndProceed() {
        if tfName.text!.isEmpty {
            showMainScreen()
        } else {
            guard let user = auth.currentUser else {return}
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = tfName.text!
            changeRequest.commitChanges { [weak self] (error) in
                guard let self = self else {return}
                self.showMainScreen()
            }
        }
    }
    
    func showMainScreen() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "TableViewController") else {return}
        navigationController?.show(vc, sender: nil)
    }
}

