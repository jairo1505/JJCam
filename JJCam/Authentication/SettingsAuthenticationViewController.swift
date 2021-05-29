//
//  SettingsAuthenticationViewController.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 23/05/21.
//

import UIKit

class SettingsAuthenticationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let menu = ["Desativar", "Modificar Senha", "Bloquear", "Pedir a senha ao abrir o aplicativo"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsTableViewCell")
        tableView.rowHeight = 80
        tableView.dataSource = self
        tableView.delegate = self
    }

}

// MARK: - Table View Data Source

extension SettingsAuthenticationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Authentication.shared.isActived ? menu.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as? SettingsTableViewCell else { return UITableViewCell() }
        if indexPath.row == 2 {
            let currentTime = Authentication.shared.getCurrentTime()
            cell.title.text = "\(menu[indexPath.row]) \(currentTime == .immediately ? "" : "em ")\(currentTime.getFormattedName())"
        } else {
            cell.title.text = Authentication.shared.isActived ? menu[indexPath.row] : "Ativar"
        }
        return cell
    }
}

// MARK: - Table View Delegate

extension SettingsAuthenticationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !Authentication.shared.isActived {
            guard let segue = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "AuthenticationViewController") as? AuthenticationViewController else { return }
            segue.flow = .newPassword
            segue.delegate = self
            self.present(segue, animated: true, completion: nil)
        } else {
            switch indexPath.row {
            case 0:
                Authentication.shared.disabled()
                tableView.reloadData()
            case 1:
                guard let segue = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "AuthenticationViewController") as? AuthenticationViewController else { return }
                segue.flow = .newPassword
                segue.delegate = self
                self.present(segue, animated: true, completion: nil)
            case 2:
                guard let cell = tableView.cellForRow(at: indexPath) as? SettingsTableViewCell else { return }
                let currentTime = Authentication.shared.setNextTime()
                cell.title.text = "\(menu[indexPath.row]) \(currentTime == .immediately ? "" : "em ")\(currentTime.getFormattedName())"
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Ao ativar a senha, todas as modificações nos dispositivos serão protegidas por senha."
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footer = view as? UITableViewHeaderFooterView else { return }
        footer.textLabel?.textAlignment = .center
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.previouslyFocusedIndexPath != nil {
            guard let oldCell = tableView.cellForRow(at: context.previouslyFocusedIndexPath!) as? SettingsTableViewCell else { return }
            oldCell.title.textColor = UIColor.white
        }
        if context.nextFocusedIndexPath != nil {
            guard let newCell = tableView.cellForRow(at: context.nextFocusedIndexPath!) as? SettingsTableViewCell else { return }
            newCell.title.textColor = UIColor.black
        }
    }
}

extension SettingsAuthenticationViewController: AuthenticationViewControllerDelegate {
    func didSuccessInAuthentication() {
        self.dismiss(animated: true, completion: nil)
        tableView.reloadData()
    }
    
    func didErrorInAuthentication() {
        
    }
}
