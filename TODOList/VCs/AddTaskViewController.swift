//
//  AddTaskViewController.swift
//  TODOList
//
//  Created by Dmytro Hetman on 22.11.2022.
//

import UIKit

class AddTaskViewController: UIViewController {

    weak var delegate: AddTaskDelegate?
    var placeholder = ""
    
    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var titleTextView: UITextView!
    @IBOutlet private weak var noteTextView: UITextView!
    
    @IBOutlet private weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextView(for: titleTextView, initialText: "Add title")
        configureTextView(for: noteTextView, initialText: "Add Note")
        configureNavigationBar()
    }
    
    func configureTextView(for textView: UITextView, initialText: String) {
        textView.delegate = self
        textView.textColor = .lightGray
        textView.text = initialText
    }
    
    
    
    func configureNavigationBar() {
        
        navigationItem.title = "Add Task"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        navigationBar.setItems([navigationItem], animated: true)
    }

    @objc
    private func save() {
        if titleTextView.text == "" || titleTextView.textColor == .lightGray {
            showAlert()
            return
        }
        CoreDataService.shared.write {
            CoreDataService.shared.create(Task.self) { [titleTextView, noteTextView] task in
                task.title = titleTextView?.text
                task.note = noteTextView?.text
                task.dateOfCreation = Date.now
                task.done = false
            }
        }
        delegate?.reloadData()
        dismiss(animated: true)
    }
    
    
    
    func showAlert() {
        let addTaskAlert = UIAlertController(title: "Alert", message: "The title is mandatory", preferredStyle: .alert)
        addTaskAlert.addAction(.init(title: "OK", style: .default))
        show(addTaskAlert, sender: nil)
    }
    
    
    @objc
    private func cancel() {
        dismiss(animated: true)
    }
    
}

extension AddTaskViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.textColor == .lightGray {
            if textView == titleTextView {
                textView.text = "Add Title"
            } else {
                textView.text = "Add Note"
            }
            textView.textColor = UIColor.lightGray
            placeholder = ""
        } else {
            placeholder = textView.text
        }
        resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholder = textView.text
    }
    
}



    


protocol AddTaskDelegate: AnyObject {
    func reloadData()
}


