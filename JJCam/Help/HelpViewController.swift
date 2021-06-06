//
//  HelpViewController.swift
//  JJCam
//
//  Created by Jairo Pereira Junior on 02/05/21.
//

import UIKit

class HelpViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var helpQuestions = [Help(question: "", answer: "")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "HelpTableViewCell", bundle: nil), forCellReuseIdentifier: "HelpTableViewCell")
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        
        getQuestions()
    }
    
    private func getQuestions() {
        if let url = Bundle.main.url(forResource: "Questions", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                helpQuestions = try JSONDecoder().decode([Help].self, from: data)
                tableView.reloadData()
            } catch {
                
            }
        }
    }
}

// MARK: - Table View Data Source
extension HelpViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpQuestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HelpTableViewCell", for: indexPath) as? HelpTableViewCell else { return UITableViewCell() }
        let item = helpQuestions[indexPath.row]
        cell.question.text = item.question
        cell.answer.text = item.show ?? false ? item.answer : ""
        return cell
    }
}

// MARK: - Table View Delegate
extension HelpViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexPaths = [indexPath]
        for i in 0...helpQuestions.count-1 where i != indexPath.row {
            helpQuestions[i].show = false
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        helpQuestions[indexPath.row].show = helpQuestions[indexPath.row].show ?? false ? false : true
        tableView.reloadRows(at: indexPaths, with: .fade)
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

extension HelpViewController {
    struct Help: Codable {
        let question: String?
        let answer: String?
        var show: Bool?
    }
}
