//
//  TableViewController.swift
//  NVC
//
//  Created by lrussu on 6/8/17.
//  Copyright © 2017 lrussu. All rights reserved.
//

import UIKit
import Foundation

class TableViewController: UITableViewController {
    
    var jsonPassedBySegue: NSDictionary?
    var skills: [NSDictionary]?
    var projects: [NSDictionary]?
    
    let sections = ["", "Skils", "Projects"]
    
    @IBOutlet weak var profileCell: TableViewCell!
    
    @IBOutlet weak var skillsCell: SkillsTableViewCell!
    
    @IBOutlet weak var projectsCell: ProjectsTableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "skillsEmbedSegue") {
            let childVC = segue.destination as! SkillsTableViewController
            childVC.passedSkills = skills
        }
        
        if (segue.identifier == "projectsEmbedSegue") {
            let childVC = segue.destination as! ProjectsTableViewController
            childVC.passedProjects = projects
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    internal func launchUserpicRequest(imageUrl: String, cell: TableViewCell?) {
        guard let cellCustom = cell else {
            return
        }
        guard let request = (UIApplication.shared.delegate as! AppDelegate).createUserpicRequest(imageUrl: imageUrl) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard let httpURLResponse = response as? HTTPURLResponse,
                httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType,
                mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            
            DispatchQueue.main.async() { () -> Void in
                cellCustom.userpic.image = image
                cellCustom.userpic.layer.borderWidth = 3
                cellCustom.userpic.layer.borderColor = UIColor.white.cgColor
                cellCustom.userpic.layer.cornerRadius = cellCustom.userpic.frame.width / 2.0
//                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                
//                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "profile")
//                self.navigationController?.setViewControllers([nextViewController], animated: false)
                
                //                func switchToViewController(identifier: String) {
                //                    let viewController =self.storyboard?.instantiateViewControllerWithIdentifier(identifier) as UIViewController
                //                    self.navigationController?.setViewControllers([viewController], animated: false)
                //                }
                
                //self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        }
        task.resume()
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

    func replace(for regex: String, in text: String, template: String) -> String {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.stringByReplacingMatches(in: nsString as String, options: [], range: NSRange(location: 0, length: nsString.length), withTemplate: template)
            print("RESULTS = \(results)")
            return results
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return text
        }
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return test(testcell: profileCell)
        
        } else if indexPath.section == 1 {
            
            return skillsCell
        } else {
            
            return projectsCell
        }
    }
    
        func test(testcell: TableViewCell) -> TableViewCell {
            let firstname = jsonPassedBySegue?.value(forKey: "first_name")
            let lastname = ((jsonPassedBySegue?.value(forKey: "last_name") as? String)?.uppercased())! as String
            //  let userpicUrl = jsonPassedBySegue?.value(forKey: "image_url")
            let login = jsonPassedBySegue?.value(forKey: "login")
            let correction = jsonPassedBySegue?.value(forKey: "correction_point")
            let wallet = jsonPassedBySegue?.value(forKey: "wallet")
            let phone = jsonPassedBySegue?.value(forKey: "phone")
            let level = jsonPassedBySegue?.value(forKey: "cursus_users") as! [NSDictionary]
            let l = level.filter{$0.value(forKey: "cursus_id") as! Int == 1}.first?.value(forKey: "level")
            let l2 = (l is NSNumber || l is String) ? "\(l!)" : ""
            let l3 = replace(for: "(^\\d+)\\.(\\d+$)", in: l2, template: "$1-$2%")
            let levelPercent = Float(l as! NSNumber) - Float(Int(l as! NSNumber))//replace(for: "^.+\\.(\\d+$)", in: l2, template: "$2")
            
            print("LEVEL = \(l3)")
            //        if let testcell = cell as? TableViewCell {
            
            if let userpicUrl = jsonPassedBySegue?.value(forKey: "image_url") {
                let regex = "(^.+/)([^/].+$)"
                let medium_userpicUrl = replace(for: regex, in: userpicUrl as! String, template: "$1small_$2")
                launchUserpicRequest(imageUrl: medium_userpicUrl, cell: testcell)
            }
            // TODO: configure cell
            testcell.username.text = (firstname is String || lastname is String) ? "\(firstname!) \(lastname)" : ""
            testcell.login.text = login == nil ? "" : login as! String
            testcell.correction.text = (correction is NSNumber || correction is String) ? "Correction \(correction!)" : ""
            testcell.wallet.text = (wallet is NSNumber || wallet is String) ? "Wallet: \(wallet!)" : ""
            testcell.phone.text = (phone is NSNumber || phone is String) ? "\(phone!)" : ""
            testcell.levellable.text = "Level: " + l3
            if testcell.level.frame.height < 4 {
                testcell.level.transform = testcell.level.transform.scaledBy(x: 1, y: 4)
            }
            testcell.level.progress = levelPercent;
            
            
            
            // testcell.level.transform = testcell.level.transform.scaledBy(x: 1, y: 20)
            
            testcell.level.layer.cornerRadius = 5.0
            testcell.level.clipsToBounds = true
            //            testcell.level.layer.borderWidth = 1
            //            testcell.level.layer.borderColor = UIColor.blue.cgColor
            //
            //            testcell.level.superview?.layer.cornerRadius = 5
            //            testcell.level.superview?.clipsToBounds = true
            //            testcell.level.superview?.layer.borderWidth = 10
            //            testcell.level.superview?.layer.borderColor = UIColor.blue.cgColor
            //    .layer.frame.height = 20
            //testcell.phone.isHidden = true
            //  testcell.level.bringSubview(toFront: testcell)
            
            
            return testcell

        }

}

