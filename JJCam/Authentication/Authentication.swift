//
//  Authentication.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 23/05/21.
//

import UIKit

class Authentication {
    private enum AuthenticationKeys: String {
        case actived = "actived"
        case password = "password"
        case time = "time"
    }
    
    public enum Times: Double, CaseIterable {
        case immediately = 0
        case thirtySeconds = 30
        case oneMinute = 60
        case threeMinutes = 180
        case fiveMinutes = 300
        case tenMinutes = 600
        case fifteenMinutes = 900
        
        func getFormattedName() -> String {
            switch self {
            case .immediately:
                return "Imediatamente"
            case .thirtySeconds:
                return "30 segundos"
            case .oneMinute:
                return "1 minuto"
            case .threeMinutes:
                return "3 minutos"
            case .fiveMinutes:
                return "5 minutos"
            case .tenMinutes:
                return "10 minutos"
            case .fifteenMinutes:
                return "15 minutos"
            }
        }
    }
    
    static let shared = Authentication()
    private var viewController: UIViewController?
    private var destination: UIViewController?
    private var completion: (() -> Void)?
    private var isUnlocked = false
    
    public var isActived: Bool {
        get {
            return UserDefaults.standard.bool(forKey: AuthenticationKeys.actived.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AuthenticationKeys.actived.rawValue)
        }
    }
    
    private var password: String {
        get {
            return UserDefaults.standard.string(forKey: AuthenticationKeys.password.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AuthenticationKeys.password.rawValue)
        }
    }
    
    private var time: Double {
        get {
            UserDefaults.standard.double(forKey: AuthenticationKeys.time.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AuthenticationKeys.time.rawValue)
        }
    }
    
    public func goToAuthenticationIfNeeded(viewController: UIViewController, destination: UIViewController? = nil, force: Bool = false, completion: (()-> Void)? = nil) {
        if isActived && (!isUnlocked || force) {
            guard let segue = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "AuthenticationViewController") as? AuthenticationViewController else { return }
            segue.flow = .authentication
            segue.delegate = self
            self.completion = completion
            self.viewController = viewController
            self.destination = destination
            
            viewController.present(segue, animated: true, completion: nil)
        } else {
            completion?()
            guard let destination = destination else { return }
            viewController.present(destination, animated: true, completion: nil)
        }
    }
    
    private func continueDestination() {
        guard let viewController = viewController, let destination = destination else { return }
        
        viewController.view.isHidden = true
        viewController.tabBarController?.tabBar.isHidden = true
        viewController.dismiss(animated: true) {
            viewController.present(destination, animated: true) {
                viewController.view.isHidden = false
                viewController.tabBarController?.tabBar.isHidden = false
            }
        }
    }
    
    public func validate(_ password: String) -> Bool {
        return self.password == password
    }
    
    public func validateAndSave(_ password: String) -> Bool {
        isActived = true
        self.password = password
        return true
    }
    
    public func disabled() {
        isActived = false
        password = ""
    }
    
    public func getCurrentTime() -> Times {
        return Times(rawValue: time) ?? Times.immediately
    }
    
    public func setNextTime() -> Times {
        let newTime = Times(rawValue: time)?.next()
        time = newTime?.rawValue ?? 0
        return newTime ?? .immediately
    }
}

extension Authentication: AuthenticationViewControllerDelegate {
    func didSuccessInAuthentication() {
        continueDestination()
        completion?()
        isUnlocked = true
        UIView.delay(seconds: time) {
            self.isUnlocked = false
        }
    }
    
    func didErrorInAuthentication() {
        
    }
}
