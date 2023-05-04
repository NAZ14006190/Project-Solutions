//
//  MenuViewController.swift
//  ProjectSolutions
//
//  Created by Mikhail Nazarov (Student) on 19/04/2023.
//


import UIKit
class MenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = UserData.shared.currentUser?.username
        self.title = "Welcome, \(name!)"
        
        
        // Do any additional setup after loading the view.
    }
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


