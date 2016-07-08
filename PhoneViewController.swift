//
//  PhoneViewController.swift
//  Medchat
//
//  Created by Srihari Mohan on 6/11/16.
//  Copyright © 2016 Srihari Mohan. All rights reserved.
//

import UIKit

class PhoneViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var mynumber: UITextField!
    @IBOutlet weak var countryLab: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mynumber.delegate = self
        countryLab.delegate = self
        if let phoneNumber = NSUserDefaults.standardUserDefaults().valueForKey("phone") as? String {
            mynumber.text = phoneNumber
        }
        if let country = NSUserDefaults.standardUserDefaults().valueForKey("country") as? String {
            countryLab.text = country
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
        self.subscribeToKeyboardHidden()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
        self.unsubscribeFromKeyboardHidden()
    }

    @IBAction func confirm(sender: AnyObject) {
        //confirm to persistent memory
        let number = mynumber.text
        let country = countryLab.text

        if number != nil && !number!.isEmpty {
            NSUserDefaults.standardUserDefaults().setValue(number, forKey: "phone")
        }
        
        if country != nil && !country!.isEmpty {
            NSUserDefaults.standardUserDefaults().setValue(country, forKey: "country")
        }
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        return true;
    }
}

extension PhoneViewController {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true;
    }
    
    //want a notification parameter as supplied by subscribeToKeyboardNotifications() call
    func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y -= getKeyboardHeight(notification) * 1/5
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y += getKeyboardHeight(notification) * 1/5
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        //userInfo dictionary holds user information like the size of the keyboard
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardHidden() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        //notification of when UIKeyboardWillShow
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardHidden() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    private func valid(phone: String) -> Bool { return true; }
}
