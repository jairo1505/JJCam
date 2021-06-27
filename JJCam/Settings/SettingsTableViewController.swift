//
//  SettingsTableViewController.swift
//  testSwifter
//
//  Created by Jairo Pereira Junior on 15/02/21.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    let settings = ["Remover todos os dispositivos", "Senha", "Ajuda", "Sobre"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsTableViewCell")
        tableView.rowHeight = 80
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as? SettingsTableViewCell else { return UITableViewCell() }
        cell.title.text = settings[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let alert = UIAlertController(title: "Tem certeza que quer remover todos os dispositivos?", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Remover", style: .destructive, handler: { _ in
                Authentication.shared.goToAuthenticationIfNeeded(viewController: self) {
                    DeviceManager.shared.removeAll()
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        case 1:
            guard let segue = UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(identifier: "SettingsAuthenticationViewController") as? SettingsAuthenticationViewController else { return }
            Authentication.shared.goToAuthenticationIfNeeded(viewController: self, destination: segue, force: true)
        case 2:
            guard let segue = UIStoryboard(name: "Help", bundle: nil).instantiateInitialViewController() else { return }
            self.present(segue, animated: true, completion: nil)
        case 3:
            guard let segue = UIStoryboard(name: "About", bundle: nil).instantiateInitialViewController() else { return }
            self.present(segue, animated: true, completion: nil)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.previouslyFocusedIndexPath != nil {
            guard let oldCell = tableView.cellForRow(at: context.previouslyFocusedIndexPath!) as? SettingsTableViewCell else { return }
            oldCell.title.textColor = UIColor.white
        }
        if context.nextFocusedIndexPath != nil {
            guard let newCell = tableView.cellForRow(at: context.nextFocusedIndexPath!) as? SettingsTableViewCell else { return }
            newCell.title.textColor = UIColor.black
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Versão 1.0"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footer = view as? UITableViewHeaderFooterView else { return }
        footer.textLabel?.textAlignment = .center
    }
}
