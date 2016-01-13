//
//  AddEditExerciseViewController.swift
//  PhyT
//
//  Created by Seanmichael Stanley on 12/7/15.
//  Copyright © 2015 Seanmichael Stanley. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import AVKit
import MobileCoreServices
import Foundation

protocol ExerciseDelegate {
	func didFinishViewController(viewController:AddEditExerciseVC, didSave:Bool)
}

class AddEditExerciseVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
	
	@IBOutlet weak var addVideoButton: UIButton!
    @IBOutlet weak var exerciseName: UITextField!
    @IBOutlet weak var exerciseDesc: UITextView!
	@IBOutlet weak var videoCollection: UICollectionView!
	
    @IBOutlet var scrollView: UIScrollView!
    
    var activeTextField: UITextField? = nil
    var activeTextV: UITextView? = nil
    let keyboardVerticalSpacing: CGFloat = 10

	var coreDataStack: CoreDataStack!
	let imagePicker: UIImagePickerController! = UIImagePickerController()
	var context: NSManagedObjectContext!
	var delegate: ExerciseDelegate?
	var injury: Injury!
	var exercise: Exercise! {
		didSet {
			if (exercise != nil) {
				print("\(exercise.name)")
				print("\(exercise.exerciseDesc)")
				print("\(exercise.injury?.name)")
			}
		}
	}
	
	var videoFilePath: String?
	
	func stringForDate() -> String {
		let date: NSDate! = NSDate()
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy.M.d HH:mm:ss"
		return dateFormatter.stringFromDate(date)
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		exerciseDesc.layer.borderWidth = 1
		exerciseDesc.layer.cornerRadius = 5
		exerciseDesc.layer.borderColor = UIColor.lightGrayColor().CGColor

		self.configureView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShownField:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHiddenField:", name: UIKeyboardWillHideNotification, object: nil)

	}
	
	override func viewWillAppear(animated: Bool) {
		if (exercise != nil){
			videoCollection.reloadData()
			addVideoButton.enabled = true
		}
		else{
			addVideoButton.enabled = false
		}
		
	}
	
	func configureView() {
		if (exercise != nil){
			title = exercise.name
		
			if let textField = exerciseName {
				if let value = exercise.name {
					textField.text = value
				}
			}
		
			if let textField = exerciseDesc {
				if let value = exercise.exerciseDesc {
					textField.text = value
				}
			}
		}
	}
	
	func dismissVC() {
		navigationController?.popViewControllerAnimated(true)
	}
	
	func updateExercise() {
		if (exercise == nil){
			let exerciseEntity = NSEntityDescription.entityForName("Exercise", inManagedObjectContext: coreDataStack.context)
			exercise = Exercise(entity: exerciseEntity!, insertIntoManagedObjectContext: coreDataStack.context)
			let exercises = injury.exercises!.mutableCopy() as! NSMutableOrderedSet
					exercises.addObject(exercise)
					injury.exercises = exercises.copy() as? NSOrderedSet
		}
		
		if let existingExercise = exercise {
			existingExercise.name = exerciseName.text
			existingExercise.exerciseDesc = exerciseDesc.text
		}
	}
	
	@IBAction func saveTapped(sender: AnyObject) {
	
		updateExercise()
		delegate?.didFinishViewController(self, didSave: true)
		dismissVC()

	}
	
	@IBAction func cancelTapped(sender: AnyObject) {
		delegate?.didFinishViewController(self, didSave: false)
		/*if (exercise.name == nil){
		self.context.deleteObject(exercise)
		self.context.refreshAllObjects()
		}*/
		
		dismissVC()
	}
	func getDocumentsDirectory() -> NSString {
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}
	
	@IBAction func addVideo(sender: AnyObject) {
		if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
			if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
				
				imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
				imagePicker.mediaTypes = [kUTTypeMovie as String]
				imagePicker.allowsEditing = false
				imagePicker.delegate = self
				
				presentViewController(imagePicker, animated: true, completion: nil)
			}
			else{
				postAlert("Camera inaccessable", message: "Application cannot access the camera.")
			}
		}
		else {
			postAlert("Camera inaccessable", message: "Application cannot access the camera.")
		}
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		print("Got a video")
		
		let saveFileName = "/" + stringForDate() + ".mp4"
		
		//if let pickedVideo: NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL) {
			/*let videoData = NSData(contentsOfURL: pickedVideo)
			videoFilePath = getDocumentsDirectory().stringByAppendingPathComponent("exerciseVideo.mp4")
			print("about to write to file \(self.videoFilePath)")
			let saved = videoData?.writeToFile(videoFilePath!, atomically: false)*/
			
			
			
			
			if let data = NSData(contentsOfURL: (info[UIImagePickerControllerMediaURL] as? NSURL)!){
			let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
			let documentsDirectory:AnyObject=paths[0]
			let dataPath=documentsDirectory.stringByAppendingPathComponent(saveFileName)
			/*if (!NSFileManager.defaultManager().fileExistsAtPath(dataPath)) {
				do{
					try NSFileManager.defaultManager().createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil)
				} catch let error as NSError {
					print("Error: \(error.localizedDescription)")
				}
			}*/
				
				//(dataPath as String, withIntermediateDirectories: false, attributes: nil, error: nil)
			
			print("about to write to file \(dataPath)")
			//let outputPath = "\(dataPath)/TestproximityRwqxq.mp4"
			
			let saved = data.writeToFile(dataPath, atomically: true)

			
			
			
			
			if (saved == true){
				print("Video saved")
				
				if (exercise != nil){
					newVideoEntity(saveFileName)
				}
				
				else{
					updateExercise()
					newVideoEntity(saveFileName)
				}
			}
			else {
				print("Failed to save video.")
			}
			
			imagePicker.dismissViewControllerAnimated(true, completion: nil)		}
	}
	
	func newVideoEntity(filePath: String){
		
		let fileManager = NSFileManager.defaultManager()
		
		let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
		let documentsDirectory:AnyObject=paths[0]
		let dataPath=documentsDirectory.stringByAppendingPathComponent(filePath)
		
		if fileManager.fileExistsAtPath(dataPath){
			let filePathURL = NSURL.fileURLWithPath(dataPath)
			let videoEntity = NSEntityDescription.entityForName("Video", inManagedObjectContext: self.coreDataStack.context)
			let newVideo = Video(entity: videoEntity!, insertIntoManagedObjectContext: self.coreDataStack.context)
			let videos = self.exercise.videos!.mutableCopy() as! NSMutableOrderedSet
			newVideo.url = filePath
			print("\(self.videoFilePath)")
			print("\(filePath)")
			newVideo.thumbnail = UIImagePNGRepresentation(thumbnailForVideoAtURL(filePathURL)!)!
			videos.addObject(newVideo)
			self.exercise.videos! = (videos.copy() as? NSOrderedSet)!
		}
	
		do {
			try self.context.save()
		} catch {
			let nserror = error as NSError
			print("Error: \(nserror.localizedDescription)")
		}
		
		//videoCollection.reloadData()
	}
	
	// Called when the user selects cancel
	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		print("User canceled image")
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	func thumbnailForVideoAtURL(url: NSURL) -> UIImage? {
		
		let asset = AVAsset(URL: url)
		let assetImageGenerator = AVAssetImageGenerator(asset: asset)
		
		var time = asset.duration
		time.value = min(time.value, 2)
		
		do {
			let imageRef = try assetImageGenerator.copyCGImageAtTime(time, actualTime: nil)
			return UIImage(CGImage: imageRef)
		} catch {
			print("error")
			return nil
		}
	}
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if (exercise != nil){
			return exercise.videos!.count
		} else {
			return 0
		}
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
		
		let pic = cell.viewWithTag(1) as! UIImageView
		
		let video = exercise.videos![indexPath.row] as! Video
		
		pic.image = UIImage(data: video.thumbnail!)
		
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		print("Cell Selected!")
		
		let video = exercise.videos![indexPath.row] as! Video
		let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
		let documentsDirectory:AnyObject=paths[0]
		let dataPath = documentsDirectory.stringByAppendingPathComponent(video.url!)
		let videoPath = NSURL.fileURLWithPath(dataPath)
		print("\(videoPath)")
		let videoAsset = (AVAsset(URL: videoPath))
		let playerItem = AVPlayerItem(asset: videoAsset)
		
		// Play the video
		let player = AVPlayer(playerItem: playerItem)
		let playerViewController = AVPlayerViewController()
		playerViewController.player = player
		
		self.presentViewController(playerViewController, animated: true) {
			playerViewController.player!.play()
		}
	}
	
	func postAlert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	@IBAction func dismissKeyboard(sender: AnyObject) {
		self.view.endEditing(true)
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
    
    func textViewDidBeginEditing(textView: UITextView) {
        activeTextV = textView
        
        let activeTextViewSize = CGRectMake(activeTextV!.frame.origin.x, activeTextV!.frame.origin.y, activeTextV!.frame.width, activeTextV!.frame.height + keyboardVerticalSpacing)
        
        dispatch_async(dispatch_get_main_queue(), {
            self.scrollView.scrollRectToVisible(activeTextViewSize, animated: true)
        })
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        activeTextV = nil
    }
    
    func textViewShouldReturn(textView: UITextView) -> Bool {
        activeTextV?.resignFirstResponder()
        return true
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


}


