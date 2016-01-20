//
//  MemeTableViewController.swift
//  meme V2
//
//  Created by Peter Brooks on 11/11/15.
//  Copyright © 2015 Peter Brooks. All rights reserved.
//

import UIKit

class MemeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var instructionLabel: UILabel!
   
    /********************************************************************************************************
     * Use global var in appdelegate per Udacity                                                            *
     ********************************************************************************************************/

    var allMemes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView!.reloadData()    // needed to repopulate table view
        if (allMemes.count > 0) {
            instructionLabel.hidden = true  // show instructions label
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMemes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableCell") as! SentMemesTableCell   // downcasting links in the custom class
        let meme = allMemes[indexPath.row]
        
        /* set the text label by combining top and bottom meme text fields
        logic:
        if total lengths <= 20 print both fields
        if total lengths > 20 print top field up to a max of 10 chars + print out bottom field to get total length to 20
        */
        let maxIndivChars = 10
        let maxTotalChars = 20
        let topLengthUsed = min(meme.topText.characters.count,maxIndivChars)
        let bottomLengthUsed = min(meme.bottomText.characters.count,maxTotalChars - topLengthUsed)
        let topTextUsed = meme.topText.substringToIndex(meme.topText.startIndex.advancedBy(topLengthUsed))
        let bottomTextUsed = meme.bottomText.substringToIndex(meme.bottomText.startIndex.advancedBy(bottomLengthUsed))
        cell.sentMemesCellLabel.text = topTextUsed + "..." + bottomTextUsed   // add the fields together with a ... in the middle
        // Set the image
        cell.sentMemesCellImage.image = meme.memedImage
        return cell
    }
    
    // go to detailed view when row is selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailController = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = allMemes[indexPath.row]
        navigationController!.pushViewController(detailController, animated: true)
    }
    
    // delete row when swiped left
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            tableView.beginUpdates()
            let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
            appDelegate.memes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.endUpdates()
        }
    }

    
}