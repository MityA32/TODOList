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
    var navigationTitle = ""
    
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
        textView.layer.cornerRadius = 20
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
        delegate?.saveNew(title: titleTextView.text, note: noteTextView.text, dateOfCreation: Date.now)
        
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
            textView.textColor = .label
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
    func saveNew(title: String, note: String?, dateOfCreation: Date)
    func reloadData()
}


