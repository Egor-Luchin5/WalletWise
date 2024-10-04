//
//  SettingsViewController.swift
//  WalletWise
//
//  Created by Егор Лукин on 11.08.2024.
//

import UIKit
import iOSDropDown

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var SwitchVibration: UISwitch!
    @IBOutlet weak var dropDown: DropDown!
    
    lazy var generator = UIImpactFeedbackGenerator(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropDown.optionArray = ManagerAndModel.shared.currency
        dropDown.text = UserDefaults.standard.string(forKey: "currency")
        SwitchVibration.isOn = UserDefaults.standard.bool(forKey: "SwitchVibrationisOn")
    }
    
    @IBAction func SwitchVibrationValueChanged(_ sender: UISwitch) {
        SwitchVibration.isOn == true ? UserDefaults.standard.set(true, forKey: "SwitchVibrationisOn") : UserDefaults.standard.set(false, forKey: "SwitchVibrationisOn")
    }
    
    
    @IBAction func closeAndSaveSettings(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("Currency"), object: dropDown.text)
        NotificationCenter.default.post(name: NSNotification.Name("SwitchIsOn"), object: SwitchVibration.isOn)
        
        checkSwitchOn()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func TextFieldPressed(_ sender: UITextField) {
        dropDown.showList()
        UserDefaults.standard.set(dropDown.text, forKey: "currency")
    }
    
    @IBAction func openManageCategory(_ sender: UIButton) {
        guard let manageCategoryController = self.storyboard?.instantiateViewController(withIdentifier: "ManageCategoryViewController") as? ManageCategoryViewController else {return}
        
        checkSwitchOn()
        
        present(manageCategoryController, animated: true)
    }
    
    @IBAction func MessageToDeveloperButtonPressed(_ sender: UIButton) {
        checkSwitchOn()
        guard let url = URL(string: "https://t.me/miladimal") else {return}
        UIApplication.shared.open(url)
    }
    
    @IBAction func OpenWebSiteButtonPressed(_ sender: UIButton) {
        checkSwitchOn()
        guard let url = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ") else {return}
        UIApplication.shared.open(url)
    }
    
    
    
    private func checkSwitchOn(){
        if SwitchVibration.isOn == true {
            generator.impactOccurred(intensity: 100)
        }
    }
}
