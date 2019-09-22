//
//  ViewController.swift
//  WakeUp
//
//  Created by Doe on 3/2/18.
//  Copyright © 2018 Doe. All rights reserved.
//

import UIKit
import CustomAlert

@IBDesignable
class ClockViewController: UIViewController  {
    
    // MARK: Properties -
    @IBOutlet weak var setButton: RoundedButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var clockLabel: UILabel!
    private var timeNowString = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
    var alarmTVC = AlarmsTableViewController()
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.displayTime), userInfo: nil, repeats: true)
        datePicker.setValue(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), forKey: "textColor")
        let lc = NSLocale.autoupdatingCurrent
        datePicker.locale = lc
        datePicker.calendar = Calendar.autoupdatingCurrent
        if let navVC = splitViewController?.viewControllers[0] as? UINavigationController , let alarm = navVC.viewControllers[0] as? AlarmsTableViewController {
            alarmTVC = alarm
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func displayTime() {
        clockLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
    }
    
    @IBAction func setAlarmButtonIsPressed(_ sender: UIButton) {
        let pickerDate = DateFormatter().formatPickerDate(pickerDate: datePicker)
        let datesFormExistingAlarms = alarmTVC.alarmArrayForAlarmTVC.map({$0.getAlarmTime()})
        if datesFormExistingAlarms.contains(pickerDate) == false {
            let newAlarm = Alarm(time: pickerDate)
            alarmTVC.alarmArrayForAlarmTVC.append(newAlarm)
            alarmTVC.scheduler.createRequestAndSetAlarm(newAlarm)
            navigationController?.popViewController(animated: true)
            alarmTVC.update()
        }
    }
}

extension DateFormatter {
    
    func customFormattedDate(_ date : Date) -> Date {
        var dateComponents = Calendar.autoupdatingCurrent.dateComponents([.calendar,.year ,.month, .day , .hour , .minute , .second ,.timeZone], from: date)
        dateComponents.second = 0
        let newDate = Calendar.autoupdatingCurrent.date(from: dateComponents)
        return newDate!
    }
    
    func formatPickerDate (pickerDate : UIDatePicker) -> Date {
        var newDate : Date
        if self.customFormattedDate(pickerDate.date) <= self.customFormattedDate(Date()){
            var dateComponents = Calendar.autoupdatingCurrent.dateComponents([.calendar, .year , .month , .day , .hour , .minute , .second , .timeZone], from: pickerDate.date)
            dateComponents.day = dateComponents.day! + 1
            dateComponents.second = 0
            newDate = Calendar.autoupdatingCurrent.date(from: dateComponents)!
            return newDate
        }
        return self.customFormattedDate(pickerDate.date)
    }
    
    func print(_ date : Date) -> String {
        self.dateFormat = "h:mm a"
        return self.string(from: date)
    }
    
}
