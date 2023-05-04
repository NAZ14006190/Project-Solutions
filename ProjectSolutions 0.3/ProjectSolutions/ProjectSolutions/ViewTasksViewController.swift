//
//  ViewTasksViewController.swift
//  ProjectSolutions
//
//  Created by Mikhail Nazarov (Student) on 27/04/2023.
//

import UIKit

class ViewTasksViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var tasksPickerView: UIPickerView!
    @IBOutlet weak var editButton: UIButton!

    var projectId: Int
    var tasks: [Task] = []
    
    init(projectId: Int) {
        self.projectId = projectId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.projectId = 0
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksPickerView.dataSource = self
        tasksPickerView.delegate = self
        editButton.addTarget(self, action: #selector(viewEditButtonTapped), for: .touchUpInside)
        
        fetchTaskDetails(forProjectId: projectId)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tasks.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < tasks.count {
            return tasks[row].name
        } else {
            return ""
        }
    }
    
    @objc func viewEditButtonTapped() {
        // Implement this method to handle the tap event for the Edit button
    }

    func fetchTaskDetails(forProjectId projectId: Int) {
        let apiUrl = "http://127.0.0.1:5000/api/tasks/get/by_project_id/\(projectId)"
        print("API URL: \(apiUrl)")
        guard let url = URL(string: apiUrl) else { return }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                print("Error: Invalid response")
                return
            }

            guard let data = data else {
                print("Error: No data received")
                return
            }

            do {
                self.tasks = try JSONDecoder().decode([Task].self, from: data)
                print("Parsed tasks for project \(projectId): \(self.tasks)")
                DispatchQueue.main.async {
                    self.tasksPickerView.reloadAllComponents()
                }
            } catch {
                print("Error: \(error)")
            }
        }

        task.resume()
    }
}
