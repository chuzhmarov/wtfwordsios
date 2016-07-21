import Foundation

class WTFOneButtonAlert: NSObject, UIAlertViewDelegate  {
    static let CON_ERR = "%conError%"
    private static let connectionErrorDescription = "Internet connection problem"

    class func show(title: String, message: String, firstButtonTitle: String, alertButtonAction:(() -> Void)? = nil) {
        
        //if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title,
                message: message.replace(CON_ERR, with: connectionErrorDescription),
                preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: firstButtonTitle, style: .Default, handler: { (action: UIAlertAction) in
                alertButtonAction?()
            }))

            let rootViewController: UIViewController = UIApplication.sharedApplication().windows.last!.rootViewController!
            rootViewController.presentViewController(alert, animated: true, completion: nil)
        /*} else {
            let alert = AlertWithDelegate()
            alert.title = title
            alert.message = message
            alert.addButtonWithTitle(firstButtonTitle)
            alert.setAlertFunction(alertButtonAction)
            alert.show()
        }*/
    }
}

class WTFTwoButtonsAlert: NSObject, UIAlertViewDelegate {
    class func show(title: String, message: String, firstButtonTitle: String, secondButtonTitle: String, alertButtonAction:(() -> Void)?) {
        
        return WTFTwoButtonsAlert.show(title, message: message, firstButtonTitle: firstButtonTitle, secondButtonTitle: secondButtonTitle, alertButtonAction: alertButtonAction, cancelButtonAction: nil)
    }
    
    class func show(title: String, message: String, firstButtonTitle: String, secondButtonTitle: String, alertButtonAction:(() -> Void)?, cancelButtonAction:(() -> Void)?) {
        
        //if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title,
                message: message,
                preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: firstButtonTitle, style: .Default, handler: { (action: UIAlertAction) in
                alertButtonAction?()
            }))
            
            alert.addAction(UIAlertAction(title: secondButtonTitle, style: .Default, handler: { (action: UIAlertAction) in
                cancelButtonAction?()
            }))

            let rootViewController: UIViewController = UIApplication.sharedApplication().windows.last!.rootViewController!
            rootViewController.presentViewController(alert, animated: true, completion: nil)
        /*} else {
            let alert = AlertWithDelegate()
            alert.title = title
            alert.message = message
            alert.addButtonWithTitle(firstButtonTitle)
            alert.addButtonWithTitle(secondButtonTitle)
            alert.setAlertFunction(alertButtonAction)
            alert.setCancelFunction(cancelButtonAction)
            alert.show()
        }*/
    }
}

class AlertWithDelegate: UIAlertView, UIAlertViewDelegate {
    var alertButtonAction: (() -> Void)?
    var cancelButtonAction: (() -> Void)?
    
    func setAlertFunction(alertButtonAction: (() -> Void)?) {
        self.alertButtonAction = alertButtonAction
        self.delegate = self
    }
    
    func setCancelFunction(cancelButtonAction: (() -> Void)?) {
        self.cancelButtonAction = cancelButtonAction
        self.delegate = self
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex{
        case 0:
            alertButtonAction?()
            break;
        case 1:
            cancelButtonAction?()
            break;
        default:
            //Do nothing
            break;
        }
    }
}