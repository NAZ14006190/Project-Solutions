//
//  User.swift
//  ProjectSolutions
//
//  Created by Mikhail Nazarov (Student) on 26/04/2023.
//

import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let username: String
    let password: String
}
