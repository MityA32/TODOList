//
//  TaskTableViewCell.swift
//  TODOList
//
//  Created by Dmytro Hetman on 22.11.2022.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var date: UILabel!
    @IBOutlet private weak var done: UIButton!
    
    var isDone = false
    var task: Task?
    
    @IBAction func done(_ sender: Any) {
        CoreDataService.shared.write {
            self.task?.done.toggle()
        }
        done.setImage(UIImage(systemName: self.task?.done ?? false ? "circle.fill" : "circle") , for: .normal)
    }
    
    var placeholder = "Add Note"
    
    
    func config(from task: Task) {
        self.task = task
        textView.delegate = self
        title.text = task.title
        textView.text = task.note
        if task.note == "Add Note" {
            textView.textColor = .lightGray
        } else {
            textView.textColor = .black
        }
        
        date.text = "\(task.dateOfCreation?.getFormattedDate() ?? "Date()")"
        done.setImage(UIImage(systemName: task.done ? "circle.fill" : "circle"), for: .normal)
    }

}

extension Date {
   func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: self)
    }
}

extension TaskTableViewCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Add Note"
            textView.textColor = .lightGray
            placeholder = ""
        } else {
            placeholder = textView.text
            CoreDataService.shared.write {
                task?.note = placeholder
            }
        }
        resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholder = textView.text
    }
    
    
    
    
}
