//
//  NotificationViewController.swift
//  BookBuddy
//
//  Created by Tony Nguyen on 3/6/2023.
//

import UIKit
import UserNotifications

class NotificationViewController: UIViewController {
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func schedule(_ sender: Any) {
        notificationCenter.getNotificationSettings { (settings) in
            
            DispatchQueue.main.async {
            
                let goal = self.goalTextField.text!
                self.goalTextField.text = self.remindedBookTitle
                let date = self.datePicker.date
                
                if(settings.authorizationStatus == .authorized) {
                    let content = UNMutableNotificationContent()
                    content.title = "BookBuddy"
                    content.body = goal
                    
                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    self.notificationCenter.add(request) { (error) in
                        if (error != nil) {
                            print("Error" + error.debugDescription)
                            return
                        }
                    }
                    let alertControl = UIAlertController(title: "Send me a reminder?", message: self.formattedDate(date: date), preferredStyle: .alert)
                    alertControl.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in }))
                    self.present(alertControl, animated: true)
                }
                else {
                    let alertControl = UIAlertController(title: "Notification not enabled?", message: "Permission required to use this feature.", preferredStyle: .alert)
                    let goToSetting = UIAlertAction(title: "Settings", style: .default) {(_) in
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString)
                        else {
                            return
                        }
                        if(UIApplication.shared.canOpenURL(settingsURL)) {
                            UIApplication.shared.open(settingsURL) { (_) in }
                        }
                    }
                    alertControl.addAction(goToSetting)
                    alertControl.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in }))
                    self.present(alertControl, animated: true)
                    
                }
                
            }
            
        }
    }
    
    
    // Create a notification content object
    let notificationCenter = UNUserNotificationCenter.current()
    var remindedBookTitle: String = ""
    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert])
        { (granted, error) in
            if !granted {
                print("Permission was not granted!")
                return
            }
        }
        
    }
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y HH:mm"
        return formatter.string(from: date)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
