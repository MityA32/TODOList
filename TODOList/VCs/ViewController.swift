//
//  ViewController.swift
//  TODOList
//
//  Created by Dmytro Hetman on 22.11.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    @Fetch<Task> var tasks
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = view.frame.height * 0.15
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addNewTask))
        print(tasks)
        
    }

    @objc
    private func addNewTask() {
        performSegue(withIdentifier: "addNewTask", sender: nil)
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewTask",
           let destination = segue.destination as? AddTaskViewController {
            destination.delegate = self
            destination.modalPresentationStyle = .pageSheet
            if let sheet = destination.sheetPresentationController {
                sheet.detents = [.medium()]
            }
        }
        

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellId", for: indexPath) as! TaskTableViewCell
        cell.config(from: tasks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CoreDataService.shared.write {
                CoreDataService.shared.delete(tasks[indexPath.row])
            }
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
    
}

extension ViewController: AddTaskDelegate {
    
    func reloadData() {
        DispatchQueue.main.async { [tableView] in
            tableView?.reloadData()
        }
    }
    
}



