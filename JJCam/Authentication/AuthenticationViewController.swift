//
//  AuthenticationViewController.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 23/05/21.
//

import UIKit

protocol AuthenticationViewControllerDelegate {
    func didSuccessInAuthentication()
    func didErrorInAuthentication()
}

class AuthenticationViewController: UIViewController {
    enum AuthenticationFlow {
        case newPassword
        case authentication
    }
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var labelTop: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var labelBotton: UILabel!
    
    var delegate: AuthenticationViewControllerDelegate?
    var flow: AuthenticationFlow? = .authentication
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        password.delegate = self
        navigationBar.topItem?.title = getTitle()
    }
    
    private func validatePassword(_ password: String) -> Bool {
        switch flow {
        case .authentication:
            return Authentication.shared.validate(password)
        case .newPassword:
            return Authentication.shared.validateAndSave(password)
        default:
            return false
        }
    }
    
    private func getTitle() -> String {
        switch flow {
        case .authentication:
            return "Autenticação"
        case .newPassword:
            return "Nova senha"
        default:
            return "Autenticação"
        }
    }
}

extension AuthenticationViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !(password.text?.isEmpty ?? true) {
            if validatePassword(password.text ?? "") {
                delegate?.didSuccessInAuthentication()
            } else {
                labelBotton.text = flow == .authentication ? "Senha incorreta!" : "Senha inválida!"
            }
        } else {
            labelBotton.text = "Digite uma senha!"
        }
    }
}
