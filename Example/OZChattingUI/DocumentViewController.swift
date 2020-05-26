//
//  DocumentViewController.swift
//  OZChattingUI_Example
//
//  Created by Henry Kim on 2020/05/23.
//  Copyright © 2020 CKStack. All rights reserved.
//

import UIKit

// Thanks to https://www.appcoda.com/files-app-integration/
class DocumentViewController: UIViewController {

    var delegate: ExampleViewController?
    var document: Document?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        document?.open(completionHandler: { (success) in
            if success {
                // Display the content of the document, e.g.:
                //self.documentNameLabel.text = self.document?.fileURL.lastPathComponent
                if let nc = self.navigationController {
                    nc.popViewController(animated: false)
                }
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


// Thanks to https://www.appcoda.com/files-app-integration/
// #1.0 - Subclass UIDocument to add a data
// model and provide functionality to read and
// write model data.
class Document: UIDocument {
    
    var delegate: ExampleViewController?

    // #2.0 - Model for storing binary data when file type is "public.image".
    var fileData: Data? {
        didSet {
            if let vc = delegate,
                let ccvc = vc.chatViewController {
                if let aData = fileData {
                    let aPath = String.audioFileSave(aData)
                    ccvc.send(msg: aPath, type: .mp3, isDeliveredMsg: false, callback: { (identifier, path) in
                        if let window = UIApplication.shared.keyWindow,
                            let rootVC = window.rootViewController,
                            let rvc = rootVC as? UINavigationController,
                            let chatVC = (rvc.viewControllers.filter{$0 is ExampleViewController}).first {
                            if let lastVC = chatVC.presentingViewController {
                                lastVC.dismiss(animated: true, completion: nil)
                            }
                            else if let lastVC = chatVC.presentedViewController {
                                lastVC.dismiss(animated: true, completion: nil)
                            }
                        }
                    })
                }
            }
        }
    }
    // #2.1 - Model for storing text when file type is "public.plain-text".
    var filesText: String?
    
    // #3.0 - Use this for WRITING/SAVING files. I only allow
    // editing/saving of text files, not image files.
    // "Override this method to return the document data to be saved."
    override func contents(forType typeName: String) throws -> Any {
        
        // #3.1 - UIDocument knows what type of file it
        // currently represents. The file type is passed
        // to this method when it's called during saves.
        if typeName == "public.plain-text" {
            
            // #3.2 - Use optional binding to find out
            // whether the "filesText" optional contains a value.
            if let content = filesText {
                
                // #3.3 - Return a Data instance containing
                // a representation of the String encoded using
                // UTF-8 (basically, plain text).
                let data = content.data(using: .utf8)
                return data!
                
            } else {
                return Data()
            }
            
        } else {
            return Data()
        }

    } // end func contents

    // #4.0 - "load" is called soon after "open"; used for READING data
    // from the user-selected document and storing that data
    // in the UIDocument's model. Called when document is opened.
    // "Override this method to load the document data into the app's data model."
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        
        // #4.1 - We can only read data if we know
        // what type of file we're reading from.
        if let fileType = typeName {
            
            if fileType == "public.mp3" {
                
                 if let fileContents = contents as? Data {
                     
                     fileData = fileContents
                     
                 }
                
            }
            else if fileType == "public.png" || fileType == "public.jpeg" { // .jpg not recognized
                // #4.2 - I only support .PNG and .JPG type image files.

                // #4.3 - If reading was successful, store
                // the binary data into the document model.
                if let fileContents = contents as? Data {
                    
                    fileData = fileContents
                    
                }
               
            // #4.4 - If reading from a text file...
            } else if fileType == "public.plain-text" {
                
                // #4.5 - ... and if reading was successful, store
                // the UTF-8 encoded text data into the document model.
                if let fileContents = contents as? Data {
                    
                    filesText = String(data: fileContents, encoding: .utf8)
                    
                }
                
            } else {
                print("File type unsupported.")
            }
            
        } // end if let fileType = typeName
        
    } // end func load
    
    // #5.0 - "A UIDocument object has a specific state at
    // any moment in its life cycle. You can check
    // the current state by querying the documentState
    // property..." State can help us in debugging.
    public var state: String {
        
        switch documentState {
            
        case .normal:
            return "Normal"
        case .closed:
            return "Closed"
        case .inConflict:
            return "Conflict"
        case .savingError:
            return "Save Error"
        case .editingDisabled:
            return "Editing Disabled"
        case .progressAvailable:
            return "Progress Available"

        default:
            return "Unknown"
            
        }
        
    } // end public var state
    
} // end class Document
