//
//  AppDelegate.swift
//  NVC
//
//  Created by lrussu on 5/24/17.
//  Copyright © 2017 lrussu. All rights reserved.
//

import UIKit
import MessageUI

var alert: UIAlertController?


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func setAccessTokenToNil() {
        accessToken = nil
        AppDelegate.expireToken = nil
    }
    
    static func createTokenRequest() -> URLRequest? {
        guard let url = URL(string: "https://api.intra.42.fr/oauth/token") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "grant_type=client_credentials&client_id=\(AppDelegate.uid)&client_secret=\(AppDelegate.secret)".data(using: .utf8)
        return request
    }
    
    func createUserIdRequest(login: String) -> URLRequest? {
        guard let token = accessToken else {
            return nil
        }
        guard let url = URL(string: "https://api.intra.42.fr/v2/users/\(login)") else {
            //?filter[login]=\(login)") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func createUserpicRequest(imageUrl: String) -> URL? {
        guard let request = URL(string: imageUrl) else {
            return nil
        }
        return request
    }
    
    var timer: Timer?
    static let uid = "1b9d3cc5126e0b62269cc47451839cf473a3937953bcddac94f284ef6cf09fda"
    static let secret = "9885e27da0f1b58b87e39adfadebcf3fa0034793187af026893485381f8e03b8"
    var tokenRequest = AppDelegate.createTokenRequest()
    static var expireToken: Double?
    var accessToken: String?
    
    var window: UIWindow?

    func sendEmail() {
        let mailComposeViewController = configureMailController()
        if MFMailComposeViewController.canSendMail() {
            self.window?.rootViewController?.present(mailComposeViewController, animated: true, completion: nil)
            
        } else {
            showMailError()
        }
    }
    
    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.setToRecipients(["artimida@gmail.com"])
        mailComposerVC.setSubject("54353535")
        mailComposerVC.setMessageBody("5435435345345345345345?", isHTML: false)
        
        return mailComposerVC
    }
    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        //        self.present(sendMailErrorAlert, animated: true, completion: nil)
        self.window?.rootViewController?.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func someBackgroundTask(timer:Timer) {
        DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
            print("do some background task")
            
            DispatchQueue.main.async {
                print("update some UI")
            }
        }
    }
    
    func launchRequestToken() {
        
        accessToken = nil
        
        guard let request = AppDelegate.createTokenRequest() else {
            return
        }

        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let responseRequest = response as? HTTPURLResponse else {
                print("ERROR response")
                return
            }
            
            guard responseRequest.statusCode == 200 else {
                alert = UIAlertController(title: "Нет соединения", message: "Приложение не получило запрашиваемых данных", preferredStyle: UIAlertControllerStyle.alert)
                
                alert?.addAction(UIAlertAction(title: "Повторить попытку снова", style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in
                    // делаем что-то при выборе действия 1
                })
                alert?.addAction(UIAlertAction(title: "Повторить попытку через 10 минут", style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in
                    // делаем что-то при выборе действия 1
                })
                alert?.addAction(UIAlertAction(title: "Отправить запрос разработчику", style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in
                    self.sendEmail()
                    // делаем что-то при выборе действия 1
                })
                alert?.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (sender: UIAlertAction) -> Void in
                    // ничего не делаем
                })
                
                self.window?.rootViewController?.present(alert!, animated: true, completion: nil)
                print("Status request is not 200. Status is \(responseRequest.statusCode)")
                return
            }
            
            guard let dataRequest = data else {
                print("Data was not recieved")
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: dataRequest, options: []) as? [String: AnyObject] else {
                    print("ERROR parse JSON")
                    return
                }
                
                self.accessToken = json["access_token"] as! String?
                self.timer?.invalidate()
                self.timer = nil
                DispatchQueue.main.async {
                    self.timer = Timer.scheduledTimer(timeInterval: json["expires_in"]! as! TimeInterval, target: self, selector: #selector(self.launchRequestToken), userInfo: nil, repeats: false)
                }
                
            } catch {
                print("Error")
            }
            
            print("Response \(responseRequest.statusCode)")
        }
        task.resume()
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
            return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        if self.tokenRequest != nil {
            launchRequestToken()
        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
        
}

