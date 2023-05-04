//
//  AddTaskViewController.swift
//  ProjectSolutions
//
//  Created by Mikhail Nazarov (Student) on 27/04/2023.
//

import UIKit

class AddTaskViewController: UIViewController {

    @IBOutlet weak var taskNameField: UITextField!
    @IBOutlet weak var taskDescView: UITextView!
    @IBOutlet var dueDatePicker: UIDatePicker!
    @IBOutlet weak var isCompleteSwitch: UISwitch!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var errorTaskLabel: UILabel!

    var projectId: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
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

        let isComplete = isCompleteSwitch.isOn ? 1 : 0

        let imageData = imageView.image?.jpegData(compressionQuality: 1.0)
        let base64Image = imageData?.base64EncodedString(options: .lineLength64Characters)

        let parameters: [String: Any] = [
            "name": taskName,
            "description": taskDesc,
            "due_date": dueDateString,
            "status": isComplete,
            "project_id": projectId,
            "image": base64Image ?? ""
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
                        // Handle successful task addition, e.g., navigate to another view
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
