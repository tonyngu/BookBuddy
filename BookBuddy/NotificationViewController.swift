//
//  NotificationViewController.swift
//  BookBuddy
//
//  Created by Tony Nguyen on 3/6/2023.
//  Tutorial followed: https://www.youtube.com/watch?v=qDbbdvTYpVI

import UIKit
import UserNotifications

class NotificationViewController: UIViewController {
    @IBOutlet weak var goalTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func schedule(_ sender: Any) {
        
        // Checking if user has given permission to show notification
        notificationCenter.getNotificationSettings { (settings) in
            
            // View should only be modify from main thread.
            DispatchQueue.main.async {
            
                let goal = self.goalTextField.text!
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
                    
                    // Show alert to indicate when the notification will be send.
                    let alertControl = UIAlertController(title: "Send me a reminder?", message: self.formattedDate(date: date), preferredStyle: .alert)
                    alertControl.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in }))
                    self.present(alertControl, animated: true)
                }
                    // Show alert if the user have not give permission.
                else {
                    let alertControl = UIAlertController(title: "Notification not enabled?", message: "Permission required to use this feature.", preferredStyle: .alert)
                    
                    // Displaying an option for the user to go to setting to enable notification.
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
    
    
    // Create a notification content object.
    let notificationCenter = UNUserNotificationCenter.current()
    var remindedBookTitle: String = ""
    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        
        // Ask user for permission to show notification.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert])
        { (granted, error) in
            if !granted {
                print("Permission was not granted!")
                return
            }
        }
        // Pass the book title to the text field when user choose a specific book.
        self.goalTextField.text = self.remindedBookTitle
        
        
    }
    // Formating date into a string for displaying.
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y HH:mm"
        return formatter.string(from: date)
    }
    
}
