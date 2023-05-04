//
//  AddTaskViewController.swift
//  ProjectSolutions
//
//  Created by Mikhail Nazarov (Student) on 27/04/2023.
//

import UIKit

class AddTaskViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskDescView: UITextView!
    @IBOutlet var dueDatePicker: UIDatePicker!
    @IBOutlet weak var statusPicker: UIPickerView!

    @IBOutlet weak var errorTaskLabel: UILabel!

    var projectId: Int? // ? means optional
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
        print("Project ID in add new task: \(String(describing: projectId))")
    }

    @IBAction func addTaskButtonPressed(_ sender: UIButton) {
        guard let taskName = taskNameField.text,
              let taskDesc = taskDescView.text,
              let projectId = projectId else {
            return
        }
        
        let dueDate = dueDatePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dueDateString = dateFormatter.string(from: dueDate)
        let projectStatus = statusList[statusPicker.selectedRow(inComponent: 0)]
        
        let parameters: [String: Any] = [
            "name": taskName,
            "description": taskDesc,
            "due_date": dueDateString,
            "status": projectStatus,
            "project_id": projectId
        ]
        
        guard let url = URL(string: "http://127.0.0.1:5000/api/tasks/add") else {
            return
        }
      
    
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
                let addSuccess = json?["Add_Success"] as? Bool ?? false
                DispatchQueue.main.async {
                             if addSuccess {
                                 self.errorTaskLabel.text = "Success!"
                                 if let navigationController = self.navigationController,
                                    let homeVC = navigationController.viewControllers.first(where: { $0.restorationIdentifier == "EditProjectViewController" }) {
                                     navigationController.popToViewController(homeVC, animated: true)
                                 }
                             } else {
                                 self.errorTaskLabel.text = "Error!"
                             }
                         }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