//        var cell: UITableViewCell?
//        print("indexPath = \(indexPath)")
//        switch indexPath.section {
//            case 0:
//                let cell1: TableViewCell = (tableView.dequeueReusableCell(withIdentifier: "test", for: indexPath) as? TableViewCell)!
//            case 1:
//                cell = tableView.dequeueReusableCell(withIdentifier: "skillsCell", for: indexPath) as? SkillsTableViewCell
//            case 2:
//                cell = tableView.dequeueReusableCell(withIdentifier: "projectsCell", for: indexPath) as? ProjectsTableViewCell
//            default:
//                cell = UITableViewCell()
//        }
//        
//        return cell!
        
        
 
//        guard let cell = tableView.cellForRow(at: indexPath) // dequeueReusableCell(withIdentifier: "profileCell") //.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
//            else {
//                print("CELL NIL")
//                return UITableViewCell()
//                
//        }
        
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? TableViewCell
//                else {
//                    print("CELL NIL")
//                    return UITableViewCell()
//                    
//            }
//            cell.login.text = "test"
//            print("cell.description = \(cell.description)")
//            
//            return cell
        
/*       print ("cell.reuseIdentifier = \(cell.reuseIdentifier)")
        // Configure the cell...
       
        let firstname = jsonPassedBySegue?.value(forKey: "first_name")
        let lastname = ((jsonPassedBySegue?.value(forKey: "last_name") as? String)?.uppercased())! as String
      //  let userpicUrl = jsonPassedBySegue?.value(forKey: "image_url")
        let login = jsonPassedBySegue?.value(forKey: "login")
        let correction = jsonPassedBySegue?.value(forKey: "correction_point")
        let wallet = jsonPassedBySegue?.value(forKey: "wallet")
        let phone = jsonPassedBySegue?.value(forKey: "phone")
        let level = jsonPassedBySegue?.value(forKey: "cursus_users") as! [NSDictionary]
        let l = level.filter{$0.value(forKey: "cursus_id") as! Int == 1}.first?.value(forKey: "level")
        let l2 = (l is NSNumber || l is String) ? "\(l!)" : ""
        let l3 = replace(for: "(^\\d+)\\.(\\d+$)", in: l2, template: "$1-$2%")
        let levelPercent = Float(l as! NSNumber) - Float(Int(l as! NSNumber))//replace(for: "^.+\\.(\\d+$)", in: l2, template: "$2")

        print("LEVEL = \(l3)")
//        if let cellCustom = cell as? TableViewCell {
            
            if let userpicUrl = jsonPassedBySegue?.value(forKey: "image_url") {
                let regex = "(^.+/)([^/].+$)"
                let medium_userpicUrl = replace(for: regex, in: userpicUrl as! String, template: "$1small_$2")
                launchUserpicRequest(imageUrl: medium_userpicUrl, cell: cellCustom)
            }
            // TODO: configure cell
            cellCustom.username.text = (firstname is String || lastname is String) ? "\(firstname!) \(lastname)" : ""
            cellCustom.login.text = login == nil ? "" : login as! String
            cellCustom.correction.text = (correction is NSNumber || correction is String) ? "Correction \(correction!)" : ""
            cellCustom.wallet.text = (wallet is NSNumber || wallet is String) ? "Wallet: \(wallet!)" : ""
            cellCustom.phone.text = (phone is NSNumber || phone is String) ? "\(phone!)" : ""
            cellCustom.levellable.text = cellCustom.levellable.text! + l3
            cellCustom.level.transform = cellCustom.level.transform.scaledBy(x: 1, y: 4)
            cellCustom.level.progress = levelPercent;
           
            
            
           // cellCustom.level.transform = cellCustom.level.transform.scaledBy(x: 1, y: 20)
            
            cellCustom.level.layer.cornerRadius = 5.0
            cellCustom.level.clipsToBounds = true
//            cellCustom.level.layer.borderWidth = 1
//            cellCustom.level.layer.borderColor = UIColor.blue.cgColor
//            
//            cellCustom.level.superview?.layer.cornerRadius = 5
//            cellCustom.level.superview?.clipsToBounds = true
//            cellCustom.level.superview?.layer.borderWidth = 10
//            cellCustom.level.superview?.layer.borderColor = UIColor.blue.cgColor
            //    .layer.frame.height = 20
            //cellCustom.phone.isHidden = true
          //  cellCustom.level.bringSubview(toFront: cellCustom)
        }
       
//        
       // print("displayname = \(displayname)    CELL[\(indexPath)] = \(jsonPassedBySegue?.value(forKey: "displayname") )")
   //    print("cell.username.text = \(cell.username.text)")
 //       return cell
   */
  

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

