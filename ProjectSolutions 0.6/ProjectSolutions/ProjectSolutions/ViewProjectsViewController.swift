import UIKit

class ViewProjectsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var projectsPickerView: UIPickerView!
    @IBOutlet weak var editButton: UIButton!

    var currentUserId: Int
    var projects: [Project] = []
    // The currentUserId is set when the view controller is initialized, and is uses to fetch the projects for the current user
    init(currentUserId: Int) {
        self.currentUserId = currentUserId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.currentUserId = 0
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        projectsPickerView.dataSource = self
        projectsPickerView.delegate = self
        editButton.addTarget(self, action: #selector(viewEditButtonTapped), for: .touchUpInside)
        
        fetchProjectDetails(forUserId: UserData.shared.currentUser!.id)
    }
    // The numberOfComponents and numberOfRowsInComponent methods are required by the UIPickerViewDataSource protocol, and are used to determine the number of components and rows in the picker view.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return projects.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < projects.count {
            return projects[row].name
        } else {
            return ""
        }
    }
    
    @objc func viewEditButtonTapped() {
           let selectedIndex = projectsPickerView.selectedRow(inComponent: 0)
           let selectedProject = projects[selectedIndex]
           print("View/Edit button tapped for project: \(selectedProject.name)")
           
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           if let editProjectViewController = storyboard.instantiateViewController(withIdentifier: "EditProjectViewController") as? EditProjectViewController {
               editProjectViewController.project = selectedProject
               navigationController?.pushViewController(editProjectViewController, animated: true)
           }
       }

    
    // Fetch project details from the server for the given user ID
    func fetchProjectDetails(forUserId userId: Int) {
        let apiUrl = "http://127.0.0.1:5000/api/projects/get/by_user_id/\(userId)"
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
                self.projects = try JSONDecoder().decode([Project].self, from: data)
                print("Parsed projects for user \(userId): \(self.projects)")
                DispatchQueue.main.async {
                    self.projectsPickerView.reloadAllComponents()
                }
            } catch {
                print("Error: \(error)")
            }
        }

        task.resume()
    }
}