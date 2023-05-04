import Foundation
import UIKit

class ViewProjectsViewController: UIViewController {
    
    

        var projectsStackView: UIStackView!
        var currentUserId: Int

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

            projectsStackView = UIStackView()
            projectsStackView.translatesAutoresizingMaskIntoConstraints = false
            projectsStackView.axis = .vertical
            projectsStackView.spacing = 8

            view.addSubview(projectsStackView)

            NSLayoutConstraint.activate([
                projectsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
                projectsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
                projectsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
                projectsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            ])

            fetchProjectDetails(forUserId: UserData.shared.currentUser!.id)
            print("Current User ID: \(UserData.shared.currentUser!.id)")
        }
    
   
    func fetchProjectDetails(forUserId userId: Int) {
         let apiUrl = "http://127.0.0.1:5000/api/projects/get/by_user_id/\(userId)"
         print("API URL: \(apiUrl)") // Print the API URL
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
                 let projectDetails = try JSONDecoder().decode([Project].self, from: data)
                 print("Parsed projects for user \(userId): \(projectDetails)")
                 DispatchQueue.main.async {
                     self.addProjectViews(projects: projectDetails)
                 }
             } catch {
                 print("Error: \(error)")
             }
         }

         task.resume()
    

    }
    func addProjectViews(projects: [Project]) {
        for project in projects {
            let projectView = UIView()
            projectView.translatesAutoresizingMaskIntoConstraints = false
            projectView.backgroundColor = .systemGray6
            projectView.layer.cornerRadius = 8

            let textView = UITextView()
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.text = """
            Project Name: \(project.name)
            Start Date: \(project.start_date)
            End Date: \(project.end_date)
            Description: \(project.description)
            """
            textView.isEditable = false
            projectView.addSubview(textView)

            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("View/Edit", for: .normal)
            button.addTarget(self, action: #selector(viewEditButtonTapped(_:)), for: .touchUpInside)
            projectView.addSubview(button)

            NSLayoutConstraint.activate([
                textView.topAnchor.constraint(equalTo: projectView.topAnchor, constant: 8),
                textView.leadingAnchor.constraint(equalTo: projectView.leadingAnchor, constant: 8),
                textView.trailingAnchor.constraint(equalTo: projectView.trailingAnchor, constant: -8),

                button.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 8),
                button.leadingAnchor.constraint(equalTo: projectView.leadingAnchor, constant: 8),
                button.trailingAnchor.constraint(equalTo: projectView.trailingAnchor, constant: -8),
                button.bottomAnchor.constraint(equalTo: projectView.bottomAnchor, constant: -8),
            ])

            projectsStackView.addArrangedSubview(projectView)
        }
    }
    func createProjectView(project: Project) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8

        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = """
        Project Name: \(project.name)
        Start Date: \(project.start_date)
        End Date: \(project.end_date)
        Description: \(project.description)
        """
        textView.isEditable = false
        view.addSubview(textView)

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(viewEditButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            textView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -8),

            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            button.widthAnchor.constraint(equalToConstant: 80),
            button.heightAnchor.constraint(equalToConstant: 30)
        ])

        return view
    }

    @objc func viewEditButtonTapped(_ sender: UIButton) {
        // Implement the API call for getting the project by ID and navigate to the corresponding view controller
        print("View/Edit button tapped")
    }
}


/*struct ProjectData: Decodable {
    let name: String
    let start_date: String
    let end_date: String
    let description: String
} */
