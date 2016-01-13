//
//  ShowExerciseViewController.swift
//  PhyT
//
//  Created by Seanmichael Stanley on 12/7/15.
//  Copyright © 2015 Seanmichael Stanley. All rights reserved.
//

import UIKit
import CoreData

class ShowExerciseVC: UIViewController {
	
	@IBOutlet weak var exerciseDesc: UITextView!
	
	
	var embedController: PageViewVC? = nil
	var context: NSManagedObjectContext!
	var delegate: ExerciseDelegate?
	var exercise: Exercise!
	var injury: Injury!
	var coreDataStack: CoreDataStack!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = exercise.name
		exerciseDesc.text = exercise.exerciseDesc
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "embed" {
			embedController = segue.destinationViewController as? PageViewVC
			embedController?.exercise = exercise
		}
		
		if segue.identifier == "editExercise" {
			let detailViewController = segue.destinationViewController as! AddEditExerciseVC
			
			detailViewController.exercise = exercise
			detailViewController.coreDataStack = coreDataStack
			detailViewController.injury = injury
			detailViewController.context = context
			detailViewController.delegate = delegate
		}
	}
}
