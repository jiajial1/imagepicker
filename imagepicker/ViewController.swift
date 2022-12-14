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
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!

    let memeDelegate = MemeTextFieldDelegate()
    
    // define text attributes
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.white,
        NSAttributedString.Key.foregroundColor: UIColor.black,
        NSAttributedString.Key.font: UIFont(name: "IMPACT", size: 40)!,
        NSAttributedString.Key.strokeWidth: 5
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        // disable cameraButton if camera is no accessible
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // disable share button if image has been selected
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
        view.frame.origin.y -= getKeyboardHeight(notification)
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
        setupTextField(self.topTextField, placeHolderText: "TOP")
        setupTextField(self.bottomTextField, placeHolderText: "BOTTOM")

        self.topTextField.delegate = memeDelegate
        self.bottomTextField.delegate = memeDelegate
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // for both top and bottome text field
    func setupTextField(_ textField: UITextField, placeHolderText: String) {
        textField.textAlignment = .center
        textField.defaultTextAttributes = memeTextAttributes
        textField.attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: memeTextAttributes)
    }
    
    // MARK: Actions
    @IBAction func cleanImagePicker(_ sender: Any) {
        imagePicker.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
    }
    
    @IBAction func pickAnyImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        UIImagePickerController.isSourceTypeAvailable(.camera)
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func share(_ sender: Any) {
        let meme = generateMemedImage()

        let activityViewController = UIActivityViewController(activityItems: [meme], applicationActivities:  nil)
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
        navBar.isHidden = true
        toolbar.isHidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        navBar.isHidden = false
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

