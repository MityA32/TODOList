//
//  AddTaskDelegate.swift
//  TODOList
//
//  Created by Dmytro Hetman on 01.12.2022.
//

import Foundation

protocol AddTaskDelegate: AnyObject {
    func saveNew(title: String, note: String?, dateOfCreation: Date)
    func reloadData()
}
