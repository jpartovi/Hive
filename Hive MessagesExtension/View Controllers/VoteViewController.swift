//
//  VoteViewController.swift
//  testapp1 MessagesExtension
//
//  Created by Jack Albright on 6/17/22.
//

import UIKit
import Messages

//class VoteViewController: MSMessagesAppViewController {

class VoteViewController: UITableViewController {
    
    var delegate: MessagesViewController?
    static let storyboardID = "VoteViewController"
    
    
    var myID: String!
    var mURL: URL!
    
    var curPick = -1
    var dispPick = -1
    let daysAndTimes = 
    
    @IBOutlet weak var scrollview: UIView!
    
    
    var entries: [String]!
    var counts: [String]!
    
    var votelabels: [UILabel]!
    
    var countlabels: [UILabel]!
    
    var PickButtons: [UIButton]!
    
    @IBAction func pickPressed(_ sender: UIButton) {
        
        for (index, sendbutton) in (PickButtons.enumerated()) {
            
            if sendbutton.isEqual(sender) {
                
                let url = prepareVoteURL(index)
                
                prepareMessage(url)
                
            }
        }
    }
    
    
    func prepareMessage(_ url: URL) {
        
        guard let conversation = MessagesViewController.conversation else { fatalError("Received nil conversation") }

        let message = MSMessage(session: (conversation.selectedMessage?.session)!)

        let layout = MSMessageTemplateLayout()
        layout.caption = "Vote Placeholder"

        message.layout = layout
        message.url = url
        
        print(message.url)
        
        
        
        conversation.insert(message)
        
        //self.requestPresentationStyle(.compact)
    }
    
    
    func prepareVoteURL(_ indexPicked: Int) -> URL {
        
        var components = URLComponents(url: mURL,
                resolvingAgainstBaseURL: false)
        
        let voteItems = components!.queryItems![(3+entries.count)...]
        
        if (curPick == -1){
            
            let newVoteItem = URLQueryItem(name:myID, value: String(indexPicked))
            components!.queryItems?.append(newVoteItem)
            
        } else {
            
            for (index, queryItem) in (voteItems.enumerated()) {
                if (queryItem.name == myID){
                      
                    components!.queryItems![2+curPick].value = String(Int(components!.queryItems![2+curPick].value!)! - 1)
                    
                    components!.queryItems![(3+entries.count+index)].value = String(indexPicked)
                    
                    break
                }
            }
            
        }
        
        components!.queryItems![2+indexPicked].value = String(Int(components!.queryItems![2+indexPicked].value!)! + 1)
        
        
        countlabels[indexPicked].text = String(Int(countlabels[indexPicked].text!)!+1)
        
        if (dispPick != -1){
            countlabels[dispPick].text = String(Int(countlabels[dispPick].text!)!-1)
        }
        
        dispPick = indexPicked
        
        return (components?.url!)!
    }
    
    
    
    var arrayForBool: [String]!
    var sectionTitleArray: [String]!
    var sectionContentDict: [String : NSArray]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decodeURL(mURL)
        
        
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        
        votelabels = []
        countlabels = []
        PickButtons = []
        
