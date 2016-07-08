//
//  ChatViewController.swift
//  Medchat
//
//  Created by Srihari Mohan on 5/20/16.
//  Copyright © 2016 Srihari Mohan. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
import AVFoundation
import CoreData

class ChatViewController: UIViewController, UITextFieldDelegate,
    UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    AVAudioRecorderDelegate {
   
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var imagePicker: UIImagePickerController = UIImagePickerController()
    var cameraPicker: UIImagePickerController = UIImagePickerController()
    var soundRecorder: AVAudioRecorder!
    var audioToggle = Bool()
    private var popGesture: UIPanGestureRecognizer?
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var chatField: UITextField!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var microphone: UIButton!
    @IBOutlet weak var mailIcon: UIButton!
    
    var fetchedResultsController : NSFetchedResultsController? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            tableView.reloadData()
        }
    }
    
    // Do not worry about this initializer. I has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.None
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        chatField.delegate = self
        chatField.returnKeyType = UIReturnKeyType.Send
        self.hideKeyboardWhenTappedAround()
        chatField.tintColor = UIColor(red: 1, green: 102/255.0, blue: 104/255.0, alpha: 1)
        cameraButton.tintColor = UIColor(red: 0/255.0, green: 142/255.0, blue: 204/255.0, alpha: 1)
        videoButton.tintColor = UIColor(red: 0/255.0, green: 142/255.0, blue: 204/255.0, alpha: 1)
        microphone.tintColor = UIColor(red: 0/255.0, green: 142/255.0, blue: 204/255.0, alpha: 1)
        mailIcon.tintColor = UIColor(red: 0/255.0, green: 142/255.0, blue: 204/255.0, alpha: 1)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch { NSLog("Could not instantiate AVAudioSession") }
        self.setupRecorder()
        
        let stack = appDelegate.stack
        let fr = NSFetchRequest(entityName: "Content")
        fr.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func addMessage(sender: String, date: String, body: String,
                    creationDate: NSDate, context: NSManagedObjectContext) {
        _ = Content(sender: sender, date: date, body: body,
                    creationDate: creationDate, context: context)
        
        do {
            try fetchedResultsController?.performFetch()
        } catch { print("Could not fetch request") }
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.allowsSelection = false
        self.subscribeToKeyboardNotifications()
        self.subscribeToKeyboardDidShow()
        self.subscribeToKeyboardHidden()
        tableView.reloadData()
        scrollToBottom()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
        self.unsubscribeFromKeyboardDidShow()
        self.unsubscribeFromKeyboardHidden()
    }
    
    @IBAction func playOrStop(sender: AnyObject) {
        if audioToggle {
            stopAudio()
        } else {
            recordAudio()
        }
        audioToggle = !audioToggle
    }
    
    func setupRecorder() {
        let recordSettings = [AVFormatIDKey: Int(kAudioFormatLinearPCM),
                              AVSampleRateKey: 16000.0,
                              AVNumberOfChannelsKey: 1 as NSNumber,
                              AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue]
        do {
            try soundRecorder = AVAudioRecorder(URL: ChatViewController.getFileURL(), settings: recordSettings as [String:AnyObject])
        } catch {
            NSLog("error in retrieving recorded audio file")
            return;
        }
        soundRecorder.delegate = self
        soundRecorder.meteringEnabled = true
        soundRecorder.prepareToRecord()
    }
    
    static func getFileURL() -> NSURL {
        let audiofile = "recorderfile.l16"
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
                    NSSearchPathDomainMask.UserDomainMask, true) 
        let filePath = (paths[0] as NSString).stringByAppendingPathComponent(audiofile)
        print(filePath)
        return NSURL(fileURLWithPath: filePath);
    }
    
    func recordAudio() {
        NSLog("Entered Recording")
        microphone.tintColor = UIColor(red: 46/255.0, green: 191/255.0, blue: 87/255.0, alpha: 1)
        soundRecorder.record()
    }
    
    func stopAudio() {
        NSLog("Entered Stop Recording")
        microphone.tintColor = UIColor(red: 0/255.0, green: 142/255.0, blue: 204/255.0, alpha: 1)
        soundRecorder.stop()
        //TODO: API Integration
        let parameters: [String: AnyObject] = [String:AnyObject]()
        MedchatClient.taskForPOSTSpeech(MedchatClient.Methods.STT, parameters: parameters) { (results, error) in
            
            print("Entered Speech-To-Text Parsing")
            
            if let error = error {
                NSLog("\(error)")
            } else {
                if let resArr = results[MedchatClient.JSONResponseKeys.Results] as? [AnyObject] where
                    resArr.count > 0 {
                    if let dict = (resArr[0] as? [String: AnyObject]) {
                        if let alts = dict[MedchatClient.JSONResponseKeys.Alternatives] as? [AnyObject] {
                            if let content = alts[0] as? [String: AnyObject] {
                                if let transcript = content[MedchatClient.JSONResponseKeys.Transcript] as? String {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.chatField.becomeFirstResponder()
                                        self.chatField.text = transcript
                                    }
                                }
                            }
                        }
                    }
                } else {
                    NSLog("Error in parsing bot response")
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertVC = UIAlertController(title: "I couldn't quite catch that.", message: "Could you try again?", preferredStyle: .Alert)
                        let alert_action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alertVC.addAction(alert_action)
                        self.presentViewController(alertVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func goToCamera(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                let cameraDelegate = CameraDelegate()
                cameraPicker.allowsEditing = false
                cameraPicker.sourceType = .Camera
                cameraPicker.mediaTypes = [kUTTypeImage as String]
                cameraPicker.cameraCaptureMode = .Photo
                cameraPicker.delegate = cameraDelegate
                self.presentViewController(cameraPicker, animated: true, completion: nil)
            }
        } else {
            print("Camera inaccessible")
        }
//        let cameraCaptureVC = self.storyboard?.instantiateViewControllerWithIdentifier("CameraCaptureVC")
//            as! CameraCaptureViewController
//        self.presentViewController(cameraCaptureVC, animated: false, completion: nil)
    }
    
    @IBAction func goToVideo(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                imagePicker.sourceType = .Camera
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.allowsEditing = false
                imagePicker.delegate = self
                self.presentViewController(imagePicker, animated: true, completion: nil)
            } else {
                NSLog("Application cannot access the camera")
            }
        } else {
            NSLog("Camera inaccessible, application cannot access the camera")
        }
    }
    
    @IBAction func gotoInbox(sender: AnyObject) {
        let inboxVC = self.storyboard?.instantiateViewControllerWithIdentifier("InboxVC") as! InboxViewController
        self.presentViewController(inboxVC, animated: true, completion: nil)
    }
    
    func getDateString(time: NSDate) -> String {
        var date = "\(time)"
        date = date.substringToIndex(date.startIndex.advancedBy(10))
        date = date.substringFromIndex(date.startIndex.advancedBy(5)) +
                "-" + date.substringToIndex(date.startIndex.advancedBy(4))
        return date;
    }
    
    func query(body: String) {
        addMessage("Me", date: self.getDateString(NSDate()), body: body,
                   creationDate: NSDate(), context: (fetchedResultsController?.managedObjectContext)!)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
            self.scrollToBottom()
        }
        
        var parameters = [MedchatClient.ParameterKeys.Input : body]
        
        if MedchatClient.sharedInstance().sessionID != nil {
            parameters[MedchatClient.ParameterKeys.SessionID] = MedchatClient.sharedInstance().sessionID!
        }
        
        print(parameters)
        
        var mutableMethod: String = MedchatClient.Methods.Talk
        mutableMethod = substituteKeyInMethod(mutableMethod, key: MedchatClient.URLKeys.AppID, value: String(MedchatClient.Constants.ApiKey))!
        mutableMethod = substituteKeyInMethod(mutableMethod, key: MedchatClient.URLKeys.BotName, value: String(MedchatClient.Constants.BotName))!
        
        print(mutableMethod)
        
        /* 2. Make the request */
        MedchatClient.taskForPOSTMethod(mutableMethod, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
            } else {
                if let responses = results[MedchatClient.JSONResponseKeys.Responses] as? [AnyObject] {
                    
                    for botResponse in responses {
                        self.addMessage("Flo", date: self.getDateString(NSDate()), body: botResponse as! String,
                                        creationDate: NSDate(), context: (self.fetchedResultsController?.managedObjectContext)!)
                    }
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)/2)), dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                        self.scrollToBottom()
                    }
                } else {
                    NSLog("Error in parsing bot response")
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertVC = UIAlertController(title: "Flo had trouble processing your question.", message: "We appreciate your patience as we troubleshoot the problem", preferredStyle: .Alert)
                        let alert_action = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
                        alertVC.addAction(alert_action)
                        self.presentViewController(alertVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension ChatViewController {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        return true;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let testText = textField.text {
            if testText.isEmpty {
                return false;
            }
        }
        
        NSLog("entered")
        
        guard let body = self.chatField.text else {
            NSLog("could not parse user message in chatField")
            return false
        }
        
        guard !body.isEmpty else {
            NSLog("body is empty")
            return false
        }
        
        query(body)
        textField.text = ""
        
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
}

extension ChatViewController {
    
    private func substituteKeyInMethod(method: String, key: String, value: String) -> String? {
        
        NSLog(method)
        
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
}

// MARK:  - Table Data Source
extension ChatViewController {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let fc = fetchedResultsController{
            return (fc.sections?.count)!;
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MessageCell
        let message = fetchedResultsController?.objectAtIndexPath(indexPath) as! Content
        
        cell.senderLab?.text = message.sender
        cell.messageLab?.text = message.body
        cell.messageLab?.numberOfLines = 0
        cell.dateLab?.text = message.date
        
        if message.sender == "Flo" {
            cell.senderLab?.textColor = UIColor(red: 0/255.0, green: 175/255.0, blue: 240/255.0, alpha: 1.0)
            cell.barLab?.textColor = UIColor(red: 0/255.0, green: 175/255.0, blue: 240/255.0, alpha: 1.0)
            cell.dateLab?.textColor = UIColor(red: 0/255.0, green: 175/255.0, blue: 240/255.0, alpha: 1.0)
//            cell.backgroundColor = UIColor(red: 252/255.0, green: 252/255.0, blue: 252/255.0, alpha: 1.0)
        }
        
        return cell;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fc = fetchedResultsController{
            return fc.sections![section].numberOfObjects;
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let fc = fetchedResultsController{
            return fc.sections![section].name;
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if let fc = fetchedResultsController{
            return fc.sectionForSectionIndexTitle(title, atIndex: index)
        } else {
            return 0
        }
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if let fc = fetchedResultsController{
            return  fc.sectionIndexTitles
        } else {
            return nil
        }
    }
    
    func scrollToBottom() {
        if (self.tableView.contentSize.height > self.tableView.frame.size.height) {
            let offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
            self.tableView.setContentOffset(offset, animated:true)
        }
    }
}

// MARK:  - Fetches
extension ChatViewController {
    
    func executeSearch(){
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError{
                NSLog("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}

// MARK:  - Delegate
extension ChatViewController: NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                    atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        let set = NSIndexSet(index: sectionIndex)
        
        switch (type) {
            
        case .Insert:
            tableView.insertSections(set, withRowAnimation: .Fade)
            
        case .Delete:
            tableView.deleteSections(set, withRowAnimation: .Fade)
            
        default:
            // irrelevant in our case
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController,
            didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
            forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch(type){
            
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}

extension ChatViewController {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL) {
            _ = Selector("videoWasSavedSuccessfully:didFinishSavingWithError:context:")
                let videoData = NSData(contentsOfURL: pickedVideo)
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let documentDirectory: AnyObject = paths[0]
            let dataPath = documentDirectory.stringByAppendingPathComponent("videoCapture")
                videoData?.writeToFile(dataPath, atomically: false)
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(false, completion: nil)
    }
}

extension ChatViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}