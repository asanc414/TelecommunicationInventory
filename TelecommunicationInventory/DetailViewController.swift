// PROGRAMMERS: Anamarys Sanchez Morales, David Vetan
// PANTHERID:   6058389, 4100031
// CLASS:       COP 4655 Online
// INSTRUCTOR:  Steve Luis ECS 282
// ASSIGNMENT:  Team Project Deliverable 2
// DUE:         Saturday 07/27/19

import UIKit
import CoreData

class DetailViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
 
    @IBOutlet var tcIdentifier: UITextField!
    @IBOutlet var location: UITextField!
    @IBOutlet var doorType: UITextField!
    @IBOutlet var acType: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var racksNumber: UITextField!
    @IBOutlet var connectedOnOff: UISwitch!
    @IBOutlet var camera: UIBarButtonItem!
    
    //This boolean addScreen will be passed to this view throught the segue.
    //If the user pressed Add the boolean will be set to true, otherwise it will be set to false.
    var addScreen = false
    var editOff = true
    var tc: TC!

    var managedObjectContext: NSManagedObjectContext? = nil
    
    //Image Picker method
    @IBAction func takePicture(_ sender: UIBarButtonItem) {
        
        let imagePicker = UIImagePickerController()
        
        // If the device has a camera, take a picture; otherwise,
        // just pick from photo library
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        imagePicker.delegate = self
        
        // Place image picker on the screen
        present(imagePicker, animated: true, completion: nil)
    }
    
    //Dismisses the keyboard when background is tapped
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    //This method will trigger every time this view appears. It sets up the interface for the user to add or edit data.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if addScreen{
            //sets the right bar button title to add
            navigationItem.rightBarButtonItem?.title = "Add"
        }
        else{
            if(editOff)
            {
                //sets the right bar button title to edit
                navigationItem.rightBarButtonItem?.title = "Edit"
                navigationItem.title = tc.location! + tc.tcID!
                
                //disables all the data entries so the user only can change them when edit is pressed
                tcIdentifier.isEnabled = false
                location.isEnabled = false
                doorType.isEnabled = false
                acType.isEnabled = false
                connectedOnOff.isEnabled = false
                racksNumber.isEnabled = false
                datePicker.isUserInteractionEnabled = false
                camera.isEnabled = false
                
                //populates the data items
                tcIdentifier.text = tc.tcID
                location.text = tc.location
                doorType.text = tc.doorType
                acType.text = tc.acType
                connectedOnOff.isOn = tc.connected
                racksNumber.text = String(tc.racksNumber)
                datePicker.date = tc.visitDate! as Date
                
                let imageToDisplay = tc.image
                imageView.image = UIImage(data: imageToDisplay! as Data)
            }
            else
            {
                //sets the right bar button title to done
                navigationItem.rightBarButtonItem?.title = "Done"
                
                //disables all the data entries so the user only can change them when edit is pressed
                tcIdentifier.isEnabled = true
                location.isEnabled = true
                doorType.isEnabled = true
                acType.isEnabled = true
                connectedOnOff.isEnabled = true
                racksNumber.isEnabled = true
                datePicker.isUserInteractionEnabled = true
                camera.isEnabled = true
            }
            
        }
        
    }
    
    //dismisses the keyboard when the user presses return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true }
    
    //triggers everytime the view disapears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Clear first responder
        view.endEditing(true)
    }
    
    //Programaticaly adds the right button to the navigation bar
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
    }
    
    //method that triggers when right buttom is tapped
    func editTapped() {
        var message: String = ""
        //ading TC
        if addScreen
        {
            //validates data
            if (tcIdentifier.text == "" || location.text == "" || doorType.text == "" || racksNumber.text == "" || acType.text == "" || imageView.image == nil)
            {
                message = "Could not update database. One or more fields are empty. All the fields, including the photo, are required."
            }
            //creates new TC
            else
            {
                createNewTC()
                message = "New TC Added"
            }
            //alert message
            let alert = UIAlertController(title: "TC Database Message", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
        //editing TC
        else
        {
            if editOff
            {
                navigationItem.rightBarButtonItem?.title = "Done"
                
                //enable all the data items
                tcIdentifier.isEnabled = true
                location.isEnabled = true
                doorType.isEnabled = true
                acType.isEnabled = true
                connectedOnOff.isEnabled = true
                racksNumber.isEnabled = true
                datePicker.isUserInteractionEnabled = true
                camera.isEnabled = true
                
                editOff = false
            }
            else
            {
                //validates data
                if (tcIdentifier.text == "" || location.text == "" || doorType.text == "" || racksNumber.text == "" || acType.text == "" || imageView.image == nil)
                {
                    message = "Could not update database. One or more fields are empty."
                }
                //populates tc object with all the required data taken from the user input
                else
                {
                    tc.tcID = tcIdentifier.text!
                    tc.location = location.text!
                    tc.doorType = doorType.text!
                    tc.racksNumber = Int16(racksNumber.text!)!
                    tc.acType = acType.text!
                    tc.connected = connectedOnOff.isOn
                    tc.visitDate = datePicker.date as NSDate
                    tc.image = UIImagePNGRepresentation(imageView.image!)! as NSData
                    
                    let context = self.fetchedResultsController.managedObjectContext
                    // Save the context.
                    do {
                        try context.save()
                    } catch {
                        //code to handle the error.
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                    
                    message = "TC Edited"
                    //turn the view back into non-editing view
                    navigationItem.rightBarButtonItem?.title = "Edit"
                    
                    tcIdentifier.isEnabled = false
                    location.isEnabled = false
                    doorType.isEnabled = false
                    acType.isEnabled = false
                    connectedOnOff.isEnabled = false
                    racksNumber.isEnabled = false
                    datePicker.isUserInteractionEnabled = false
                    camera.isEnabled = false
                
                    
                    editOff = true
                    
                }
                let alert = UIAlertController(title: "TC Database Message", message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    //method to create a new TC
    func createNewTC() {
        let context = self.fetchedResultsController.managedObjectContext
        let newTC = TC(context: context)
        
        //populates tc object with all the required data taken from the user input
        newTC.tcID = tcIdentifier.text
        newTC.location = location.text
        newTC.doorType = doorType.text
        newTC.connected = connectedOnOff.isOn
        newTC.acType = acType.text
        newTC.racksNumber = Int16(racksNumber.text!)!
        newTC.visitDate = datePicker.date as NSDate
        newTC.image = UIImagePNGRepresentation(imageView.image!)! as NSData
        
        // Save the context.
        do {
            try context.save()
        } catch {
            // Code to handle the error appropriately.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
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
        aFetchedResultsController.delegate = self as? NSFetchedResultsControllerDelegate
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            //Code to handle the error
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<TC>? = nil
    
    //image picker controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        // Get picked image from info dictionary
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Put that image on the screen in the image view
        imageView.image = image
        
        // Take image picker off the screen -
        // you must call this dismiss method
        dismiss(animated: true, completion: nil)
    }
}
