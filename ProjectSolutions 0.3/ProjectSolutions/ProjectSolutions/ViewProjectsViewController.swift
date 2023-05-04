import UIKit

class ViewProjectsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var projectsPickerView: UIPickerView!
    @IBOutlet weak var editButton: UIButton!

    var currentUserId: Int
    var projects: [Project] = []
    
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

    func getProjectById(_ projectId: Int, completion: @escaping (Project?) -> Void) {
        let apiUrl = "http://127.0.0.1:5000/api/projects/get/byid/\(projectId)"
        print ("API URL: \(apiUrl)")
        guard let url = URL(string: apiUrl) else { return }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                print("Error: Invalid response")
                completion(nil)
                return
            }

            guard let data = data else {
                print("Error: No data received")
                completion(nil)
                return
            }

            do {
                let project = try JSONDecoder().decode(Project.self, from: data)
                completion(project)
            } catch {
                print("Error: \(error)")
                completion(nil)
            }
        }

        task.resume()
    }

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
