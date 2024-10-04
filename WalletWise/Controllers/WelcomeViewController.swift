//
//  WelcomeViewController.swift
//  WalletWise
//
//  Created by Егор Лукин on 19.08.2024.
//

import UIKit
import iOSDropDown

class WelcomeViewController: UIViewController {
    @IBOutlet weak var dropDown: DropDown!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropDown.optionArray = ManagerAndModel.shared.currency
        dropDown.text = "$"
        
    }
    @IBAction func StartToUseButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("Currency"), object: dropDown.text)
        
        self.dismiss(animated: true, completion: nil)
        Core.shared.setISNotUser()
    }
    
    @IBAction func TextFieldPressed(_ sender: UITextField) {
        dropDown.showList()
    }
    
}


