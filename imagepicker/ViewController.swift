//
//  ViewController.swift
//  imagepicker
//
//  Created by Jiajia Li on 12/8/22.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imagePicker: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var toolbar: UIToolbar!

    let memeDelegate = MemeTextFieldDelegate()
    
    // define text attributes
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.white,
        NSAttributedString.Key.foregroundColor: UIColor.black,
        NSAttributedString.Key.font: UIFont(name: "IMPACT", size: 40)!,
        NSAttributedString.Key.strokeWidth: -5
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        // disable cameraButton if app runs in Simulator
        #if targetEnvironment(simulator)
            cameraButton.isEnabled = false
        #else
            cameraButton.isEnabled = true
        #endif
        
        // disable share button if image has not been selected
        uploadButton.isEnabled = ( imagePicker.image != nil )
        
        super.viewWillAppear(false)
        
        // subscribe keyboard notification
        subscribeToKeyboardNotifications()
        subscribeToKeyboardHideNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // unsubscribe keyboard notification
        unsubscribeFromKeyboardNotifications()
        unsubscribeFromKeyboardHideNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    func subscribeToKeyboardHideNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardHideNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillHide() {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    override func viewDidLoad() {
        setupTextField(topTextField, placeHolderText: "TOP")
        setupTextField(bottomTextField, placeHolderText: "BOTTOM")
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // for both top and bottome text field
    func setupTextField(_ textField: UITextField, placeHolderText: String) {
        textField.textAlignment = .center
        textField.defaultTextAttributes = memeTextAttributes
        textField.attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: memeTextAttributes)
        textField.delegate = memeDelegate
    }
    
    // MARK: Actions
    @IBAction func cleanImagePicker(_ sender: Any) {
        imagePicker.image = nil
        topTextField.text = ""
        topTextField.placeholder = "TOP"
        bottomTextField.text = ""
        bottomTextField.placeholder = "BOTTOM"
        uploadButton.isEnabled = false
    }
    
    func pickImage(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnyImage(_ sender: Any) {
        pickImage(source: .photoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickImage(source: .camera)
    }
    
    @IBAction func share(_ sender: Any) {
        let meme = generateMemedImage()

        let activityViewController = UIActivityViewController(activityItems: [meme], applicationActivities:  nil)
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
                    if success {
                        Meme(topText: self.topTextField.text! as String?, bottomeText: self.bottomTextField.text! as String?, originalImage: self.imagePicker, memeImage: meme)
                        // not sure what to do with the Meme object. it's not mentioned in th spec'
                    }
                }
        activityViewController.excludedActivityTypes = [.addToReadingList,
                                                        .airDrop,
                                                        .assignToContact,
                                                        .copyToPasteboard,
                                                        .openInIBooks,
                                                        .print,
                                                        .saveToCameraRoll,
                                                        .postToWeibo,
                                                        .copyToPasteboard,
                                                        .saveToCameraRoll,
                                                        .postToFlickr,
                                                        .postToVimeo,
                                                        .postToTencentWeibo,
                                                        .markupAsPDF
        ]
        present(activityViewController, animated: true)
    }
    
    func generateMemedImage() -> UIImage {
//        navBar.isHidden = true
        toolbar.isHidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

//        navBar.isHidden = false
        toolbar.isHidden = false
        return memedImage
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePicker.image = image
            imagePickerControllerDidCancel(picker)
            uploadButton.isEnabled = true
        } else {
            imagePicker.image = nil
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: false, completion: nil)
    }
}

