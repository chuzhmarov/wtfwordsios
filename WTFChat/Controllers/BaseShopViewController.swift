//
//  ShopViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 14/12/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class BaseShopViewController: UITableViewController {
    
    @IBOutlet weak var freeHintsLabel: UILabel!
    @IBOutlet weak var freeHintsBuyLabel: UILabel!
    
    @IBOutlet weak var hints1Label: UILabel!
    @IBOutlet weak var hints1BuyLabel: UILabel!
    @IBOutlet weak var hints2Label: UILabel!
    @IBOutlet weak var hints2BuyLabel: UILabel!
    @IBOutlet weak var hints3Label: UILabel!
    @IBOutlet weak var hints3BuyLabel: UILabel!
    @IBOutlet weak var hints4Label: UILabel!
    @IBOutlet weak var hints4BuyLabel: UILabel!
    @IBOutlet weak var hints5Label: UILabel!
    @IBOutlet weak var hints5BuyLabel: UILabel!
    @IBOutlet weak var hints6Label: UILabel!
    @IBOutlet weak var hints6BuyLabel: UILabel!
    
    var detailColor: UIColor!
    var tintColor: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailColor = freeHintsBuyLabel.textColor
        tintColor = self.view.tintColor
        
        // Subscribe to a notification that fires when a product is purchased.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchased:", name: IAPHelperProductPurchasedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchasedError:", name: IAPHelperProductPurchasedErrorNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        updateTable()
    }
    
    func productPurchased(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateTable()
        })
    }
    
    func productPurchasedError(notification: NSNotification) {
        if (notification.object != nil) {
            let productIdentifier = notification.object as! String
            
            if let productTitle = inAppService.getProductTitle(productIdentifier) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.updateTable()
                    
                    WTFOneButtonAlert.show("Error",
                        message: productTitle + " purchase error",
                        firstButtonTitle: "Ok",
                        viewPresenter: self)
                })
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.updateTable()
                
                WTFOneButtonAlert.show("Error",
                    message: "Unknown error occured",
                    firstButtonTitle: "Ok",
                    viewPresenter: self)
            })
        }
    }
    
    func updateTable() {
        setBuyLabels(hints1Label, buyTitle: hints1BuyLabel, productId: IAPProducts.HINTS_1)
        setBuyLabels(hints2Label, buyTitle: hints2BuyLabel, productId: IAPProducts.HINTS_2)
        setBuyLabels(hints3Label, buyTitle: hints3BuyLabel, productId: IAPProducts.HINTS_3)
        setBuyLabels(hints4Label, buyTitle: hints4BuyLabel, productId: IAPProducts.HINTS_4)
        setBuyLabels(hints5Label, buyTitle: hints5BuyLabel, productId: IAPProducts.HINTS_5)
        setBuyLabels(hints6Label, buyTitle: hints6BuyLabel, productId: IAPProducts.HINTS_6)

        self.tableView.reloadData()
    }
    
    func setBuyLabels(title: UILabel, buyTitle: UILabel, productId: ProductIdentifier) {
        title.text = inAppService.getProductTitle(productId)
        buyTitle.text = inAppService.getProductPrice(productId)
        
        if inAppService.canPurchase(productId) && !inAppService.isPurchased(productId) {
            buyTitle.textColor = tintColor
        } else {
            buyTitle.textColor = detailColor
        }
    }
    
    func showPurchaseAlert(productId: ProductIdentifier) {
        inAppService.showBuyAlert(productId, viewPresenter: self)
    }
}