//
//  ViewController.swift
//  textDemo
//
//  Created by xlx on 15/4/28.
//  Copyright (c) 2015年 xlx. All rights reserved.
//

import UIKit
import AssetsLibrary
import MobileCoreServices
import MessageUI

class ViewController: UIViewController,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,MFMailComposeViewControllerDelegate{

    @IBOutlet weak var aaa: NSLayoutConstraint!
    @IBOutlet weak var helpview: UIView!
    @IBOutlet weak var textview: UITextView!

    var fontSize    = 20

    var sharelayout:UIView!
    var lay:UIView!
    var lay2:UIView!
    var tapSingle:UITapGestureRecognizer!
    /// 记录每次改变时的长度
    var lengthRange = 0
    
    var underline = false
    var obliqueness = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textview.delegate=self
        textview.typingAttributes[NSObliquenessAttributeName] = 0
        self.textview.typingAttributes[NSUnderlineStyleAttributeName] = 0
        
    }
    /**
    分享功能
    制作长图片以后分享到微信
    
    :param: sender
    */
    @IBAction func share(sender: AnyObject) {
        var alertController = UIAlertController(title: "分享", message: "只能制作长图片进行分享", preferredStyle: UIAlertControllerStyle.ActionSheet)
        var cancelAction    = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        var archiveAction   = UIAlertAction(title: "制作长图片", style: UIAlertActionStyle.Default, handler: {(UIAlertAction)-> Void in
            self.shareTOweixin()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(archiveAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        var popover = alertController.popoverPresentationController
        if (popover != nil){
            popover?.sourceView               = sender as! UIView
            popover?.sourceRect               = sender.bounds
            popover?.permittedArrowDirections = UIPopoverArrowDirection.Any
        }
    }
    /**
    通过截图制作长图片
    
    :returns: 返回长图片
    */
    func madelongPicture() -> UIImage {

        var image : UIImage!
        UIGraphicsBeginImageContext(self.textview.contentSize)
        var savedContentOffset      = self.textview.contentOffset
        var savedFrame              = self.textview.frame
        self.textview.contentOffset = CGPointZero
        self.textview.frame         = CGRectMake(0, 0, self.textview.contentSize.width, self.textview.contentSize.height)
        self.textview.layer.renderInContext(UIGraphicsGetCurrentContext())
        image                       = UIGraphicsGetImageFromCurrentImageContext()
        self.textview.contentOffset = savedContentOffset
        self.textview.frame         = savedFrame
        UIGraphicsEndPDFContext()
        return image
    }
    /**
    添加一个阴影层，并制作了微信分享的图标
    */
    func shareTOweixin(){
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
        self.sharelayout                  = UIView(frame: self.view!.frame)
        self.view!.addSubview(sharelayout)
        sharelayout.backgroundColor       = nil
        lay                               = UIView(frame: self.view!.frame)
        self.sharelayout.addSubview(lay)
        lay.backgroundColor               = UIColor.blackColor()
        lay.alpha                         = 0.1

        lay2                              = UIView(frame: CGRectMake(0, self.view!.bounds.height/7*6, self.view!.bounds.width, self.view!.bounds.height/7))
        lay2.backgroundColor              = UIColor.whiteColor()
        self.sharelayout.addSubview(lay2)
        var weixin                        = UIButton(frame: CGRectMake(0, 0, self.view!.bounds.height/7, self.view!.bounds.height/7))
        weixin.setImage(UIImage(named: "weixin.png"), forState: UIControlState.Normal)
        lay2.addSubview(weixin)
        var pengyouquan                   = UIButton(frame: CGRectMake(self.view!.bounds.height/7,0, self.view!.bounds.height/7, self.view!.bounds.height/7))
        pengyouquan.setImage(UIImage(named: "pengyouquan.png"), forState: UIControlState.Normal)
        lay2.addSubview(pengyouquan)

        let mapTranslate                  = JNWSpringAnimation(keyPath: "transform.translation.y")
        mapTranslate.damping              = 20
        mapTranslate.stiffness            = 5
        mapTranslate.mass                 = 1
        mapTranslate.fromValue            = self.view!.bounds.height/7
        mapTranslate.toValue              = 0
        lay2.layer.addAnimation(mapTranslate, forKey: mapTranslate.keyPath)
        insertBlurView(sharelayout,style: UIBlurEffectStyle.Dark)
        tapSingle                         = UITapGestureRecognizer(target: self, action: "tap")
        tapSingle.numberOfTapsRequired    = 1
        tapSingle.numberOfTouchesRequired = 1
        self.sharelayout.addGestureRecognizer(tapSingle)

    }
    /**
    模糊图片效果
    
    :param: view  需要进行模糊处理的View
    :param: style 模糊类型
    */
    func insertBlurView (view: UIView,  style: UIBlurEffectStyle) {
        view.backgroundColor = UIColor.clearColor()
        var blurEffect       = UIBlurEffect(style: style)
        var blurEffectView   = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.insertSubview(blurEffectView, atIndex: 0)
    }
    /**
    点击阴影层收起微信分享图标
    */
    func tap(){
        let mapTranslate       = JNWSpringAnimation(keyPath: "transform.translation.y")
        mapTranslate.damping   = 20
        mapTranslate.stiffness = 5
        mapTranslate.mass      = 1
        mapTranslate.fromValue = 0
        mapTranslate.toValue   = self.view.bounds.height/7
        lay2.layer.addAnimation(mapTranslate, forKey: mapTranslate.keyPath)
        lay2.transform         = CGAffineTransformTranslate(lay2.transform, 0,self.view.bounds.height)


        var  minseconds        = 0.6*Double(NSEC_PER_SEC)
        var dtime              = dispatch_time(DISPATCH_TIME_NOW, Int64(minseconds))

        UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {()->Void in
            
            self.lay.alpha     = 0
            }, completion: nil)



        dispatch_after(dtime,dispatch_get_main_queue(),{
            self.sharelayout.removeFromSuperview()
        })
    }
    /**
    调用系统邮件功能
    
    :param: sender
    */
    @IBAction func email(sender: AnyObject) {
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
        var configuredMailComposeViewController = MailComposeViewController()
        if canSendMail() {
            presentViewController(configuredMailComposeViewController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }

    func MailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC                 = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        mailComposerVC.setToRecipients(nil)
        mailComposerVC.setSubject(nil)
        mailComposerVC.setMessageBody(self.textview.text, isHTML: false)
        var addPic                         = self.madelongPicture()
        var imageData                      = UIImagePNGRepresentation(addPic)
        mailComposerVC.addAttachmentData(imageData, mimeType: "", fileName: "longPicture.png")
        return mailComposerVC
    }
    func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }


    /**
    添加图片
    
    :param: sender
    */
    @IBAction func photeSelect(sender: AnyObject) {
        var sheet:UIActionSheet
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            sheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从相册选择", "拍照")
        }else{
            sheet = UIActionSheet(title:nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "从相册选择")
        }
        sheet.showInView(self.view)
    }
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if(buttonIndex != 0){
            if(buttonIndex==1){                //相册
                sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            }else{
                sourceType = UIImagePickerControllerSourceType.Camera
            }
                let imagePickerController:UIImagePickerController = UIImagePickerController()
                imagePickerController.delegate                    = self
                imagePickerController.allowsEditing               = true//true为拍照、选择完进入图片编辑模式
                imagePickerController.sourceType                  = sourceType
                self.presentViewController(imagePickerController, animated: true, completion: {
            })
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
        var string                                                    = NSMutableAttributedString(attributedString: self.textview.attributedText)
        var img                                                       = info[UIImagePickerControllerEditedImage] as! UIImage
        img                                                           = self.scaleImage(img)

        var textAttachment                                            = NSTextAttachment()
        textAttachment.image                                          = img

        var textAttachmentString                                      = NSAttributedString(attachment: textAttachment)
        var countString:Int                                           = count(self.textview.text) as Int
      //  string.insertAttributedString(textAttachmentString, atIndex: countString)

        string.appendAttributedString(textAttachmentString)

        var storage                                                   = NSTextStorage(attributedString: string)
        var layoutmanage                                              = NSLayoutManager()
        var container                                                 = NSTextContainer(size: self.textview.frame.size)
        layoutmanage.addTextContainer(container)
        storage.addLayoutManager(layoutmanage)
        layoutmanage.textStorage                                      = storage
        var y                                                         = self.textview.contentOffset.y
        var te                                                        = UITextView(frame: self.textview.frame, textContainer: container)
        self.view.addSubview(te)
        self.textview                                                 = te
        self.textview.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        textview.typingAttributes[NSObliquenessAttributeName]         = 0
        self.textview.typingAttributes[NSUnderlineStyleAttributeName] = 0
        self.textview.typingAttributes[NSFontAttributeName]           = UIFont.systemFontOfSize((CGFloat)(self.fontSize))
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    func scaleImage(image:UIImage)->UIImage{
        UIGraphicsBeginImageContext(CGSizeMake(self.view.bounds.size.width, image.size.height*(self.view.bounds.size.width/image.size.width)))
        image.drawInRect(CGRectMake(0, 0, self.view.bounds.size.width, image.size.height*(self.view.bounds.size.width/image.size.width)))
        var scaledimage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledimage
    
    }
    func imagePickerControllerDidCancel(picker:UIImagePickerController)    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    /**
    注册通知，检测键盘弹出
    
    :param: animated
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleKeyboardDidShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleKeyboardDidHidden"), name:UIKeyboardWillHideNotification, object: nil)
    }
 
    /**
    字体减小
    
    :param: sender
    */
    @IBAction func fontincrease(sender: AnyObject) {
        self.fontSize -= 2
        self.textview.typingAttributes[NSFontAttributeName] = UIFont.systemFontOfSize((CGFloat)(self.fontSize))
    }
    /**
    字体增大

    :param: sender
    */
    @IBAction func fontdecase(sender: AnyObject) {
        self.fontSize += 2
        self.textview.typingAttributes[NSFontAttributeName] = UIFont.systemFontOfSize((CGFloat)(self.fontSize))

    }
    /**
    设置斜体

    :param: sender
    */
    @IBAction func Obliqueness(sender: AnyObject) {
        self.obliqueness = self.obliqueness == false ? true : false
        textview.typingAttributes[NSObliquenessAttributeName] = (textview.typingAttributes[NSObliquenessAttributeName] as? NSNumber) == 0 ? 0.5 : 0
    }
    /**
    设置下划线
    
    :param: sendersd
    */
    @IBAction func underline(sender: AnyObject) {
        self.underline = self.underline == false ? true : false
        self.textview.typingAttributes[NSUnderlineStyleAttributeName] =  (self.textview.typingAttributes[NSUnderlineStyleAttributeName] as? NSNumber) == 0 ? 1 : 0
    }
    /**
    设置字体，这个字体叫做‘骚气无敌，情根深种’。～～～～～～～
    
    :param: sender 
    */
    @IBAction func font(sender: AnyObject) {
        UIApplication.sharedApplication().keyWindow?.endEditing(true)
        self.sharelayout     = UIView(frame: self.view!.frame)
        self.view!.addSubview(sharelayout)
        self.textview.font   = UIFont(name: "1-", size: (CGFloat)(self.fontSize))
        self.insertBlurView(self.sharelayout, style: UIBlurEffectStyle.Light)
        var love             = UIButton(frame: CGRectMake(0, 0, 100, 30))
        love.setTitle("情根深种", forState: UIControlState.Normal)
        love.backgroundColor = UIColor.grayColor()
        love.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        love.addTarget(self, action: "lovefont:", forControlEvents: UIControlEvents.TouchUpInside)
        love.center          = self.view.center
        self.view.addSubview(love)
    }
    func lovefont(sender:AnyObject){
        self.sharelayout.removeFromSuperview()
        sender.removeFromSuperview()
        self.textview.typingAttributes[NSFontAttributeName] = UIFont(name: "1-", size: (CGFloat)(self.fontSize))
    }

 
    /**
    检测键盘弹出
    
    :param: paramNotification
    */
    func handleKeyboardDidShow(paramNotification:NSNotification){


        var userinfo:NSDictionary=(NSDictionary)(dictionary: paramNotification.userInfo!)
        var v:NSValue              = userinfo.objectForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue

        var keyboardRect           = v.CGRectValue()
        self.textview.contentInset = UIEdgeInsetsMake(0, 0, keyboardRect.size.height+50, 0)
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                self.aaa.constant  = keyboardRect.size.height
                self.view.layoutIfNeeded()
            }, completion:nil)
    }
    /**
    检测键盘收起
    */
    func handleKeyboardDidHidden(){
        self.textview.contentInset         = UIEdgeInsetsZero
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: nil, animations: { () -> Void in
                self.aaa.constant          = 0
            }, completion:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

