//
//  DataViewController.swift
//  Medchat
//
//  Created by Srihari Mohan on 5/21/16.
//  Copyright © 2016 Srihari Mohan. All rights reserved.
//

import Foundation
import UIKit

class DataViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var flo: UIBarButtonItem!
    @IBOutlet weak var chatField: UITextField!
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatField.delegate = self
        chatField.tintColor = UIColor(red: 1, green: 102/255.0, blue: 104/255.0, alpha: 1)
        chatField.returnKeyType = UIReturnKeyType.Send
        flo.target = self.revealViewController()
        flo.action = #selector(SWRevealViewController.revealToggle(_:))
        navBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 0/255.0, green: 142/255.0, blue: 204/255.0, alpha: 1.0), NSFontAttributeName : UIFont(name: "Noteworthy-bold", size: 18)!]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
        self.subscribeToKeyboardDidShow()
        self.subscribeToKeyboardHidden()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
        self.unsubscribeFromKeyboardDidShow()
        self.unsubscribeFromKeyboardHidden()
    }
}

extension DataViewController {
        
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
            
        return true;
    }
        
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true;
    }
        
    //want a notification parameter as supplied by subscribeToKeyboardNotifications() call
    func keyboardWillShow(notification: NSNotification) {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        self.view.frame.origin.y -= getKeyboardHeight(notification) * 3/4
    }
    
    func keyboardDidShow(notification: NSNotification) {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
        
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y += getKeyboardHeight(notification) * 3/4
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
    
    func subscribeToKeyboardDidShow() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow), name: UIKeyboardDidShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardDidShow() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
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
}

extension DataViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}