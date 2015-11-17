//
//  MemeDetailViewController.swift
//  meme V2
//
//  Created by Peter Brooks on 11/11/15.
//  Copyright © 2015 Peter Brooks. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var meme: Meme?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView!.image = meme?.memedImage    // needed
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "MemeDetailToEditorSegue"{
            let vc = segue.destinationViewController as! MemeEditorViewController
            vc.memeFromMemeDetail = meme!   // Send meme to Meme Editor VC
        }
    }
    
    
    
}
