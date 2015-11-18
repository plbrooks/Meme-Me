//
//  MemeCollectionViewController.swift
//  meme V2
//
//  Created by Peter Brooks on 11/11/15.
//  Copyright © 2015 Peter Brooks. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController  {
    
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var allMemes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let space: CGFloat = 3.0
        let width = (view.frame.size.width - (2 * space)) / 3.0
        let height = (view.frame.size.height - (2 * space)) / 5.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(width, height)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()   // repopulate collection view
    }
    
    
    // MARK: Collection View Data Source
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allMemes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SentMemesCollectionCell", forIndexPath: indexPath) as! SentMemesCollectionCell
        let meme = allMemes[indexPath.item]
        let imageView = UIImageView(image: meme.memedImage)
        cell.backgroundView = imageView
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath
    indexPath: NSIndexPath) {
        let object: AnyObject = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController")
        let detailController = object as! MemeDetailViewController
        detailController.meme = allMemes[indexPath.row]
        navigationController!.pushViewController(detailController, animated: true) // Present the view controller using navigation
    }
    
}
