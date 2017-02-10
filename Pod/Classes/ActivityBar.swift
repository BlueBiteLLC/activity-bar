import UIKit
//TODO FIGURE OUT IF THESE ARE NECESSARY OR WHATEVER

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class ActivityBar: UIView {
    
    //MARK: Properties
    fileprivate var bar = UIView()
    fileprivate var barLeft: NSLayoutConstraint!
    fileprivate var barRight: NSLayoutConstraint!
    fileprivate var animationTimer: Timer?
    
    //MARK: Constants
    fileprivate let duration: TimeInterval = 1
    fileprivate let waitTime: TimeInterval = 0.5
    
    //MARK: Lifecycle
    fileprivate func initializeBar() {
        super.awakeFromNib()
        
        self.bar.backgroundColor = self.color
        self.bar.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.bar)
        
        //Left and right margins from bar to container
        self.barLeft = NSLayoutConstraint(item: self.bar, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        self.addConstraint(self.barLeft)
        self.barRight = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: self.bar, attribute: .right, multiplier: 1, constant: 1)
        self.addConstraint(self.barRight!)
        
        //Align top and bottom of bar to container
        self.addConstraint(
            NSLayoutConstraint(item: self.bar, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        )
        self.addConstraint(
            NSLayoutConstraint(item: self.bar, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        )
    }
    
    func animate() {
        let toZero: NSLayoutConstraint
        let toWidth: NSLayoutConstraint
        
        if self.barRight.constant == 0 {
            toZero = self.barLeft
            toWidth = self.barRight
            self.barRight.constant = 0
            self.barLeft.constant = self.frame.size.width
        } else {
            toZero = self.barRight
            toWidth = self.barLeft
            self.barRight.constant = self.frame.size.width
            self.barLeft.constant = 0
        }
        self.layoutIfNeeded()
        
        UIView.animate(withDuration: self.duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            toZero.constant = 0
            self.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: self.duration * 0.7, delay: self.duration * 0.3, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
            toWidth.constant = self.frame.size.width
            self.layoutIfNeeded()
        }, completion:nil)
    }
    
    
    //MARK: Public
    
    /**
        Set the ActivityBar to a fixed progress.
    
        Valid values are between 0.0 and 1.0.
    
        The progress will be `nil` if the bar is currently animating.
    */
    open var progress: Float? {
        didSet {
            if self.progress != nil {
                self.stop()
                self.isHidden = false
            } else {
                self.isHidden = true
            }
            
            if self.progress > 1.0 {
                self.progress = 1.0
            } else if self.progress < 0 {
                self.progress = 0
            }
            
            if let progress = self.progress {
                UIView.animate(withDuration: self.duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [], animations: {
                    self.barLeft.constant = 0
                    self.barRight.constant = self.frame.size.width - (CGFloat(progress) * self.frame.size.width)
                    self.layoutIfNeeded()
                }, completion: nil)
            }
            
        }
    }
    
    /**
         The tint color of the ActivityBar.
         
         Defaults to the parent UIView's tint color.
     */
    open var color = UIColor.black {
        didSet {
            self.bar.backgroundColor = self.color
        }
    }
    
    /**
        Starts animating the ActivityBar.
    
        Call `.stop()` to stop.
    */
    open func start() {
        self.stop()
        
        self.barRight.constant = self.frame.size.width - 1
        self.layoutIfNeeded()
        
        self.isHidden = false
        
        self.animationTimer = Timer.scheduledTimer(timeInterval: self.duration + self.waitTime, target: self, selector: #selector(ActivityBar.animate as (ActivityBar) -> () -> ()), userInfo: nil, repeats: true)
        self.animate()
    }
    
    /**
         Stops animating the ActivityBar.
     
         Call `.start()` to start.
     */
    open func stop() {
        self.animationTimer?.invalidate()
        self.animationTimer = nil
    }
    
    //MARK: Class
    
    /**
        Adds an ActivityBar to the supplied view controller.
    
        The added ActivityBar is returned.
    */
    open class func addTo(_ viewController: UIViewController) -> ActivityBar {
        let activityBar = ActivityBar()
        
        activityBar.alpha = 0.8
        
        var topOffset: CGFloat = 20
        
        let view: UIView
        let xLayout: NSLayoutConstraint
        
        if let navigationBar = viewController.navigationController?.navigationBar {
            topOffset += navigationBar.frame.size.height
            
            view = navigationBar
            xLayout = NSLayoutConstraint(item: activityBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -2)
        } else {
            view = viewController.view
            xLayout = NSLayoutConstraint(item: activityBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: topOffset)
        }
        
        activityBar.translatesAutoresizingMaskIntoConstraints = false
        activityBar.isHidden = true
        
        view.addSubview(activityBar)
        
        //Height = 2
        activityBar.addConstraint(
            NSLayoutConstraint(item: activityBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 2)
        )
        
        //Insert view at top with top offset
        view.addConstraint(
            xLayout
        )
        
        //Left and right align view to superview
        view.addConstraint(
            NSLayoutConstraint(item: activityBar, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        )
        view.addConstraint(
            NSLayoutConstraint(item: activityBar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        )
        
        activityBar.initializeBar()
        
        activityBar.color = viewController.view.tintColor
        
        return activityBar
    }
    
    
}
