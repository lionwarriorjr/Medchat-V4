//
//  MyPlanViewController.swift
//  Medchat
//
//  Created by Srihari Mohan on 5/21/16.
//  Copyright © 2016 Srihari Mohan. All rights reserved.
//

import UIKit

class MyPlanViewController: UIViewController, UINavigationControllerDelegate,
    UIViewControllerAnimatedTransitioning, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var circleSeg: UIButton!
    @IBOutlet weak var medsTableView: UITableView!
    @IBOutlet weak var planTableView: UITableView!
    @IBOutlet var contacts: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var interactionController: UIPercentDrivenInteractiveTransition?
    weak var transitionContext: UIViewControllerContextTransitioning?
    var meds = ["Levothyroxine (Synthroid)", "Regular Multivitamins"]
    var instructions = ["Take this capsule in the morning on an empty stomach. Wait at least 30 to 60 minutes before you eat any food. In the case you miss a dose, skip it and resume your regular dosing schedule. Do not take a double dose to make up for a missed one.","Take twice a day, once in the morning and once in the evening to help get your body its necessary nutrients and better absorb the benefits of your medication."]
    var doses = [50,10]
    var freq = [1,2]
    var treatments = ["Treatment should begin at 50mg","Dosage should reach max of 75mg after 5 weeks", "1 hour of light cardiovascular exercise per day","Meet once a week with your cognitive therapist Dr. Weiss","Gradually increase caloric intake once every 2 weeks"]
    var goals = ["To reduce the size of your enlarged thyroid gland and restore production of your thyroid hormone, necessary to restore your hormonal balance.", "To significantly boost thyroid hormone production and help ease your fatigue.", "To regain your appetite and restore your heart rate to its natural rhythm.","To better cope with the irritability and mood swings you reported having recently. Your therapy will also help us better monitor your cognitive progress as the effects of your hypothyroidism wear off.","To quicken the treatment process by introducing a more nutritious diet back into your lifestyle."]
    var goalDates = ["5 weeks","2 months","Always","1.5 months","2 months"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        if appDelegate.button == nil {
            appDelegate.button = self.circleSeg
        }
        contacts.target = self.revealViewController()
        contacts.action = #selector(SWRevealViewController.rightRevealToggle(_:))
        medsTableView.tableFooterView = UIView()
        planTableView.tableFooterView = UIView()
        medsTableView.backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)
        planTableView.backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)
        navBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 0/255.0, green: 142/255.0, blue: 204/255.0, alpha: 1.0), NSFontAttributeName : UIFont(name: "Noteworthy-bold", size: 18)!]
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.delegate = self
        if appDelegate.button == nil {
            appDelegate.button = self.circleSeg
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
            self.navigationController?.delegate = nil
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        //1
        self.transitionContext = transitionContext
        
        //2
        let containerView = transitionContext.containerView()
        _ = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! TabBarViewController
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! DataViewController
        
        //3
        containerView!.addSubview(toViewController.view)
        
        //4
        let circleMaskPathInitial = UIBezierPath(ovalInRect: appDelegate.button!.frame)
        let extremePoint = CGPoint(x: appDelegate.button!.center.x - 0, y: appDelegate.button!.center.y - CGRectGetHeight(toViewController.view.bounds))
        let radius = sqrt((extremePoint.x*extremePoint.x) + (extremePoint.y*extremePoint.y))
        let circleMaskPathFinal = UIBezierPath(ovalInRect: CGRectInset(appDelegate.button!.frame, -radius, -radius))
        
        //5
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.CGPath
        toViewController.view.layer.mask = maskLayer
        
        //6
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.CGPath
        maskLayerAnimation.toValue = circleMaskPathFinal.CGPath
        maskLayerAnimation.duration = self.transitionDuration(transitionContext)
        maskLayerAnimation.delegate = self
        maskLayer.addAnimation(maskLayerAnimation, forKey: "path")
    }
}

extension MyPlanViewController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(MyPlanViewController.panned(_:)))
        //self.navigationController!.view.addGestureRecognizer(panGesture)
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyPlanViewController.sharedInstance()
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) ->  UIViewControllerInteractiveTransitioning? {
        return self.interactionController
    }
    
    @IBAction func panned(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        //1
        case .Began:
            self.interactionController = UIPercentDrivenInteractiveTransition()
            if self.navigationController?.viewControllers.count > 1 {
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                self.navigationController?.topViewController!.performSegueWithIdentifier("pushToData", sender: nil)
            }
            
        //2
        case .Changed:
            let translation = gestureRecognizer.translationInView(self.navigationController!.view)
            let completionProgress = translation.x/CGRectGetWidth(self.navigationController!.view.bounds)
            self.interactionController?.updateInteractiveTransition(completionProgress)
            
        //3
        case .Ended:
            if (gestureRecognizer.velocityInView(self.navigationController!.view).x > 0) {
                self.interactionController?.finishInteractiveTransition()
            } else {
                self.interactionController?.cancelInteractiveTransition()
            }
            self.interactionController = nil
            
        //4
        default:
            self.interactionController?.cancelInteractiveTransition()
            self.interactionController = nil
        }
    }
}
    
extension MyPlanViewController {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.transitionContext?.completeTransition(!self.transitionContext!.transitionWasCancelled())
        self.transitionContext?.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view.layer.mask = nil
    }
    
    class func sharedInstance() -> MyPlanViewController {
        struct Singleton {
            static var sharedInstance = MyPlanViewController()
        }
        return Singleton.sharedInstance;
    }
}

extension MyPlanViewController {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.isEqual(medsTableView) {
            return meds.count;
        } else {
            return treatments.count;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView.isEqual(medsTableView) {
            let medCell = tableView.dequeueReusableCellWithIdentifier("medsCell")
                as! MedsTableViewCell
            medCell.medType.text = meds[indexPath.row]
            medCell.doseLab.text = "\(doses[indexPath.row])mg"
            medCell.freqLab.text = "\(freq[indexPath.row])x day"
            return medCell;
        } else {
            let planCell = tableView.dequeueReusableCellWithIdentifier("treatmentCell")
                    as! TreatmentTableViewCell
            planCell.intervention.text = "\(indexPath.row+1). \(treatments[indexPath.row])"
            return planCell;
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.isEqual(medsTableView) {
            let medAlertVC = UIAlertController(title: "\(meds[indexPath.row])", message: "\(instructions[indexPath.row])", preferredStyle: .Alert)
            medAlertVC.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(medAlertVC, animated: true, completion: nil)
        } else {
            let goalsAlertVC = UIAlertController(title: "Goal (\(goalDates[indexPath.row]))", message: "\(goals[indexPath.row])", preferredStyle: .Alert)
            goalsAlertVC.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(goalsAlertVC, animated: true, completion: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
