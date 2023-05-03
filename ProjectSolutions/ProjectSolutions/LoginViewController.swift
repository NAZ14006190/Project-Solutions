import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var not: UILabel!
    // viewDidLoad method is called when view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // Function to be called when login button is pressed
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        var loggedIn = false
        // Retrieve the username and password from the text fields
        guard let username = usernameTextField.text,
              let password = passwordTextField.text else {
            return
        }
        // Create a dictionary of parameters
        let parameters = ["username": username, "password": password]
        // Create a URL to the API
        guard let url = URL(string: "http://127.0.0.1:5000/api/users/login") else {
            return
        }
        // Create a POST request with the parameters as the body of the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Serialize the parameters into JSON data and add it to the request body
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error: \(error.localizedDescription)")
            return
        }
        // Send the request to the server and wait for a response
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            // Check if the response is valid
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                      print("Error: Invalid response")
                      return
                  }
            
            guard let data = data else {
                print("Error: No data received")
                return
            }
            // Try to decode the received data into an array of User objects
            do {
                let userData = try JSONDecoder().decode([User].self, from: data)
                if userData.count > 0 {
                    // If login is successful, set the current user and update UI
                    UserData.shared.currentUser = userData[0]
                    DispatchQueue.main.async {
                        loggedIn = true
                        self.not.text = "Logged in \(userData[0].username)"
                    }
                    print("User logged in successfully")
                } else {
                    print("Invalid username or password")
                    DispatchQueue.main.async {
                    self.not.text = "Wrong credentials"
                        
                    }
                    
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
            if (loggedIn == true)
            {
                // Push the user to the home view controller if logged in successfully
                DispatchQueue.main.async {
                    let uservc = (self.storyboard?.instantiateViewController(withIdentifier: "HomeVC"))!
                    self.navigationController?.pushViewController(uservc, animated: true)
                }
            
                
            }
        }.resume()
      
    }
}
