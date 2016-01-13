//
//  AddEditInjuryViewController.swift
//  PhyT
//
//  Created by Seanmichael Stanley on 12/1/15.
//  Copyright © 2015 Seanmichael Stanley. All rights reserved.
//

import UIKit
import CoreData

protocol InjuryDelegate {
	func didFinishViewController(viewController: AddEditInjuryVC, didSave: Bool)
}

class AddEditInjuryVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {
	
	var context: NSManagedObjectContext!
	var delegate: InjuryDelegate? = nil
	
	var injury : Injury! {
		didSet {
			if (injury != nil){
			print("\(injury.name)")
			print("\(injury.injuryDesc)")
			print("\(injury.prevention)")
			print("\(injury.date)")
			print("\(injury.severity)")
		
			}
		}
	}
		
    @IBOutlet weak var injuryName: UITextField!
    @IBOutlet weak var severity: UILabel!
    @IBOutlet weak var severitySlider: UISlider!
    @IBOutlet weak var injuryDesc: UITextView!
    @IBOutlet weak var prevention: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet var scrollView: UIScrollView!
    
    var activeTextV: UITextView? = nil
    var activeTextField: UITextField? = nil
    let keyboardVerticalSpacing: CGFloat = 10
	
	
    @IBAction func textFieldForDate(sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        datePickerView.maximumDate = NSDate()
        
        if (dateTextField.text != "") {
            datePickerView.date = getDate(dateTextField.text!)
        }
        
        let toolBar = UIToolbar(frame: CGRectMake(0,0,0,40))
        toolBar.barStyle = UIBarStyle.Default
        toolBar.tintColor = UIColor.blackColor()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("donePicker:"))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Clear", style: UIBarButtonItemStyle.Done, target: self, action: Selector("cancelPicker:"))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        sender.inputAssistantItem.leadingBarButtonGroups = []
        sender.inputAssistantItem.trailingBarButtonGroups = []
        sender.inputAccessoryView = toolBar
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
	
	
	
	func donePicker(sender: UIBarButtonItem){
		dateTextField.endEditing(true)
	}
	
	func cancelPicker(sender: UIBarButtonItem){
		dateTextField.text = ""
		dateTextField.endEditing(true)
	}
	
	func datePickerValueChanged(sender:UIDatePicker) {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
		dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
		dateTextField.text = dateFormatter.stringFromDate(sender.date)
	}
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		injuryDesc.layer.borderWidth = 1
		prevention.layer.borderWidth = 1
		injuryDesc.layer.cornerRadius = 5
		prevention.layer.cornerRadius = 5
		injuryDesc.layer.borderColor = UIColor.lightGrayColor().CGColor
		prevention.layer.borderColor = UIColor.lightGrayColor().CGColor
		
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShownView:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHiddenView:", name: UIKeyboardWillHideNotification, object: nil)
       
        self.configureView()
        
        severity.text = "\(Int(severitySlider.value))"

	}
	
	func configureView() {
		if (injury != nil){
		
			title = injury.name
		
			if let textField = injuryName {
				if let value = injury.name {
					textField.text = value
				}
			}
		
			if let textField = injuryDesc {
				if let value = injury.injuryDesc {
					textField.text = value
				}
			}
		
			if let textField = prevention {
				if let value = injury.prevention {
					textField.text = value
				}
			}
		
			if let slider = severitySlider {
				if let value = injury.severity {
					slider.value = Float(value)
					severity.text = "\(value)"
				}
			}
		
			if let textField = dateTextField {
				if let value = injury.date {
					textField.text = getString(value)
				}
			}
		}
	}
	
	func updateInjury() {
		if (injury == nil){
			let newInjury = NSEntityDescription.entityForName("Injury", inManagedObjectContext: context)
			injury = Injury(entity: newInjury!, insertIntoManagedObjectContext: context)
		}
		
		if let existingInury = injury {
			existingInury.name = injuryName.text
			existingInury.injuryDesc = injuryDesc.text
			existingInury.prevention = prevention.text
			existingInury.severity = Int(severitySlider.value)
			if dateTextField.text != nil{
				existingInury.date = getDate(dateTextField.text!)
			} else {
				return
			}
		}
	}
	
	func dismissVC() {
		if (context.hasChanges) {
			print("\(context.insertedObjects.count)")
		}
		navigationController?.popViewControllerAnimated(true)
	}
	
	@IBAction func sliderAction(sender: AnyObject) {
		severity.text = "\(Int(severitySlider.value))"
	}
	
	@IBAction func saveTapped(sender: AnyObject) {
		updateInjury()
		delegate?.didFinishViewController(self, didSave: true)
		dismissVC()
	}
	
	@IBAction func cancelTapped(sender: UIBarButtonItem) {
		
		delegate?.didFinishViewController(self, didSave: false)
		dismissVC()
	}
	
	@IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
		self.view.endEditing(true)
	}
	
	func getString (date: NSDate) -> String{
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
		let date = dateFormatter.stringFromDate(date)
		
		return date
	}
	
	func getDate (dateString: String) -> NSDate {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy.M.d"
		let date = dateFormatter.dateFromString(dateString)
		if (date != nil){
			return date!
		}
			
		else {
			return NSDate()
		}
	}
    
    func textViewDidBeginEditing(textView: UITextView) {
        activeTextV = textView
        
        let activeTextViewSize = CGRectMake(activeTextV!.frame.origin.x, activeTextV!.frame.origin.y, activeTextV!.frame.width, activeTextV!.frame.height + keyboardVerticalSpacing)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.scrollView.scrollRectToVisible(activeTextViewSize, animated: true)
        })
    }
    
    func keyboardWasShownView(aNotification: NSNotification) {
        
        let userInfo = aNotification.userInfo
        
        if let info = userInfo{
            let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().size
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
            
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            
            if activeTextV == nil{
                keyboardWasShownField(aNotification)
            }else{

            
            let activeTextViewSize = CGRectMake(activeTextV!.frame.origin.x, activeTextV!.frame.origin.y, activeTextV!.frame.width, activeTextV!.frame.height + keyboardVerticalSpacing)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.scrollView.scrollRectToVisible(activeTextViewSize, animated: true)
            })}
            
        }
      
    }
    
    func keyboardWillBeHiddenView(aNotification: NSNotification) {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
        
        let activeTextFieldSize = CGRectMake(activeTextField!.frame.origin.x, activeTextField!.frame.origin.y, activeTextField!.frame.width, activeTextField!.frame.height + keyboardVerticalSpacing)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.scrollView.scrollRectToVisible(activeTextFieldSize, animated: true)
        })
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeTextField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        activeTextField?.resignFirstResponder()
        return true
    }
    
    func keyboardWasShownField(aNotification: NSNotification) {
        let userInfo = aNotification.userInfo
        
        if let info = userInfo {
            let kbSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().size
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
            
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            
            if activeTextField == nil{
                keyboardWasShownView(aNotification)
            }else{
            let activeTextFieldSize = CGRectMake(activeTextField!.frame.origin.x, activeTextField!.frame.origin.y, activeTextField!.frame.width, activeTextField!.frame.height + keyboardVerticalSpacing)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.scrollView.scrollRectToVisible(activeTextFieldSize, animated: true)
            })}
        }
    }
    
    func keyboardWillBeHiddenField(aNotification: NSNotification) {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
    }



}

