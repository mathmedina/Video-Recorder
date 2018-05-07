//
//  MenuTransitionManager.swift
//


import UIKit


//Classe que gerencia transição do menu lateral
class MenuTransitionManager: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    fileprivate var presenting = false
    fileprivate var interactive = false
    
    fileprivate var enterPanGesture: UIPanGestureRecognizer!
    
    var sourceViewController: CameraViewController! {
        didSet {
            self.enterPanGesture = UIPanGestureRecognizer()
            self.enterPanGesture.addTarget(self, action:#selector(handleOnstagePan))
            self.sourceViewController.view.addGestureRecognizer(self.enterPanGesture)
            
            
            
            // add to window rather than view controller
        }
    }
    
    fileprivate var exitPanGesture: UIPanGestureRecognizer!
    
    var feedViewController: FeedViewController! {
        didSet {
            self.exitPanGesture = UIPanGestureRecognizer()
            self.exitPanGesture.addTarget(self, action:#selector(handleOffstagePan))
            self.feedViewController.view.addGestureRecognizer(self.exitPanGesture)
        }
    }
    
    @objc func handleOnstagePan(_ pan: UIPanGestureRecognizer){
        // how much distance have we panned in reference to the parent view?
        let translation = pan.translation(in: pan.view!)
        
        // do some math to translate this to a percentage based value
        let d =  translation.x / pan.view!.bounds.width * 0.5
        
        // now lets deal with different states that the gesture recognizer sends
        switch (pan.state) {
            
        case UIGestureRecognizerState.began:
            // set our interactive flag to true
            self.interactive = true
            
            // trigger the start of the transition
            self.sourceViewController.performSegue(withIdentifier: "presentFeed", sender: self)
            break
            
        case UIGestureRecognizerState.changed:
            
            // update progress of the transition
            self.update(d)
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            
            // return flag to false and finish the transition
            self.interactive = false
            if(d > 0.2){
                // threshold crossed: finish
                self.finish()
            }
            else {
                // threshold not met: cancel
                self.cancel()
            }
        }
    }
    
    @objc func handleOffstagePan(_ pan: UIPanGestureRecognizer){
        
        let translation = pan.translation(in: pan.view!)
        let d =  translation.x / pan.view!.bounds.width * -0.5
        
        switch (pan.state) {
            
        case UIGestureRecognizerState.began:
            self.interactive = true
            self.feedViewController.performSegue(withIdentifier: "dismiss", sender: self)
            break
            
        case UIGestureRecognizerState.changed:
            self.update(d)
            break
            
        default: // .Ended, .Cancelled, .Failed ...
            self.interactive = false
            if(d > 0.1){
                self.finish()
            }
            else {
                self.cancel()
            }
        }
    }
    
    // MARK: UIViewControllerAnimatedTransitioning protocol methods
    
    // animate a change from one viewcontroller to another
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView
        
        // create a tuple of our screens
        let screens : (from:UIViewController, to:UIViewController) = (transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!, transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!)
        
        // assign references to our menu view controller and the 'bottom' view controller from the tuple
        // remember that our menuViewController will alternate between the from and to view controller depending if we're presenting or dismissing
        let feedViewController = !self.presenting ? screens.from as! FeedViewController : screens.to as! FeedViewController
        let topViewController = !self.presenting ? screens.to as UIViewController : screens.from as UIViewController
        
        let feedView = feedViewController.view
        let topView = topViewController.view
        
        // prepare menu items to slide in
        if (self.presenting){
            self.offStageMenuControllerInteractive(feedViewController) // offstage for interactive
        }
        
        // add the both views to our view controller
        
        container.addSubview(feedView!)
        container.addSubview(topView!)
        
        let duration = self.transitionDuration(using: transitionContext)
        
        // perform the animation!
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options:.curveLinear , animations: {
            
            if (self.presenting){
                feedView?.transform = CGAffineTransform.identity
                self.onStageMenuController(feedViewController) // onstage items: slide in
                topView?.transform = self.offStage((feedView?.frame.width)!)
            }
            else {
                feedView?.transform = self.offStage(0)
                topView?.transform = CGAffineTransform.identity
                self.offStageMenuControllerInteractive(feedViewController)
            }
            
        }, completion: { finished in
            
            // tell our transitionContext object that we've finished animating
            if(transitionContext.transitionWasCancelled){
                
                transitionContext.completeTransition(false)
                
                UIApplication.shared.keyWindow!.addSubview(screens.from.view)
                
            }
                
            else {
                
                transitionContext.completeTransition(true)
                // bug: same as above
                UIApplication.shared.keyWindow!.addSubview(screens.to.view)
                
                
            }
            
        })
        
    }
    
    func offStage(_ amount: CGFloat) -> CGAffineTransform {
        
        return CGAffineTransform(translationX: amount, y: 0)
        
    }
    
    func offStageMenuControllerInteractive(_ menuViewController: FeedViewController){
        
        menuViewController.view.alpha = 100
        
    }
    
    func onStageMenuController(_ menuViewController: FeedViewController){
        
        // prepare menu to fade in
        menuViewController.view.alpha = 1
        
        
    }
    
    // return how many seconds the transiton animation will take
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.5
        
    }
    
    // MARK: UIViewControllerTransitioningDelegate protocol methods
    
    // return the animator when presenting a viewcontroller
    // remember that an animator (or animation controller) is any object that aheres to the UIViewControllerAnimatedTransitioning protocol
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    
    // return the animator used when dismissing from a viewcontroller
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // if our interactive flag is true, return the transition manager object
        // otherwise return nil
        return self.interactive ? self : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
    
}
