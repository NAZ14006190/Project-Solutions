//
//  EditAccViewController.swift
//  ProjectSolutions
//
//  Created by Mikhail Nazarov (Student) on 02/05/2023.
//

import UIKit

class EditAccViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userUsername: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var updateAccButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    let minLength = 3
        let strongPasswordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$"
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            userUsername.delegate = self
            userEmail.delegate = self
            userPassword.delegate = self
            // Add action to update button
            updateAccButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
            // Display current user data
            displayUserData()
        }
    // Retrieve the current user's data and display it in the text fields
        func displayUserData() {
            guard let currentUser = UserData.shared.currentUser else { return }
            userUsername.text = currentUser.username
            userEmail.text = currentUser.email
        }
        
        @objc func updateButtonTapped() {
            // Navigate back to the home screen
            DispatchQueue.main.async {
                if let navigationController = self.navigationController,
                   let homeVC = navigationController.viewControllers.first(where: { $0.restorationIdentifier == "HomeVC" }) {
                    navigationController.popToViewController(homeVC, animated: true)
                }
            }
        }
    // Check text field validation on editing ended
        func textFieldDidEndEditing(_ textField: UITextField) {
            if textField == userUsername || textField == userEmail {
                checkMinLengthRequirement(textField: textField)
            } else if textField == userPassword {
                checkPasswordStrength(textField: textField)
            }
        }
        
        func checkMinLengthRequirement(textField: UITextField) {
            guard let text = textField.text, !text.isEmpty else {
                textField.layer.borderWidth = 1.0
                textField.layer.borderColor = UIColor.red.cgColor
                errorLabel.textColor = UIColor.red
                errorLabel.text = "Please fill in all fields."
                return
            }
            
            if text.count < minLength {
                textField.layer.borderWidth = 1.0
                textField.layer.borderColor = UIColor.red.cgColor
                errorLabel.textColor = UIColor.red
                errorLabel.text = "Username and email must have at least \(minLength) characters."
            } else {
                textField.layer.borderWidth = 0.0
                if userUsername.layer.borderWidth == 0.0 && userPassword.layer.borderWidth == 0.0 && userEmail.layer.borderWidth == 0.0 {
                    errorLabel.text = ""
                }
            }
        }
    // Check if password meets strong password requirements
        func checkPasswordStrength(textField: UITextField) {
            guard let text = textField.text, !text.isEmpty else {
                textField.layer.borderWidth = 1.0
                textField.layer.borderColor = UIColor.red.cgColor
                errorLabel.textColor = UIColor.red
                errorLabel.text = "Please fill in all fields."
                return
            }
            
            let passwordTest = NSPredicate(format: "SELF MATCHES %@", strongPasswordRegex)
            if passwordTest.evaluate(with: text) {
                textField.layer.borderWidth = 0.0
                if userUsername.layer.borderWidth == 0.0 && userPassword.layer.borderWidth == 0.0 && userEmail.layer.borderWidth == 0.0 {
                    errorLabel.text = ""
                }
            } else {
                textField.layer.borderWidth = 1.0
                textField.layer.borderColor = UIColor.red.cgColor
                errorLabel.textColor = UIColor.red
                errorLabel.text = "Password must have at least 8 characters, 1 letter, 1 number, and 1 special character."
            }
        }
    }
