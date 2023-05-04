//
//  RegisterController.swift
//  ProjectManagement
//
//  Created by Mikhail Nazarov (Student) on 22/03/2023.
//

import UIKit

class RegisterController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var reglabel: UILabel!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    let minLength = 6
    let strongPasswordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        username.delegate = self
        password.delegate = self
        email.delegate = self
    }
    

    func textFieldDidEndEditing(_ textField: UITextField) {
          if textField == username || textField == email {
              checkMinLengthRequirement(textField: textField)
          } else if textField == password {
              checkPasswordStrength(textField: textField)
          }
      }
      
    func checkMinLengthRequirement(textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = UIColor.red.cgColor
            reglabel.textColor = UIColor.red
            reglabel.text = "Please fill in all fields."
            return
        }
        
        if text.count < minLength {
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = UIColor.red.cgColor
            reglabel.textColor = UIColor.red
            reglabel.text = "Username and email must have at least \(minLength) characters."
        } else {
            textField.layer.borderWidth = 0.0
            if username.layer.borderWidth == 0.0 && password.layer.borderWidth == 0.0 && email.layer.borderWidth == 0.0 {
                reglabel.text = ""
            }
        }
    }
      
    func checkPasswordStrength(textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = UIColor.red.cgColor
            reglabel.textColor = UIColor.red
            reglabel.text = "Please fill in all fields."
            return
        }
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", strongPasswordRegex)
        if passwordTest.evaluate(with: text) {
            textField.layer.borderWidth = 0.0
            if username.layer.borderWidth == 0.0 && password.layer.borderWidth == 0.0 && email.layer.borderWidth == 0.0 {
                reglabel.text = ""
            }
        } else {
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = UIColor.red.cgColor
            reglabel.textColor = UIColor.red
            reglabel.text = "Password must have at least 8 characters, 1 letter, 1 number, and 1 special character."
        }
    }
    
    
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        checkMinLengthRequirement(textField: username)
               checkMinLengthRequirement(textField: email)
               checkPasswordStrength(textField: password)

               guard let usernameText = username.text,
                     let passwordText = password.text,
                     let emailText = email.text,
                     username.layer.borderWidth == 0.0,
                     password.layer.borderWidth == 0.0,
                     email.layer.borderWidth == 0.0 else {
                   return
               }
               
               let parameters = ["username": usernameText, "password": passwordText, "email": emailText]
               
        
    
        
        guard let url = URL(string: "http://127.0.0.1:5000/api/users/register") else {
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
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let dict = json as? [String: Any],
                   let registerSuccess = dict["Register_Success"] as? Bool,
                   registerSuccess == true {
                    print("User registration successful")
                    
                    
                    DispatchQueue.main.async {
                        self.reglabel.text = "Account registered!"
                        let loginvc = (self.storyboard?.instantiateViewController(withIdentifier: "LoginVC"))!
                        self.navigationController?.pushViewController(loginvc, animated: true)
                    }
                    
                    
                    
                    
                    
                } else {
                    print("User registration failed")
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
