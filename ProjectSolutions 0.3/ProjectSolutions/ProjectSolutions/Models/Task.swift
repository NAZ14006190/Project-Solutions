//
//  Task.swift
//  ProjectSolutions
//
//  Created by Mikhail Nazarov (Student) on 26/04/2023.
//


import Foundation

struct Task: Codable, Identifiable {
    let id : Int
    let name : String
    let description: String
    let due_date : String
    let status : String
    let project_id: Int
}
