//
//  ViewController.swift
//  NVC
//
//  Created by lrussu on 5/24/17.
//  Copyright © 2017 lrussu. All rights reserved.
//

import UIKit
import MessageUI


class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var login: String?
    var searchButtonFlag = false
    var jsonToPassBySegue: NSDictionary?

    @IBOutlet weak var loginUIText  : UITextField!
    
    @IBOutlet weak var searchButtom: UIButton!
    
    @IBAction func submitFoundButton(_ sender: UIButton) {
        
        guard let login = loginUIText.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
            return
        }
        
        if login.isEmpty || searchButtonFlag {
            return
        }
        
        searchButtonFlag = true
        
        launchUserIdRequest(login: login)
    }
    
    func match(for regex: String, in text: String) -> Bool {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: nsString as String, options: [], range: NSRange(location: 0, length: nsString.length))
            return results.count > 0
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    
    func sortProjects(p1: NSDictionary, p2: NSDictionary) -> Bool {
        return p2.value(forKey: "slug") as! String > p1.value(forKey: "slug") as! String
    }
    
    
    
    func launchUserIdRequest(login: String) {
        
        guard let request = (UIApplication.shared.delegate as! AppDelegate).createUserIdRequest(login: login) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard error == nil else {
                print("Error \(error)")
                return
            }
            guard let dataRequest = data else {
                print("Data was not recieved")
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: dataRequest, options: []) as? NSDictionary else {
                    print("ERROR parse JSON")
                    return
                }
                
                guard json.value(forKey: "id") != nil else {
                    return
                }
                self.jsonToPassBySegue = json
                
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "profile")
                
                if let controllerTable = controller as? TableViewController {
                    controllerTable.jsonPassedBySegue = json
                    
                    let level = json.value(forKey: "cursus_users") as! [NSDictionary]
                    controllerTable.skills = level.filter{$0.value(forKey: "cursus_id") as! Int == 1}.first?.value(forKey: "skills") as? [NSDictionary]
                    
                    let project = json.value(forKey: "projects_users") as! [NSDictionary]
                    let filteredProjects = project.map({["final_mark": String(describing: $0.value(forKey: "final_mark")!),
                                                         "id": String(describing: ($0.value(forKey: "project") as! NSDictionary).value(forKey: "id")!),
                                                         "parent_id": String(describing: ($0.value(forKey: "project") as! NSDictionary).value(forKey: "parent_id")!),
                                                         "slug": String(describing: ($0.value(forKey: "project") as! NSDictionary).value(forKey: "slug")!),
                                                         "name": String(describing: ($0.value(forKey: "project") as! NSDictionary).value(forKey: "name")!)
                                                        ] as NSDictionary})
                    let sortedProjects = filteredProjects.sorted(by: self.sortProjects)
                    controllerTable.projects = sortedProjects
                }
                DispatchQueue.main.async() { () -> Void in
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            } catch {
                print("Error ")
                return
            }
        }
        task.resume()
    }
    
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
        if (segue.identifier == "segueToProfile") {
            // initialize new view controller and cast it as your view controller
            let viewController = segue.destination as! TableViewController
            // your new view controller should have property that will store passed value
            viewController.jsonPassedBySegue = self.jsonToPassBySegue
        }
    }
    

    override func viewDidAppear(_ animated: Bool) {
        self.searchButtonFlag = false
        //loginUIText.becomeFirstResponder()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchButtom.layer.cornerRadius = 5
        self.searchButtonFlag = false
        //(timeInterval: 1, target: self, selector: #selector(setAccessTokenToNil), userInfo: nil, repeats: true)
        
        guard alert != nil else {
            print("AlertController is nil")
            return
        }
        loginUIText.resignFirstResponder()
        
        loginUIText.autocorrectionType = .no
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

