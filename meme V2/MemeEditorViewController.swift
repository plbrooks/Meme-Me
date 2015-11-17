//
//  MemeEditorViewController.swift
//  meme V2
//
//  Created by Peter Brooks on 11/11/15.
//  Copyright © 2015 Peter Brooks. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate  {

    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topCenterTextField: UITextField!
    @IBOutlet weak var bottomCenterTextField: UITextField!
    
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancel: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var instructionLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var memeFromMemeDetail: Meme?   // used if MemeEditorVC called from MemeDetailVC
    
    let textFieldMaxChars = 25
    var topTextEntered = false
    var bottomTextEntered = false
    var topCenterTextEntered = false
    var bottomCenterTextEntered = false
    var useCenterTextFields = false
    var viewOriginalFramePositionY: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaults()  // set up text, image, and button defaults
        topTextField.delegate = self
        bottomTextField.delegate = self
        topCenterTextField.delegate = self
        bottomCenterTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        // assign top and bottom text field defaults
        let memeTextAttributes = [ // struct containing text font, color, size
            NSStrokeColorAttributeName: UIColor.blackColor(),NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 30)!,
            NSStrokeWidthAttributeName : 4.0]
        
        // set up top text field
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = NSTextAlignment.Center
        
        // set up bottom text field
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = NSTextAlignment.Center
        
        // set up top center text field
        topCenterTextField.defaultTextAttributes = memeTextAttributes
        topCenterTextField.textAlignment = NSTextAlignment.Center
        
        // set up bottom center text field
        bottomCenterTextField.defaultTextAttributes = memeTextAttributes
        bottomCenterTextField.textAlignment = NSTextAlignment.Center
        
        // show / hide text fields
        if useCenterTextFields == true {
            topTextField.hidden = true
            bottomTextField.hidden = true
            topCenterTextField.hidden = false
            bottomCenterTextField.hidden = false
        } else {
            topTextField.hidden = false
            bottomTextField.hidden = false
            topCenterTextField.hidden = true
            bottomCenterTextField.hidden = true
        }
        
        
        
        if(memeFromMemeDetail != nil) { // if MemeEditor was called from MemeDetail image exists
            // show the existing image and allow it to be editted or immediately shared
            showImage(memeFromMemeDetail!.image)
            topTextField.text = memeFromMemeDetail?.topText
            bottomTextField.text = memeFromMemeDetail?.bottomText
            topTextField.enabled = true
            bottomTextField.enabled = true
            topCenterTextField.text = memeFromMemeDetail?.topText
            bottomCenterTextField.text = memeFromMemeDetail?.bottomText
            topCenterTextField.enabled = true
            bottomCenterTextField.enabled = true
            shareButton.enabled = true
            instructionLabel.hidden = true
        }
        
        // only enable source buttons whose source type is available
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        albumButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        
        // enable keyboard processing
        subscribeToKeyboardNotifications()
        
        // track orginal view position so can compare to current view position, so don't double jump the image when data is added into both text fields one after the other
        viewOriginalFramePositionY = view.frame.origin.y
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // Toolbar buttonitems method. Both UIToolBarItems use this IBAction. TAG is used to differentiate processing
    
    @IBAction func pickAnImage(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        var sourceType: UIImagePickerControllerSourceType
        switch sender.tag { // could be more compact but use switch so easy to expand later if needed
        case 0:
            sourceType = UIImagePickerControllerSourceType.Camera
        default:
            sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        imagePicker.sourceType = sourceType
        presentViewController(imagePicker, animated: true, completion: nil)

    }

    @IBAction func shareButton(sender: UIBarButtonItem) {
        let newMeme = generateMeme()
        let objectsToShare = [newMeme]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        presentViewController(activityVC, animated: true, completion: nil)
        
        // When share is complete start from beginning
        activityVC.completionWithItemsHandler = {
            (activity, success, items, error) in
            if success {
                // selfs here because xcode complained - needed in the completion handler
                if self.useCenterTextFields {
                    self.save(newMeme,topText: self.topCenterTextField,bottomText: self.bottomCenterTextField)
                } else {
                   self.save(newMeme,topText:self.topTextField,bottomText:self.bottomTextField)
                }
                self.setDefaults()
                self.showAlert()
            }
        }
    }

    @IBAction func cancel(sender: AnyObject) {
        setDefaults()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    // Text field processing. Each method used for both text fields
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = "" // blank out default text
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()    // hide keyboard
        return true
    }
    
    // NOTE: Make sure text field tags are set!
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var newText = textField.text! as NSString
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        switch textField.tag {
        case 0:
            topTextEntered = true
        default:
            bottomTextEntered = true
        }
        return newText.length <= textFieldMaxChars
    }
    
    // Set up initialization defaults at initiation, when the Cancel button is pressed, or after the Sharing button is pressed
    func setDefaults() {
        topTextField.text = "TOP"
        topTextField.enabled = false
        bottomTextField.text = "BOTTOM"
        bottomTextField.enabled = false
        topCenterTextField.text = "TOP"
        topCenterTextField.enabled = false
        topCenterTextField.hidden = true
        bottomCenterTextField.text = "BOTTOM"
        bottomCenterTextField.enabled = false
        bottomCenterTextField.hidden = true
        imageView.image = nil
        shareButton.enabled = false
        instructionLabel.hidden = false
    }
    
    // Handle the Keyboard
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if (view.frame.origin.y == viewOriginalFramePositionY) { // if view has not already shifted
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (view.frame.origin.y != viewOriginalFramePositionY) {   // if view has not already shifted
            view.frame.origin.y += getKeyboardHeight(notification)
            if (topTextEntered && bottomTextEntered && imageView.image != nil) {
                shareButton.enabled = true
            }
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // Handle the Image
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                if (image.size.height > image.size.width) {
                    useCenterTextFields = false
                    topTextField.hidden = true
                    bottomTextField.hidden = true
                    topCenterTextField.hidden = false
                    bottomCenterTextField.hidden = false
                } else {
                    useCenterTextFields = true
                    topTextField.hidden = false
                    bottomTextField.hidden =  false
                    topCenterTextField.hidden = true
                    bottomCenterTextField.hidden = true
                }
                showImage(image)
                dismissViewControllerAnimated(true, completion: nil)
            }
    }
    
    func showImage(image:UIImage) {
        imageView.image = image
        if (imageView != nil) { // turn on keyboard
            topTextField.enabled = true
            bottomTextField.enabled = true
            topCenterTextField.enabled = true
            bottomCenterTextField.enabled = true
            instructionLabel.hidden = true
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Handle the meme
    func generateMeme() -> UIImage {
    
        toolbar.hidden = true   // hide tool it is not in meme image
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        toolbar.hidden = false  // now show tool bar
        //navbar.hidden = false
        return memedImage
    }
    
    // Save the meme
    func save (memedImage: UIImage,topText: UITextField, bottomText: UITextField) -> Meme {
        
        //Create the meme
        let meme = Meme( topText: topText.text!, bottomText: bottomText.text!,image:
            imageView.image!, memedImage: memedImage)
        
        //Save the meme
        let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        appDelegate.memes.append(meme)
        return meme
    }
    
    // Tell user the meme has been shared. After pressing "OK" go to first view
    func showAlert() {
        let alert=UIAlertController(title: "Share", message: "Your meme has been shared!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) {action -> Void in
            self.navigationController?.popToRootViewControllerAnimated(true)    // self needed
            })
        presentViewController(alert, animated: true, completion: nil)
    }
        
        


}
