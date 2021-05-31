//
//  HelpViewController.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 02/05/21.
//

import UIKit

class HelpViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var data = [["Como adicionar um dispositivo?", ""]]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "HelpTableViewCell", bundle: nil), forCellReuseIdentifier: "HelpTableViewCell")
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - Table View Data Source
extension HelpViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HelpTableViewCell", for: indexPath) as? HelpTableViewCell else { return UITableViewCell() }
        cell.question.text = data[indexPath.row][0]
        cell.answer.text = data[indexPath.row][1]
        return cell
    }
}

// MARK: - Table View Delegate
extension HelpViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        data[0][1] = data[0][1].isEmpty ? "Há duas opções, você pode adicionar via interface web em qualquer celular, tablet ou computador que esteja na mesma rede local ou ainda adicionar na própria Apple TV clicando no botão \"Adicionar pela Apple TV\"" : ""
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if context.previouslyFocusedIndexPath != nil {
            guard let oldCell = tableView.cellForRow(at: context.previouslyFocusedIndexPath!) as? HelpTableViewCell else { return }
            oldCell.question.textColor = UIColor.white
            oldCell.answer.textColor = UIColor.white
        }
        if context.nextFocusedIndexPath != nil {
            guard let newCell = tableView.cellForRow(at: context.nextFocusedIndexPath!) as? HelpTableViewCell else { return }
            newCell.question.textColor = UIColor.black
            newCell.answer.textColor = UIColor.black
        }
    }
}
