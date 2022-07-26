//
//  MessagesViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/6/22.
//

import UIKit
import Messages
import GooglePlaces

class MessagesViewController: MSMessagesAppViewController, InviteViewControllerDelegate, StartEventViewControllerDelegate, UINavigationControllerDelegate {
    
    static var conversation: MSConversation? = nil
    static var userID: String = (conversation?.localParticipantIdentifier.uuidString)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use like AppDelegate
        GMSPlacesClient.provideAPIKey(googlePlacesAPIKey)
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        
        MessagesViewController.conversation = conversation
        presentViewController(controller: findIntendedViewController(conversation: conversation)!, presentationStyle: presentationStyle)
        
        if self.view.frame.size.width > self.view.frame.size.height  {
            (self.children.first as! UINavigationController).navigationBar.isUserInteractionEnabled = false
            (self.children.first as! UINavigationController).children.last!.view.isUserInteractionEnabled = false
        } else {
            (self.children.first as! UINavigationController).navigationBar.isUserInteractionEnabled = true
            (self.children.first as! UINavigationController).children.last!.view.isUserInteractionEnabled = true
        }
        
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
        for child in children {
            if let child = child as? UINavigationController {
                let subchild = child.children.last //the view controller being presented
                if let subchild = subchild as? ConfirmViewController {
                    subchild.textBoxFlag = true
                    return
                }
            }
        }
        
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        for child in children {
            if let child = child as? VoteNavigationController {
                let subchild = child.children.last
                if let subchild = subchild as? VoteViewController {
                    if presentationStyle == .compact {
                        print("VOTE COMPACT")
                        presentViewController(controller: instantiateStartEventViewController(), presentationStyle: presentationStyle)
                        //child.willMove(toParent: nil)
                        //child.view.removeFromSuperview()
                        //child.removeFromParent()
                        //child.dismiss(animated: true)
                        //self.view.window!.rootViewController?.dismiss(animated: false)
                        //dismiss()
                    } else if presentationStyle == .expanded {
                        subchild.addHexFooter()
                    }
                }
            } else if let child = child as? VoteResultsNavigationController {
                let subchild = child.children.last
                if let subchild = subchild as? VoteResultsViewController {
                    if presentationStyle == .compact {
                        print("VOTE RESULTS COMPACT")
                        presentViewController(controller: instantiateStartEventViewController(), presentationStyle: presentationStyle)
                        //child.willMove(toParent: nil)
                        //child.view.removeFromSuperview()
                        //child.removeFromParent()
                        //child.dismiss(animated: true)
                        //self.view.window!.rootViewController?.dismiss(animated: false)
                        //dismiss()
                    } else if presentationStyle == .expanded {
                        subchild.addHexFooter()
                    }
                }
            } else if let child = child as? InviteViewController {
                if presentationStyle == .compact {
                    
                    presentViewController(controller: instantiateStartEventViewController(), presentationStyle: presentationStyle)
                    //dismiss()
                    //self.view.window!.rootViewController?.dismiss(animated: false)
                }
            } else if let child = child as? UINavigationController {
                let subchild = child.children.last //the view controller being presented
                if let subchild = subchild as? ConfirmViewController {
                    if presentationStyle == .compact {
                        subchild.scrollViewTrailingConstraint.constant = 160
                        for constraint in subchild.expandConstraints {
                            constraint.isActive = false
                        }
                        for constraint in subchild.compactConstraints {
                            constraint.isActive = true
                        }
                    } else if presentationStyle == .expanded {
                        subchild.scrollViewTrailingConstraint.constant = 16
                        for constraint in subchild.compactConstraints {
                            constraint.isActive = false
                        }
                        for constraint in subchild.expandConstraints {
                            constraint.isActive = true
                        }
                    }
                    subchild.formatLocations()
                    subchild.updateTableViewHeights()
                    subchild.updateContentView()
                    subchild.locationsTableView.reloadData()
                    subchild.daysAndTimesTableView.reloadData()
                    //subchild.styleEventTitleTextField()
                    //subchild.updateTableViewHeights()
                    
                    //print(subchild.eventTitleTextField.layer.sublayers?[0].frame.width)
                } else if let subchild = subchild as? LocationsViewController {
                    if presentationStyle == .compact {
                        subchild.changedConstraints(compact: true)
                    } else if presentationStyle == .expanded {
                        subchild.changedConstraints(compact: false)
                        if subchild.expandToNext {
                            subchild.nextPage()
                        }
                    }
                } else if let subchild = subchild as? DaySelectorViewController {
                    if presentationStyle == .compact {
                        subchild.changedConstraints(compact: true)
                    } else if presentationStyle == .expanded {
                        subchild.changedConstraints(compact: false)
                        
                        if subchild.expandToNext {
                            subchild.nextPage()
                        }
                    }
                } else if let subchild = subchild as? StartEventViewController {
                    subchild.conformToPresentationStyle(presentationStyle: presentationStyle)
                    if presentationStyle == .expanded {
                        print(subchild.expandToNext)
                        if subchild.expandToNext {
                            subchild.nextPage()
                        }
                    }
                } else if let subchild = subchild as? TimeSelectorViewController {
                    if presentationStyle == .compact {
                        subchild.changedConstraints(compact: true)
                    } else if presentationStyle == .expanded {
                        subchild.changedConstraints(compact: false)
                        if subchild.expandToNext {
                            subchild.nextPage()
                        }
                    }
                }
            }
        }
        
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if size.width > self.view.frame.size.width {
            (self.children.first as! UINavigationController).navigationBar.isUserInteractionEnabled = false
            (self.children.first as! UINavigationController).children.last!.view.isUserInteractionEnabled = false
        } else {
            (self.children.first as! UINavigationController).navigationBar.isUserInteractionEnabled = true
            (self.children.first as! UINavigationController).children.last!.view.isUserInteractionEnabled = true
        }
    }
    
    override func didSelect(_ message: MSMessage, conversation: MSConversation) {
        presentViewController(controller: findIntendedViewController(conversation: conversation)!, presentationStyle: presentationStyle)
    }
    
    func findIntendedViewController(conversation: MSConversation) -> UIViewController? {
        let controller: UIViewController
        
        if conversation.selectedMessage == nil {
            return instantiateStartEventViewController()
            
            //controller = (storyboard?.instantiateViewController(withIdentifier: "InviteViewController") as? InviteViewController)!
            
            //controller.delegate = self
            //controller.myID = conversation.localParticipantIdentifier.uuidString
            //controller.mURL = conversation.selectedMessage?.url
            
        } else {
            guard let messageURL = conversation.selectedMessage?.url else {return nil}
            guard let urlComponents = NSURLComponents(url: messageURL, resolvingAgainstBaseURL: false), let queryItems = urlComponents.queryItems else {return nil}
            
            /*
            for queryItem in queryItems {
                guard let value = queryItem.value else { continue }
                        
                print(value)
            }
            */
            
            let value = queryItems[0].value!
            
            print("Type: " + value)
            
            if value == "invite" {
                return instantiateInviteViewController(conversation: conversation)
            } else if value == "vote" {
                if queryItems[1].value! == MessagesViewController.userID {
                    return instantiateVoteResultsViewController(conversation: conversation)
                } else {
                    return instantiateVoteViewController(conversation: conversation)
                }
            } else {
                print("Invalid view type")
                return instantiateStartEventViewController()
            }
            
            // BUG: Shows Create Event VC when app is already open and message is clicked
        }
    }
    
    private func presentViewController(controller: UIViewController, presentationStyle: MSMessagesAppPresentationStyle) {
        
        // Remove any existing child controllers.
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }

        // Embed the new controller.
        addChild(controller)
                
        controller.view.frame = view.bounds
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
                
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        controller.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                
        controller.didMove(toParent: self)
    }
    /*
    func instantiateCreateEventViewController() -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController else { fatalError("Unable to instantiate a NavigationController from the storyboard") }
            
        controller.delegate = self
        
        return controller
    }
    
    func didFinishTask(sender: CreateEventViewController) {
    
    }
     */
    
    func instantiateStartEventViewController() -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController else { fatalError("Unable to instantiate a NavigationController from the storyboard") }
            
        controller.delegate = self
        
        return controller
    }
    
    func didFinishTask(sender: StartEventViewController) {
    
    }

    
    func instantiateInviteViewController(conversation: MSConversation) -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: InviteViewController.storyboardID) as? InviteViewController else { fatalError("Unable to instantiate an InviteViewController from the storyboard") }
            
        controller.delegate = self
        controller.myID = MessagesViewController.userID
        controller.mURL = conversation.selectedMessage?.url
        
        return controller
    }
    
    func didFinishTask(sender: InviteViewController) {
    
    }
    
    func instantiateVoteViewController(conversation: MSConversation) -> UIViewController {
        
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "VoteNavigationController") as? VoteNavigationController else { fatalError("Unable to instantiate an VoteNavigationController from the storyboard") }
        
        controller.delegate = self
        controller.myID = MessagesViewController.userID
        controller.mURL = conversation.selectedMessage?.url
        
        return controller
    }
    
    func didFinishTask(sender: VoteViewController) {
        
    }
    
    func instantiateVoteResultsViewController(conversation: MSConversation) -> UIViewController {
        
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "VoteResultsNavigationController") as? VoteResultsNavigationController else { fatalError("Unable to instantiate an VoteResultsNavigationController from the storyboard") }
        
        controller.delegate = self
        controller.myID = MessagesViewController.userID
        controller.mURL = conversation.selectedMessage?.url
        
        return controller
    }
    
    func didFinishTask(sender: VoteResultsViewController) {
    
    }
}
