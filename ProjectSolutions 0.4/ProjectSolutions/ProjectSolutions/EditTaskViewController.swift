//
//  EditTaskViewController.swift
//  ProjectSolutions
//
//  Created by Mikhail Nazarov (Student) on 28/04/2023.
//


import UIKit

class EditTaskViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var taskNameField: UITextField!
    
    @IBOutlet weak var statusPicker: UIPickerView!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var taskDescView: UITextView!
    

    var projectId: Int?
    var task: Task?
    let statusList = ["In Progress", "Not Started", "Suspended", "Completed"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statusList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statusList[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusPicker.delegate = self
        statusPicker.dataSource = self
        
        if let task = task {
            taskNameField.text = task.name
            taskDescView.text = task.description
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let dueDate = dateFormatter.date(from: task.due_date) {
                dueDatePicker.date = dueDate
            }
            
            if let statusIndex = statusList.firstIndex(of: task.status) {
                statusPicker.selectRow(statusIndex, inComponent: 0, animated: false)
            }
        }
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc func saveButtonTapped() {
        guard let task = task,
              let taskName = taskNameField.text,
              let taskDesc = taskDescView.text,
              let projectId = projectId else {
            return
        }
        
        let dueDate = dueDatePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dueDateString = dateFormatter.string(from: dueDate)
        let taskStatus = statusList[statusPicker.selectedRow(inComponent: 0)]
        
        let parameters: [String: Any] = [
            "id": task.id,
            "name": taskName,
            "description": taskDesc,
            "due_date": dueDateString,
            "status": taskStatus,
            "project_id": projectId
        ]
        
        guard let url = URL(string: "http://127.0.0.1:5000/api/tasks/update/\(task.id)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
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
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let updateSuccess = json?["Update_Success"] as? Bool ?? false
                
                DispatchQueue.main.async {
                    if updateSuccess {
                        if let navigationController = self.navigationController,
                           let viewTasksVC = navigationController.viewControllers.first(where: { $0 is ViewTasksViewController }) {
                            navigationController.popToViewController(viewTasksVC, animated: true)
                        }
                    } else {
                        
                    }
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
