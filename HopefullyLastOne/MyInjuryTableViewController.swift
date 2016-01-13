//
//  MyInjuryTableViewController.swift
//  HopefullyLastOne
//
//  Created by Seanmichael Stanley on 12/9/15.
//  Copyright © 2015 James Tapia. All rights reserved.
//
/*Import CoreData Library to Access and Write to the App's Data Sset*/
import UIKit
import CoreData

class MyInjuryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, InjuryDelegate  {
	
	var coreDataStack: CoreDataStack!
	lazy var fetchedResultController: NSFetchedResultsController = self.injuryFetchedResultController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "My Injuries"
	}
	
	// MARK: - NSFetchedResultsController
	func injuryFetchedResultController()-> NSFetchedResultsController {
		
		fetchedResultController = NSFetchedResultsController(fetchRequest: injuryFetchRequest(), managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultController.delegate = self
		
		do {
			try fetchedResultController.performFetch()
		} catch let error as NSError {
			print("Error: \(error.localizedDescription)")
			abort()
		}
		
		return fetchedResultController
	}
	
	func injuryFetchRequest() -> NSFetchRequest {
		let fetchRequest = NSFetchRequest(entityName: "Injury")
		let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
		fetchRequest.sortDescriptors = [sortDescriptor]
		return fetchRequest
	}
	
	
	// MARK: - NSFetchedResultsControllerDelegate
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		tableView.beginUpdates()
	}
	
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		print("\(coreDataStack.context.insertedObjects.count)")
		switch type {
		case .Insert:
			tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
		case .Delete:
			tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
		case .Update:
			let cell = tableView.cellForRowAtIndexPath(indexPath!) as! InjuryCell
			configureCell(cell, indexPath: indexPath!)
		case .Move:
			tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
			tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
		}
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		tableView.endUpdates()
	}
	
	
	// MARK: - UITableViewDataSource
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return fetchedResultController.sections!.count
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultController.sections![section].numberOfObjects
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("injuryCell", forIndexPath: indexPath) as! InjuryCell
		configureCell(cell, indexPath: indexPath)
		if (coreDataStack.context.hasChanges) {
			print("\(coreDataStack.context.insertedObjects.count)")
		}
		return cell
	}
	
	func configureCell(cell: InjuryCell, indexPath:NSIndexPath) {
		let injury = fetchedResultController.objectAtIndexPath(indexPath) as! Injury
		cell.injuryTitle.text = injury.name
		cell.injuryDate.text = injury.stringForDate()
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			
			let actionSheet = UIAlertController(title: "Are you sure?", message: "This will permanently delete the information associated with this injury!", preferredStyle: UIAlertControllerStyle.Alert)
			
			let deleteAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive) { (alert: UIAlertAction) -> Void in
				
				let injuryToDelete = self.fetchedResultController.objectAtIndexPath(indexPath) as! Injury
				
				self.coreDataStack.context.deleteObject(injuryToDelete)
				self.coreDataStack.saveContext()
			}
			
			let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alert:UIAlertAction) -> Void in
				self.coreDataStack.saveContext()
			}
			
			actionSheet.addAction(deleteAction)
			actionSheet.addAction(cancelAction)
			
			self.presentViewController(actionSheet, animated: true, completion: nil)
		}
	}
	
	func didFinishViewController(viewController:AddEditInjuryVC, didSave:Bool) {
		print("\(didSave)")
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
			})
		}
	}
	
	// MARK: - Segues
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "addInjury" {
			
			let detailViewController = segue.destinationViewController as! AddEditInjuryVC
		
			detailViewController.injury = nil
			detailViewController.context = coreDataStack.context
			detailViewController.delegate = self
		}
			
		else if segue.identifier == "showInjury" {
			let indexPath = tableView.indexPathForSelectedRow
			let injury = fetchedResultController.objectAtIndexPath(indexPath!) as! Injury
			
			let detailViewController = segue.destinationViewController as! ShowInjuryVC
			
			detailViewController.injury = injury
			detailViewController.context = injury.managedObjectContext
			detailViewController.delegate = self
			detailViewController.coreDataStack = coreDataStack
			
		}
	}
}