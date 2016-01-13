//
//  ShowInjuryVC.swift
//  HopefullyLastOne
//
//  Created by Seanmichael Stanley on 12/9/15.
//  Copyright © 2015 James Tapia. All rights reserved.
//


import UIKit
import CoreData

class ShowInjuryVC: UIViewController, NSFetchedResultsControllerDelegate {
	

	
	@IBOutlet weak var injuryName: UILabel!
	@IBOutlet weak var injuryDate: UILabel!
	@IBOutlet weak var severity: UILabel!
	@IBOutlet weak var injuryDesc: UITextView!
	@IBOutlet weak var prevention: UITextView!
		
	var coreDataStack: CoreDataStack!
	var context: NSManagedObjectContext!
	var delegate: InjuryDelegate?
	var injury : Injury!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = ""
        injuryDesc.layer.borderWidth = 1
        prevention.layer.borderWidth = 1
        injuryDesc.layer.cornerRadius = 5
        prevention.layer.cornerRadius = 5
        injuryDesc.layer.borderColor = UIColor.lightGrayColor().CGColor
        prevention.layer.borderColor = UIColor.lightGrayColor().CGColor
	}
	
	override func viewWillAppear(animated: Bool) {
		injuryName.text = injury.name
		injuryDate.text = injury.stringForDate()
		severity.text = "Level: \(injury.severity!)"
		injuryDesc.text = injury.injuryDesc
		prevention.text = injury.prevention
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "editInjury" {
			
			let detailViewController = segue.destinationViewController as! AddEditInjuryVC
			
			detailViewController.injury = injury
			detailViewController.context = injury.managedObjectContext
			detailViewController.delegate = delegate
		}
			
		else if segue.identifier == "exerciseList" {
			let detailViewController = segue.destinationViewController as! ExerciseListTVC
			
			detailViewController.injury = injury
			detailViewController.context = context
			detailViewController.coreDataStack = coreDataStack
		}
	}
	
	
}