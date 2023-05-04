//
//  MenuViewController.swift
//  ProjectSolutions
//
//  Created by Mikhail Nazarov (Student) on 19/04/2023.
//


import UIKit
class MenuViewController: UIViewController {
    
    @IBOutlet weak var numberOfProjects: UILabel!
    @IBOutlet weak var numberOfTasks: UILabel!
    
    @IBOutlet weak var editAccButton: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = UserData.shared.currentUser?.username
        self.title = "Welcome, \(name!)"
        
        fetchIncompleteProjects()
        fetchInProgressTasks()
        editAccButton.addTarget(self, action: #selector(editAccButtonTapped), for: .touchUpInside)
    }
    @objc func editAccButtonTapped() {
        self.performSegue(withIdentifier: "EditAccSegue", sender: self)
       }
    func updateStatusLabel(incompleteProjectsCount: Int) {
        if incompleteProjectsCount > 10 {
            statusLabel.text = "💪 You're very busy"
        } else if incompleteProjectsCount >= 5 {
            statusLabel.text = "✍️ You're kind of busy "
        } else {
            statusLabel.text = "😎 You're not so busy"
        }
    }
    func fetchIncompleteProjects() {
        let userId = UserData.shared.currentUser!.id
        let apiUrl = "http://127.0.0.1:5000/api/projects/get/by_user_id/\(userId)"
        
        guard let url = URL(string: apiUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("Error: No data received")
                return
            }
            
            do {
                let projects = try JSONDecoder().decode([Project].self, from: data)
                let incompleteProjects = projects.filter { !$0.isComplete }
                
                DispatchQueue.main.async {
                    self.numberOfProjects.text = "\(incompleteProjects.count)"
                    self.updateStatusLabel(incompleteProjectsCount: incompleteProjects.count)
                }
            } catch {
                print("Error: \(error)")
            }
        }.resume()
    }
    
    func fetchInProgressTasks() {
        let userId = UserData.shared.currentUser!.id
        let apiUrl = "http://127.0.0.1:5000/api/tasks/get/by_user_id/\(userId)"
        
        guard let url = URL(string: apiUrl) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("Error: No data received")
                return
            }
            
            do {
                let tasks = try JSONDecoder().decode([Task].self, from: data)
                let inProgressTasks = tasks.filter { $0.status == "In Progress" }
                
                DispatchQueue.main.async {
                    self.numberOfTasks.text = "\(inProgressTasks.count)"
                }
            } catch {
                print("Error: \(error)")
            }
        }.resume()
    }
}
