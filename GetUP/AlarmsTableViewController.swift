//
//  AlarmsTableViewController.swift
//  GetUP
//
//  Created by Doe on 3/6/18.
//  Copyright © 2018 Doe. All rights reserved.
//

import UIKit
import EventKit

class AlarmsTableViewController: UITableViewController {
 
    var alarmArrayForAlarmTVC = [Alarm]() {
        didSet {
            alarmArrayForAlarmTVC.sort()
        }
    }
    var alarmsToRemove = [Alarm]()
    var scheduler : AlarmSchedulerDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    override func viewWillAppear(_ animated: Bool) {
        update()
    }
    override func viewWillDisappear(_ animated: Bool) {
        update()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func update() {
        DispatchQueue.main.async {
                self.tableView.reloadData()
        }
    }
    
    @IBAction func navBarButtonPressed(_ sender: UIBarButtonItem) {
        let clockView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "clockView")
        splitViewController?.showDetailViewController(clockView, sender: nil)
    }
    

    // MARK: - Table view data source
    
    /**
     Sets the individual alarm activity from table view
    */
    
    @IBAction func alarmActivityChanged(_ sender: UISwitch) {
        if let index = tableView.indexPath(for: sender.superview?.superview as! UITableViewCell)?.row{
            alarmArrayForAlarmTVC[index].active = sender.isOn
            alarmsToRemove.append(alarmArrayForAlarmTVC[index])
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return alarmArrayForAlarmTVC.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "alarmCell", for: indexPath) as! AlarmCell
        // Configure the cell...
        cell.alarmActivity.tintColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
        cell.alarmActivity.isOn = (alarmArrayForAlarmTVC[indexPath.row].active)
        cell.alarmTimeLabel.text = DateFormatter.localizedString(from:alarmArrayForAlarmTVC[indexPath.row].getAlarmTime(), dateStyle: .none, timeStyle: .medium)
        return cell
    }
    
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.beginUpdates()
            let alarmToRemove = alarmArrayForAlarmTVC.remove(at: indexPath.row)
            alarmsToRemove.append(alarmToRemove)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
       
    }

/*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     }
 

     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return false
     }
*/
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == "showAlarmDetail" {
            if let vc = segue.destination as? AlarmDetailViewController , let selectedCell = sender as? AlarmCell , let index = tableView.indexPath(for: selectedCell) {
                vc.detailAlarm =  Alarm(time: alarmArrayForAlarmTVC[index.row].getAlarmTime())
            }
        }
     }
}

class AlarmDetailViewController: UIViewController {

    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var detailAlarmSwitch: UISwitch!
    @IBOutlet weak var detailLabel: UILabel!
    var detailAlarm = Alarm(time: Date())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillTimeAndDateLabelForAlarmDetail()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func fillTimeAndDateLabelForAlarmDetail() {
        detailLabel.text = DateFormatter().print(detailAlarm.getAlarmTime())
        detailAlarmSwitch.isOn = detailAlarm.active
        let formatter = DateComponentsFormatter()
        formatter.calendar = Calendar.autoupdatingCurrent
        formatter.includesTimeRemainingPhrase = true
        formatter.allowsFractionalUnits = true
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour ,.minute]
       remainingLabel.text = formatter.string(from: Date(), to: detailAlarm.getAlarmTime())
    }
}
class AlarmCell: UITableViewCell {
    @IBOutlet weak var alarmTimeLabel: UILabel!
    @IBOutlet weak var alarmActivity: UISwitch!
    override func setSelected(_ selected: Bool, animated: Bool) {
    }
}