        for (index, entry) in entries!.enumerated() {
            
            let count = counts[index]
            
            
            let optionlabel = UILabel()
            optionlabel.text = entry
            optionlabel.translatesAutoresizingMaskIntoConstraints = false
            scrollview.addSubview(optionlabel)
            
            let countlabel = UILabel()
            countlabel.text = count
            countlabel.translatesAutoresizingMaskIntoConstraints = false
            scrollview.addSubview(countlabel)
            
            //let votebutton = UIButton(type: UIButton.ButtonType.system)
            let votebutton = PrimaryButton()
            votebutton.setTitle("Vote", for: UIControl.State.normal)
            votebutton.translatesAutoresizingMaskIntoConstraints = false
            scrollview.addSubview(votebutton)
            
            
            optionlabel.leadingAnchor.constraint(equalTo: optionlabel.superview!.leadingAnchor, constant: 16).isActive = true
            
            countlabel.trailingAnchor.constraint(equalTo: votebutton.leadingAnchor, constant: -16).isActive = true
            
            votebutton.trailingAnchor.constraint(equalTo: votebutton.superview!.trailingAnchor, constant: -16).isActive = true
            
            
            countlabel.centerYAnchor.constraint(equalTo: optionlabel.centerYAnchor).isActive = true
            votebutton.centerYAnchor.constraint(equalTo: optionlabel.centerYAnchor).isActive = true
            
            
            if (index == 0){
                
                optionlabel.topAnchor.constraint(equalTo: optionlabel.superview!.topAnchor, constant: 16).isActive = true
                
                //countlabel.topAnchor.constraint(equalTo: countlabel.superview!.topAnchor, constant: 16).isActive = true
                
                //votebutton.topAnchor.constraint(equalTo: votebutton.superview!.topAnchor, constant: 16).isActive = true
                
            } else {
                
                optionlabel.topAnchor.constraint(equalTo: votelabels[index-1].bottomAnchor, constant: 16).isActive = true
                
                //countlabel.topAnchor.constraint(equalTo: countlabels[index-1].bottomAnchor).isActive = true
                
                //votebutton.topAnchor.constraint(equalTo: PickButtons[index-1].bottomAnchor).isActive = true
                
            }
            
            if (index == entries!.count-1) {
                
                optionlabel.bottomAnchor.constraint(equalTo: optionlabel.superview!.bottomAnchor, constant: -16).isActive = true
                
                //countlabel.bottomAnchor.constraint(equalTo: countlabel.superview!.bottomAnchor, constant: -16).isActive = true
                
                //votebutton.bottomAnchor.constraint(equalTo: votebutton.superview!.bottomAnchor, constant: -16).isActive = true
                
            }
            
            votebutton.addTarget(self, action:#selector(pickPressed), for: UIControl.Event.touchUpInside)
            
            votelabels.append(optionlabel)
            countlabels.append(countlabel)
            PickButtons.append(votebutton)
            
            
        }
        
        
        
        /*for (index, entry) in (entries.enumerated()) {
            
            votelabels[index].text = entry
            countlabels[index].text = counts[index]
        }*/
        
        
        arrayForBool = ["0","0","0"]
        sectionTitleArray = ["Pool A","Pool B","Pool C"]
        var tmp1 : NSArray = ["New Zealand","Australia","Bangladesh","Sri Lanka"]
        var string1 = sectionTitleArray[0]
        sectionContentDict[string1] = tmp1
        var tmp2 : NSArray = ["India","South Africa","UAE","Pakistan"]
        string1 = sectionTitleArray[1]
        sectionContentDict[string1] = tmp2
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitleArray.count
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

        if(Bool(arrayForBool[section]) == true)
        {
            var tps = sectionTitleArray[section]
            var count1 = (sectionContentDict[tps])!
            return count1.count
        }
        return 0;
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "ABC"
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 50
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(Bool(arrayForBool[indexPath.section]) == true){
            return 100
        }

        return 2;
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
        headerView.backgroundColor = Style.primaryColor
        headerView.tag = section

        let headerString = UILabel(frame: CGRect(x: 10, y: 10, width: tableView.frame.size.width-10, height: 30)) as UILabel
        headerString.text = sectionTitleArray[section]
        headerView.addSubview(headerString)

        let headerTapped = UITapGestureRecognizer (target: self, action:Selector(("sectionHeaderTapped:")))
        headerView.addGestureRecognizer(headerTapped)

        return headerView
    }

    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        print("Tapping working")
        print(recognizer.view?.tag)

        var indexPath : NSIndexPath = NSIndexPath(row: 0, section:recognizer.view!.tag)
        if (indexPath.row == 0) {

            var collapsed = Bool(arrayForBool[indexPath.section])
            collapsed = !collapsed!

            arrayForBool[indexPath.section] = String(collapsed!)
            //reload specific section animated
            var range = NSMakeRange(indexPath.section, 1)
            var sectionToReload = NSIndexSet(indexesIn: range)
            self.tableView.reloadSections(sectionToReload as IndexSet, with:UITableView.RowAnimation.fade)
        }

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{

        let CellIdentifier = "Cell"
        var cell :UITableViewCell
        cell = self.tableView.dequeueReusableCell(withIdentifier: CellIdentifier)!

        var manyCells : Bool = Bool(arrayForBool[indexPath.section])!

        if (!manyCells) {
            //  cell.textLabel.text = @"click to enlarge";
        } else {
            var content = sectionContentDict[sectionTitleArray[indexPath.section]]!
            cell.textLabel?.text = content.object(at: indexPath.row) as? String
            cell.backgroundColor = UIColor.green
        }

        return cell
    }
    
    
    
    // MARK: - Conversation Handling

    
    func decodeURL(_ url: URL) {

        let components = URLComponents(url: url,
                resolvingAgainstBaseURL: false)
        
        
        entries = []
        counts = []
        
        var lastIndex = 0

        for (index, queryItem) in (components!.queryItems![2...].enumerated()) {
            
            if (queryItem.name == "END") && (queryItem.value == "END"){
                lastIndex = index+2
                break
            }
            
            entries.append(queryItem.name)
            counts.append(queryItem.value!)
        }
        
        
        for (index, queryItem) in (components!.queryItems![(lastIndex+1)...].enumerated()) {
            if (queryItem.name == myID){
                
                curPick = Int(components!.queryItems![(lastIndex+1+index)].value!)!
                dispPick = curPick
                
                break
            }
        }
        
    }

    
}


protocol VoteViewControllerDelegate: AnyObject {
    
  func didFinishTask(sender: VoteViewController)
    
}
