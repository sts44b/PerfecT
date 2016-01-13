//
//  ExerciseListTVC.swift
//  HopefullyLastOne
//
//  Created by Seanmichael Stanley on 12/9/15.
//  Copyright © 2015 James Tapia. All rights reserved.
//

import UIKit
import CoreData

class ExerciseListTVC: UITableViewController, ExerciseDelegate{
	var coreDataStack: CoreDataStack!
	var context: NSManagedObjectContext!
	var injury: Injury!
	
	
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (injury.exercises?.count)!
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("exerciseCell", forIndexPath: indexPath) as! ExerciseCell
		configureCell(cell, indexPath: indexPath)
		if (coreDataStack.context.hasChanges) {
			print("\(coreDataStack.context.insertedObjects.count)")
		}
		return cell
	}
	
	func configureCell(cell: ExerciseCell, indexPath:NSIndexPath) {
		let exercise = injury.exercises![indexPath.row] as! Exercise
		cell.exerciseName.text = exercise.name
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			
			let actionSheet = UIAlertController(title: "Are you sure?", message: "This will permanently delete the information associated with this exercise", preferredStyle: UIAlertControllerStyle.Alert)
			
			let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive) { (alert: UIAlertAction) -> Void in
				
				let exerciseToDelete = self.injury.exercises![indexPath.row] as! NSManagedObject
				
				self.coreDataStack.context.deleteObject(exerciseToDelete)
				self.coreDataStack.saveContext()
				tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
			}
			
			let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert:UIAlertAction) -> Void in
				self.coreDataStack.saveContext()
			}
			
			actionSheet.addAction(deleteAction)
			actionSheet.addAction(cancelAction)
			
			self.presentViewController(actionSheet, animated: true, completion: nil)
		}
	}

	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "addExercise" {
			let detailViewController = segue.destinationViewController as! AddEditExerciseVC
			
			detailViewController.coreDataStack = coreDataStack
			detailViewController.injury = injury
			detailViewController.context = context
			detailViewController.delegate = self
	
		}
		
		if segue.identifier == "showExercise" {
			let indexPath = tableView.indexPathForSelectedRow
			let exercise = injury.exercises![(indexPath?.row)!] as! Exercise
			
			let detailViewController = segue.destinationViewController as! ShowExerciseVC

			detailViewController.exercise = exercise
			detailViewController.coreDataStack = coreDataStack
			detailViewController.injury = injury
			detailViewController.context = context
			detailViewController.delegate = self
		}
	}
	
	func didFinishViewController(viewController: AddEditExerciseVC, didSave:Bool) {
			if didSave {
				let context = viewController.context
				context.performBlock({ () -> Void in
					if context.hasChanges {
						do {
							try context.save()
						} catch {
							let nserror = error as NSError
							print("Error: \(nserror.localizedDescription)")
							abort()
						}
					}
					self.coreDataStack.saveContext()
					self.tableView.reloadData()
				})
			}
	}
		
}
