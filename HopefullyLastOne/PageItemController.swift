//
//  PageItemController.swift
//  HopefullyLastOne
//
//  Created by MU IT Program on 12/13/15.
//  Copyright © 2015 James Tapia. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class PageItemController: UIViewController {

	@IBOutlet weak var contentImageView: UIImageView!
    
    var itemIndex: Int = 0
    var video: Video! = nil{
        
        didSet {
            
            if let imageView = contentImageView {
				imageView.image = UIImage(data: video.thumbnail!)
            }
            
        }
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if (contentImageView != nil){
			contentImageView!.image = UIImage(data: video.thumbnail!)
		}
		// Do any additional setup after loading the view.
	}
	/*@IBAction func playVideo(sender: UITapGestureRecognizer) {
		let dataPath = NSURL.fileURLWithPath(video.url!)
		print("\(dataPath)")
		let videoAsset = (AVAsset(URL: dataPath))
		let playerItem = AVPlayerItem(asset: videoAsset)
		
		// Play the video
		let player = AVPlayer(playerItem: playerItem)
		let playerViewController = AVPlayerViewController()
		playerViewController.player = player
		
		self.presentViewController(playerViewController, animated: true) {
			playerViewController.player!.play()
		}

	}*/
	@IBAction func playVideo(sender: AnyObject) {
		//let fileManager = NSFileManager.defaultManager()
		
		let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
		let documentsDirectory:AnyObject=paths[0]
		let dataPath = documentsDirectory.stringByAppendingPathComponent(video.url!)
		let videoPath = NSURL.fileURLWithPath(dataPath)
		print("\(videoPath)")
		let videoAsset = (AVAsset(URL: videoPath))
		let playerItem = AVPlayerItem(asset: videoAsset)
		
		// Play the video
		let player = AVPlayer(playerItem: playerItem)
		let playerViewController = AVPlayerViewController()
		playerViewController.player = player
		
		self.presentViewController(playerViewController, animated: true) {
			playerViewController.player!.play()
		}
	}
}
