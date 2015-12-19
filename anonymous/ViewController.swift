//
//  ViewController.swift
//  anonymous
//
//  Created by Zhongcai Ng on 18/12/15.
//  Copyright © 2015 Cloudilly Private Limited. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, CloudillyDelegate {
    var width: CGFloat!
    var height: CGFloat!
    var msgsTableView: UITableView!
    var msgs: NSMutableArray!
    var bottom: UIView!
    var field: UITextField!
    var cloudilly: Cloudilly!

    convenience init() {
        self.init(nibName:nil, bundle:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        self.msgs = []
        self.cloudilly = Cloudilly(app: "<INSERT YOUR APP NAME>", andAccess: "<INSERT YOUR ACCESS KEY>", withCallback: {
            self.addMsg("CONNECTING...")
            self.cloudilly.connect()
        })
        self.cloudilly.addDelegate(self)
    }
    
    override func loadView() {
        self.width = UIScreen.mainScreen().bounds.size.width
        self.height = UIScreen.mainScreen().bounds.size.height
        view = UIView(frame: CGRectMake(0.0, 0.0, self.width, self.height))
        view.backgroundColor = UIColor.whiteColor()
        
        let status = UIView(frame: CGRectMake(0.0, 0.0, self.width, 20.0))
        status.backgroundColor = UIColor.blackColor()
        view.addSubview(status)
        
        let top = UIView(frame: CGRectMake(0.0, 20.0, self.width, 50.0))
        top.backgroundColor = UIColor.blackColor()
        view.addSubview(top)
        
        let title = UILabel(frame: CGRectMake(0.0, 26.0, self.width, 36.0))
        title.font = UIFont(name: "ChalkboardSE-Bold", size: 22.0)
        title.backgroundColor = UIColor.clearColor()
        title.textAlignment = NSTextAlignment.Center
        title.textColor = UIColor.whiteColor()
        title.text = "Cloudilly"
        view.addSubview(title)
        
        self.msgsTableView = UITableView(frame: CGRectMake(0.0, 70.0, self.width, self.height - 120.0), style: UITableViewStyle.Plain)
        self.msgsTableView.backgroundColor = UIColor.whiteColor()
        self.msgsTableView.delegate = self
        self.msgsTableView.dataSource = self
        self.msgsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        view.addSubview(self.msgsTableView)
        
        self.bottom = UIView(frame: CGRectMake(0.0, self.height - 50.0, self.width, 50.0))
        self.bottom.userInteractionEnabled = true
        self.bottom.backgroundColor = UIColor.grayColor()
        view.addSubview(self.bottom)
        
        let text = UIView(frame: CGRectMake(5.0, 5.0, self.width - 70.0, 40.0))
        text.backgroundColor = UIColor.whiteColor()
        self.bottom.addSubview(text)
        
        self.field = UITextField(frame: CGRectMake(10.0, 0.0, self.width - 80.0, 40.0))
        self.field.keyboardAppearance = UIKeyboardAppearance.Dark
        self.field.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        self.field.autocorrectionType = UITextAutocorrectionType.Yes
        self.field.font = UIFont.systemFontOfSize(22.0)
        self.field.returnKeyType = UIReturnKeyType.Send
        self.field.delegate = self
        text.addSubview(self.field)

        let sendBtn = UIButton(type: UIButtonType.Custom)
        sendBtn.addTarget(self, action: "fireSend", forControlEvents: UIControlEvents.TouchUpInside)
        sendBtn.setTitle("Send", forState: UIControlState.Normal)
        sendBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        sendBtn.titleLabel?.font = UIFont(name: "AvenirNextCondensed-DemiBold", size: 22.0)
        sendBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        sendBtn.frame = CGRectMake(self.width - 60.0, 0.0, 60.0, 50.0)
        self.bottom.addSubview(sendBtn)
        view.addSubview(self.bottom)
    }
    
    func fireSend() {
        if(self.field.text!.characters.count == 0) { return }
        let payload: NSMutableDictionary = ["msg": self.field.text!]
        self.cloudilly.postGroup("public", withPayload: payload, withCallback: { dict in
            if((dict["status"]!.isEqualToString("fail"))) { print(dict["msg"]); return; }
            print("@@@@@@ POST " + String(dict))
        })
        self.field.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(self.field.text!.characters.count == 0) { return false }
        let payload: NSMutableDictionary = ["msg": self.field.text!]
        self.cloudilly.postGroup("public", withPayload: payload, withCallback: { dict in
            if((dict["status"]!.isEqualToString("fail"))) { print(dict["msg"]); return; }
            print("@@@@@@ POST " + String(dict))
        })
        self.field.text = ""
        return false
    }
    
    func returnMsgHeight(msg: String) -> CGFloat {
        let attributeNormal = [NSFontAttributeName : UIFont.systemFontOfSize(18.0)]
        return msg.boundingRectWithSize(CGSizeMake(width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributeNormal, context: nil).size.height
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let msg = msgs.objectAtIndex(indexPath.row) as! String
        return indexPath.row == 0 ? self.returnMsgHeight(msg) + 20.0 : self.returnMsgHeight(msg) + 10.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.msgs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL")
        if(cell == nil) { cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL") }
        cell!.textLabel!.text = (self.msgs.objectAtIndex(indexPath.row) as! String)
        cell!.textLabel!.numberOfLines = 0
        return cell!
    }
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo! as NSDictionary).objectForKey(UIKeyboardFrameEndUserInfoKey)!.CGRectValue
        let keyboardHeight = self.height - keyboardFrame.origin.y
        let duration = (notification.userInfo! as NSDictionary).objectForKey(UIKeyboardAnimationDurationUserInfoKey)!.doubleValue
        UIView.animateWithDuration(duration, animations: {
            self.msgsTableView.frame = CGRectMake(0.0, 70.0, self.width, self.height - 70.0 - 49.0 - keyboardHeight)
            self.bottom.frame = CGRectMake(0.0, self.height - 50.0 - keyboardHeight, self.width, 50.0)
            self.scrollToBottom()
        })
    }
    
    func scrollToBottom() {
        if(self.msgsTableView.contentSize.height < self.msgsTableView.frame.size.height) { return; }
        let delayInSeconds = 0.1
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue(), {
            let offset = CGPointMake(0.0, self.msgsTableView.contentSize.height - self.msgsTableView.frame.size.height)
            self.msgsTableView.setContentOffset(offset, animated: true)
        })
    }
    
    func addMsg(msg: NSString) {
        self.msgs.addObject(msg)
        self.msgsTableView.reloadData()
        self.scrollToBottom()
    }
    
    func socketConnected(dict: [NSObject : AnyObject]!) {
        if((dict["status"]!.isEqualToString("fail"))) { print(dict["msg"]); return; }
        print("@@@@@@ CONNECTED " + String(dict))
        
        self.addMsg("CONNECTED AS " + (dict["device"] as! String).uppercaseString)
        self.cloudilly.joinGroup("public", withCallback: { dict in
            if((dict["status"]!.isEqualToString("fail"))) { print(dict["msg"]); return; }
            print("@@@@@@ JOIN " + String(dict))
            self.addMsg("DEVICE PRESENT IN PUBLIC " + "\(dict["total_devices"] as! NSNumber)")
        })
    }
    
    func socketDisconnected() {
        print("@@@@@@ DISCONNECTED")
        msgs.removeAllObjects()
        self.msgs.addObject("DISCONNECTED")
    }
    
    func socketReceivedDevice(dict: [NSObject : AnyObject]!) {
        print("@@@@@@ RECEIVED DEVICE " + String(dict))
        let other = (dict["device"] as! String).uppercaseString
        let action = (dict["timestamp"] as! NSNumber).isEqualToNumber(NSNumber.init(int: 0)) ? "JOINED" : "LEFT"
        self.addMsg(other + " " + action + " PUBLIC")
    }
    
    func socketReceivedPost(dict: [NSObject : AnyObject]!) {
        print("@@@@@@ RECEIVED POST " + String(dict))
        let other = (dict["device"] as! String).uppercaseString
        self.addMsg(other + ": " + (dict["payload"]!["msg"] as! String))
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle { return UIStatusBarStyle.LightContent }
    override func viewDidLoad() { super.viewDidLoad() }
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
}