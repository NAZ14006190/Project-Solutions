//
//  EditProjectViewController.swift
//  ProjectSolutions
//
//  Created by Mikhail Nazarov (Student) on 27/04/2023.
//
import UIKit

class EditProjectViewController: UIViewController {
    
    var project: Project?
    var projectId: Int?
    
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var projectDescriptionTextView: UITextView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var isCompleteSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var deleteProjectButton: UIButton!
    @IBOutlet weak var viewTasksButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up the UI with the project details if there is a project to edit
        if let project = project {
            projectNameTextField.text = project.name
            projectDescriptionTextView.text = project.description // Add this line
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            if let startDate = dateFormatter.date(from: project.start_date) {
                startDatePicker.date = startDate
            }
            
            if let endDate = dateFormatter.date(from: project.end_date) {
                endDatePicker.date = endDate
            }
            
            isCompleteSwitch.isOn = project.isComplete
        }
        // Set up button actions
        viewTasksButton.addTarget(self, action: #selector(viewTasksButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        deleteProjectButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    @objc func deleteButtonTapped() {
            guard let project = project else { return }
            deleteProject(withId: project.id)
        }
    // Function to delete a project from the server
    func deleteProject(withId projectId: Int) {
        let apiUrl = "http://127.0.0.1:5000/api/projects/delete/\(projectId)"
        print("API URL: \(apiUrl)")
        
        guard let url = URL(string: apiUrl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                print("Error: Invalid response")
                return
            }
            
            DispatchQueue.main.async {
                if let navigationController = self.navigationController {
                    if let homeVCIndex = navigationController.viewControllers.firstIndex(where: { $0.restorationIdentifier == "HomeVC" }) {
                        navigationController.popToViewController(navigationController.viewControllers[homeVCIndex], animated: true)
                    } else {
                        navigationController.popViewController(animated: true)
                    }
                }
            }
        }
        task.resume()
    }

    
    // Function to handle the save button press
    @objc func saveButtonTapped() {
        guard let project = project else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let updatedProject: [String: Any] = [
            "id": project.id,
            "name": projectNameTextField.text ?? "",
            "description": projectDescriptionTextView.text,
            "start_date": dateFormatter.string(from: startDatePicker.date),
            "end_date": dateFormatter.string(from: endDatePicker.date),
            "user_id": project.user_id,
            "isComplete": isCompleteSwitch.isOn ? 1 : 0
        ]
        saveUpdatedProject(updatedProject)
        DispatchQueue.main.async {
            if let navigationController = self.navigationController,
               let homeVC = navigationController.viewControllers.first(where: { $0.restorationIdentifier == "HomeVC" }) {
                navigationController.popToViewController(homeVC, animated: true)
            }
        }
    }
    // Function to handle the view tasks button press
    @objc func viewTasksButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewTasksVC = storyboard.instantiateViewController(withIdentifier: "ViewTasksViewController") as? ViewTasksViewController {
            if let projectId = project?.id {
                viewTasksVC.projectId = projectId
                self.navigationController?.pushViewController(viewTasksVC, animated: true)
            }
        }
    }
    
    func saveUpdatedProject(_ project: [String: Any]) {
        let projectId = project["id"] as! Int
        let apiUrl = "http://127.0.0.1:5000/api/projects/update/\(projectId)"
        print("API URL: \(apiUrl)")
        
        guard let url = URL(string: apiUrl) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: project, options: [])
        } catch {
            print("Error: Could not serialize project data")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
                        let result = try JSONDecoder().decode([String: Bool].self, from: data)
                        if let success = result["Update_Success"], success {
                            print("Successfully updated project")
                     
                        } else {
                            print("Failed to update project")
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                }
                task.resume()
            }
}
