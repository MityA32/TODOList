//
//  Task.swift
//  TODOList
//
//  Created by Dmytro Hetman on 01.12.2022.
//

import Foundation

struct TaskFromNotification: Codable {
    let title: String
    let note: String
    let dateOfCreation: String
}
