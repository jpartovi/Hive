//
//  MessagesAppViewController.swift
//  Hive MessagesExtension
//
//  Created by Jude Partovi on 6/6/22.
//

import UIKit
import Messages
import GooglePlaces

class MessagesAppViewController: MSMessagesAppViewController, InviteViewControllerDelegate, StartEventViewControllerDelegate, MessageViewControllerDelegate, UINavigationControllerDelegate {
    
    static var conversation: MSConversation? = nil
    static var userID: String = (conversation?.localParticipantIdentifier.uuidString)!
    var curSession: MSSession? = nil
    
    @IBOutlet weak var messageButton: HexButton!
    
    @IBAction func messageButtonTapped(_ sender: Any) {
        
        requestPresentationStyle(.expanded)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use like AppDelegate
        GMSPlacesClient.provideAPIKey(googlePlacesAPIKey)
        
        messageButton.isHidden = true
    }

    
    /*override func viewWillDisappear(_ animated: Bool) {
        print("Will Disappear")
        messageButton.isUserInteractionEnabled = false
        super.viewWillDisappear(animated)
        
        if self.children != [] {
            self.children[0].dismiss(animated: true, completion: {self.messageButton.isUserInteractionEnabled = true})
            
        }
        
        //self.dismiss(animated: true, completion: {self.messageButton.isEnabled = true})
    }*/
    
    override func contentSizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
    
    // MARK: - Conversation Handling
    override func willBecomeActive(with conversation: MSConversation) {
        
        MessagesAppViewController.conversation = conversation
        
        let controller: UIViewController
        var title = ""
        if conversation.selectedMessage == nil {
            controller = instantiateStartEventViewController()
        } else {
            curSession = conversation.selectedMessage?.session
            guard let messageURL = conversation.selectedMessage?.url else {return}
            guard let urlComponents = NSURLComponents(url: messageURL, resolvingAgainstBaseURL: false), let queryItems = urlComponents.queryItems else {return}
            let value = queryItems[0].value!
            if value == "invite" {
                controller = instantiateInviteViewController(conversation: conversation)
                switch queryItems[2].value! {
                case "initial":
                    title = "Invite"
                case "yesRSVP":
                    title = "Coming"
                case "noRSVP":
                    title = "Can't come"
                default:
                    print("Uncaught message display type")
                }
                print(title)
            } else if value == "vote" {
                if queryItems[1].value! == MessagesAppViewController.userID {
                    controller = instantiateVoteResultsViewController(conversation: conversation)
                } else {
                    controller = instantiateVoteViewController(conversation: conversation)
                }
                switch queryItems[2].value! {
                case "initial":
                    title = "Vote!"
                case "iVoted":
                    title = "I Voted!"
                default:
                    print("Uncaught message display type")
                }
                print(title)
            } else {
                fatalError("Unrecognized message type")
            }
            
        }
        
        if presentationStyle == .transcript {
            messageButton.isHidden = false
            messageButton.size(size: 150, textSize: 25)
            messageButton.style(title: title, imageTag: "ColorHex")
        } else {
            presentViewController(controller: controller, presentationStyle: presentationStyle)
        }
        
        if UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height  {
            (self.children.first as! UINavigationController).navigationBar.isUserInteractionEnabled = false
            (self.children.first as! UINavigationController).children.last!.view.isUserInteractionEnabled = false
        }
        
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
        for child in children {
            print(child)
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
            if presentationStyle == .transcript {
                for child in children {
                    child.willMove(toParent: nil)
                    child.view.removeFromSuperview()
                    child.removeFromParent()
                }
            }
            if let child = child as? VoteNavigationController {
                let subchild = child.children.last
                if let subchild = subchild as? ConfirmViewController {
                    if presentationStyle == .compact {
                        subchild.changedConstraints(compact: true)
                    } else if presentationStyle == .expanded {
                        subchild.changedConstraints(compact: false)
                    }
                } else if let subchild = subchild as? VoteViewController {
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
                if let subchild = subchild as? ConfirmViewController {
                    if presentationStyle == .compact {
                        subchild.changedConstraints(compact: true)
                    } else if presentationStyle == .expanded {
                        subchild.changedConstraints(compact: false)
                    }
                } else if let subchild = subchild as? VoteResultsViewController {
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
                        subchild.changedConstraints(compact: true)
                    } else if presentationStyle == .expanded {
                        subchild.changedConstraints(compact: false)
                    }
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
        print("didselect")
        if curSession != message.session {
            curSession = message.session
            
            
            presentViewController(controller: findIntendedViewController(conversation: conversation)!, presentationStyle: presentationStyle)
        } else {
            self.dismiss()
            //Never runs due to message double selection bug, figure out what to put here later
        }
    }
    
    func findIntendedViewController(conversation: MSConversation) -> UIViewController? {
        print("Find Intended View Controller")
        
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
            let value = queryItems[0].value!
            if value == "invite" {
                return instantiateInviteViewController(conversation: conversation)
            } else if value == "vote" {
                if queryItems[1].value! == MessagesAppViewController.userID {
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
        print("Present View Controller")
        
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

    func instantiateVoteViewController(conversation: MSConversation) -> UIViewController {
        
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "VoteNavigationController") as? VoteNavigationController else { fatalError("Unable to instantiate an VoteNavigationController from the storyboard") }
        
        controller.delegate = self
        controller.myID = MessagesAppViewController.userID
        controller.mURL = conversation.selectedMessage?.url
        
        return controller
    }
    
    func didFinishTask(sender: VoteViewController) {
        
    }
    
    func instantiateVoteResultsViewController(conversation: MSConversation) -> UIViewController {
        
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "VoteResultsNavigationController") as? VoteResultsNavigationController else { fatalError("Unable to instantiate an VoteResultsNavigationController from the storyboard") }
        
        controller.delegate = self
        controller.myID = MessagesAppViewController.userID
        controller.mURL = conversation.selectedMessage?.url
        
        return controller
    }
    
    func didFinishTask(sender: VoteResultsViewController) {
    
    }
    
    func instantiateMessageViewController(conversation: MSConversation) -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: MessageViewController.storyboardID) as? MessageViewController else { fatalError("Unable to instantiate an MessageViewController from the storyboard") }
            
        controller.delegate = self
        controller.myID = MessagesAppViewController.userID
        controller.mURL = conversation.selectedMessage?.url
        
        return controller
    }
    
    func didFinishTask(sender: MessageViewController) {
    
    }
    
    func instantiateInviteViewController(conversation: MSConversation) -> UIViewController {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: InviteViewController.storyboardID) as? InviteViewController else { fatalError("Unable to instantiate an InviteViewController from the storyboard") }
            
        controller.delegate = self
        controller.myID = MessagesAppViewController.userID
        controller.mURL = conversation.selectedMessage?.url
        
        return controller
    }
    
    func didFinishTask(sender: InviteViewController) {
    
    }
}