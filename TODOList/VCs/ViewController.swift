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
    
    var navigationTitle = "My To Do"
    var parentTask: Task?
    var subtasks: [Task] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if parentTask == nil {
            _tasks.filter = { $0.parentTask == nil }
        }
        navigationController?.navigationBar.setNeedsLayout()
        navigationItem.title = parentTask != nil ? parentTask?.title : "My To Do"
        tableView.translatesAutoresizingMaskIntoConstraints = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addNewTask))
        
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
        if parentTask != nil {
            print(subtasks.count)
            return subtasks.count
        }
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellId", for: indexPath) as! TaskTableViewCell
        if parentTask != nil {
            cell.config(from: subtasks[indexPath.row])
        } else {
            cell.config(from: tasks[indexPath.row])
        }
        cell.callback = { [weak self, tableView] string in
            if let self {
                self.tasks[indexPath.row].note = string
                tableView.performBatchUpdates(nil)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CoreDataService.shared.write {
                if parentTask != nil {
                    
                    parentTask?.removeFromSubtasks(subtasks[indexPath.row])
                    CoreDataService.shared.delete(subtasks[indexPath.row])
                    subtasks.remove(at: indexPath.row)
                } else {
                    CoreDataService.shared.delete(tasks[indexPath.row])
                }
            }
            print(tasks)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toDoListVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        if parentTask != nil {
            toDoListVC.parentTask = subtasks[indexPath.row]
            toDoListVC.subtasks = subtasks[indexPath.row].subtasks?.allObjects as? [Task] ?? []
        } else {
            toDoListVC.parentTask = tasks[indexPath.row]
            toDoListVC.subtasks = tasks[indexPath.row].subtasks?.allObjects as? [Task] ?? []
        }
        navigationController?.pushViewController(toDoListVC, animated: true)
    }
    
    
}

extension ViewController: AddTaskDelegate {
    func saveNew(
        title: String,
        note: String?,
        dateOfCreation: Date
    ) {
        CoreDataService.shared.write {
            let task = CoreDataService.shared.create(Task.self) { [parentTask] task in
                task.title = title
                task.note = note
                task.dateOfCreation = dateOfCreation
                task.done = false
                if parentTask != nil {
                    task.parentTask = parentTask
                    parentTask?.addToSubtasks(task)
                }
            }
            subtasks.append(task)
        }
        tableView.insertRows(
            at: [IndexPath(row: parentTask == nil ? tasks.count - 1 : subtasks.count - 1, section: 0)],
            with: .automatic
        )
    }
    

    
    func reloadData() {
        DispatchQueue.main.async { [tableView] in
            tableView?.reloadData()
        }
    }
    
}



