//
//  MainViewController.swift
//  mememetest
//
//  Created by Erick Medina on 15/8/18.
//  Copyright © 2018 Erick Medina. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIImagePickerControllerDelegate
                            , UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var bottomBar: UIToolbar!
    
    var isImageSelected: Bool = false
    var originalImage: UIImage? = nil
    var memedImage: UIImage? = nil
    
    let memeTextAttributes:[String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -3.0]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        topText.defaultTextAttributes = memeTextAttributes
        topText.textAlignment = NSTextAlignment.center
        topText.textColor = UIColor.white
        topText.delegate = self
        bottomText.defaultTextAttributes = memeTextAttributes
        bottomText.textAlignment = NSTextAlignment.center
        bottomText.delegate = self
        if (!isImageSelected){
            setUIElements(false)
        }
        subscribeToKeyboardNotifications()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: Private Methods
    
    @IBAction func pickImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func takePicture(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        
        let topTextMessage = topText.text
        if ((topTextMessage?.isEmpty)! || (topTextMessage?.elementsEqual("Top".uppercased()))!){
            showAlert(message: "Top text shouldn't be empty")
            return
        }
        let bottomTextMessage = bottomText.text
        if ((bottomTextMessage?.isEmpty)! || (bottomTextMessage?.elementsEqual("Bottom".uppercased()))!){
            showAlert(message: "Bottom text shouldn't be empty")
            return
        }
        topText.resignFirstResponder()
        bottomText.resignFirstResponder()
        
        memedImage = getMemedImage()
        
        
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: [])
        present(activityController,animated: true){
            self.saveMeme()
        }
        
    }
    
    @IBAction func cancelMeme(_ sender: Any) {
        imageView.image = nil
        setUIElements(false)
    }
    
    func saveMeme(){
    
         let newMeme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: originalImage!, memedImage: memedImage!)
 
    }

    func getMemedImage() -> UIImage{
        //UIGraphicsBeginImageContext(self.view.frame.size)
        //UIGraphicsBeginImageContext(self.view.frame.size)
        //view.drawHierarchy(in: self.view.frame , afterScreenUpdates: true)
        //let height = self.view.frame.size.height
        
        let lessHeight = (self.navigationBar.frame.size.height) + (self.bottomBar.frame.size.height )//
        let height = self.view.frame.size.height - (lessHeight)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.view.frame.width, height: height), false, 0)
        view.drawHierarchy(in: CGRect(x: 0, y: -lessHeight, width: view.frame.width, height: self.view.frame.height + lessHeight),
                                      afterScreenUpdates: true)
        //self.view.frame.size.height),
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return memedImage
    }
    
    func setUIElements(_ enabled:Bool){
        setMemeTextsVisible(enabled)
        setShareButtonEnabled(enabled)
        setCancelButtonEnabled(enabled)
    }
    
    func setMemeTextsVisible(_ visible:Bool){
        topText.isHidden = !visible
        bottomText.isHidden = !visible
    }
    
    func setShareButtonEnabled(_ enabled:Bool){
        shareButton.isEnabled = enabled
    }
    
    func setCancelButtonEnabled(_ enabled:Bool){
        cancelButton.isEnabled = enabled
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    
    @objc func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    func showAlert(message:String){
        let alertController = UIAlertController()
        alertController.message = message
        let okAction = UIAlertAction(title: "OK", style: .cancel){ action in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: ImagePicker Delegate Methods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        isImageSelected = false
        setUIElements(false)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            self.originalImage = image
            imageView.image = image
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            setUIElements(true)
            isImageSelected = true
        } else {
            isImageSelected = false
            setUIElements(false)
        }
    }
    
    //MARK: TextField Delegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 0 && textField.text == "Top".uppercased() {
            topText.text = ""
        }
        if textField.tag == 1 && textField.text == "Bottom".uppercased() {
            bottomText.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            if (textField.tag == 0){
                topText.text = "Top".uppercased()
            } else if (textField.tag == 1){
                bottomText.text = "Bottom".uppercased()
            }
        }
    }
    
    
    
}

