//
//  ViewTasksViewController.swift
//  ProjectSolutions
//
//  Created by Mikhail Nazarov (Student) on 27/04/2023.
//

import UIKit

class ViewTasksViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var tasksPickerView: UIPickerView!
    @IBOutlet weak var editTaskButton: UIButton!

   // @IBOutlet weak var newTaskButton: UIButton!
    
    //var projectId: Int
    var tasks: [Task] = []
    
    /*
     init(projectId: Int) {
        self.projectId = projectId
        super.init(nibName: nil, bundle: nil)
    }
     */
    var projectId: Int {
        didSet {
            print("Project ID is set: \(projectId)")
            fetchTaskDetails(forProjectId: projectId)
        }
    }


    required init?(coder: NSCoder) {
        self.projectId = 0
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Project ID: \(String(describing: projectId))")
        tasksPickerView.dataSource = self
        tasksPickerView.delegate = self
        
        editTaskButton.addTarget(self, action: #selector(editTaskButtonTapped), for: .touchUpInside)
        
        fetchTaskDetails(forProjectId: projectId)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddTask", let addTaskVC = segue.destination as? AddTaskViewController {
            addTaskVC.projectId = projectId
        }
    }

    @objc func editTaskButtonTapped() {
        let selectedIndex = tasksPickerView.selectedRow(inComponent: 0)
        let selectedTask = tasks[selectedIndex]
        print("Edit button tapped for task: \(selectedTask.name)")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editTaskViewController = storyboard.instantiateViewController(withIdentifier: "EditTaskViewController") as? EditTaskViewController {
            editTaskViewController.projectId = projectId
            editTaskViewController.task = selectedTask
            navigationController?.pushViewController(editTaskViewController, animated: true)
        }
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
