// PROGRAMMERS: Anamarys Sanchez Morales, David Vetan
// PANTHERID:   6058389, 4100031
// CLASS:       COP 4655 Online
// INSTRUCTOR:  Steve Luis ECS 282
// ASSIGNMENT:  Team Project Deliverable 2
// DUE:         Saturday 07/27/19

import UIKit
import CoreData

class TCsViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    
    //Dismisses the keyboard when background is tapped
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    //search bar funtionality will come in future updates of the app
    //var isSearching = false
    @IBOutlet var searchBar: UISearchBar!
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    //returns number of rows in the table view
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get a new or recycled cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell",
                                                 for: indexPath)
        
        // Set the text on the cell with the description of the tc
        // that is at the nth index of tcs, where n = row this cell
        // will appear in on the tableview
        let tc = fetchedResultsController.object(at: indexPath)
        
        configureCell(cell, withEvent: tc)
        return cell
    }
    
    //configuration of the cell
    func configureCell(_ cell: UITableViewCell, withEvent tc: TC) {
        cell.textLabel!.text = tc.location! + tc.tcID!
    }
    
    //table editing view
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        // If the table view is asking to commit a delete command...
        if editingStyle == .delete {
            let tc = fetchedResultsController.managedObjectContext
            
            let title = "Delete TC"
            let message = "Are you sure you want to delete this item?"
            
            let ac = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: .actionSheet)
            
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(cancelAction)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                
                // Remove the tc from the inventory
                tc.delete(self.fetchedResultsController.object(at: indexPath))
                do {
                    try tc.save()
                } catch {
                    //code to handle the error
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
                
            })
            ac.addAction(deleteAction)
            
            // Present the alert controller
            present(ac, animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done

    }
    
    //Segue to transition the data of the table to the DetailViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailViewController
            = segue.destination as! DetailViewController
        let context = self.fetchedResultsController.managedObjectContext
        
        switch segue.identifier {
        // If the triggered segue is the "showTC" segue
        case "showTC"?:
            // Figure out which row was just tapped
            if let indexPath = tableView.indexPathForSelectedRow {
                // Get the item associated with this row and pass it along
                let tc = fetchedResultsController.object(at: indexPath)
                detailViewController.tc = tc
                detailViewController.managedObjectContext = context
                //addScreen is set to false because the user pressed a cell intead of the add button
                detailViewController.addScreen = false
            }
            
        //If the triggered segue is the "showAddTC" segue
        case "showAddTC"?:
            detailViewController.managedObjectContext = context
            //addScreen is set to true because the user pressed add button
            detailViewController.addScreen = true
            
        default:
                preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    //triggers every time the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //tcList.sortList()
        tableView.reloadData()
    }
    
    //sets the left item of the navigation bar to be an edit button item
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<TC> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<TC> = TC.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "tcID", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            //code to handle the error appropriately.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        		
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<TC>? = nil
    
    //triggers the table view to update
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! TC)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! TC)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    //triggers the table view to finish updates
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
  
    //searchBar method to be fixed in future versions of the app
    /*
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        }
        else
        {
            _fetchedResultsController = nil
            isSearching = true
            let predicate = NSPredicate(format: "tcID CONTAINS %@", searchBar.text!)
            fetchedResultsController.fetchRequest.predicate = predicate
            tableView.reloadData()
            print(isSearching)
        }
        
    }
 */
    //dismiss keyboard when return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true }
    
    //triggers when the view dissapears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Clear first responder
        view.endEditing(true)
    }
}

