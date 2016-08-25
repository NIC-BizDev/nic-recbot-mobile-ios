//
//  ViewController.swift
//  goBot
//
//  Created by Tosha on 8/18/16.
//  Copyright © 2016 nicusa. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Alamofire
import SwiftyJSON


class ViewController: JSQMessagesViewController,CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    var lat = 0.0
    var long = 0.0

    
    var myLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    
    
    let incommingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials("GO", backgroundColor: UIColor.jsq_messageBubbleBlueColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(12), diameter: 20)
    
    let outGoingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials("US", backgroundColor: UIColor.jsq_messageBubbleGreenColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(12), diameter: 20)
   // var currentLocation

    var messages = [JSQMessage]()
    
    func setup() {
        self.senderId = "1234"
        self.senderDisplayName = "GOBOT"
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
        self.setup()
        self.title = "Lets chat with GOBOT"
        self.addDemoMessages()
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages += [message]
        
        let parameters = ["v": "20150910","query":text, "lang":"en","sessionId":"ABCD"]
        
        let headers = ["Authorization":"Bearer e1e0bdb1be7c4e05ab4d2c0ebcfa3f24",  "Accept": "application/json"]
        //API call
        Alamofire.request(.GET, "https://api.api.ai/v1/query",headers: headers, parameters: parameters)
            
            .responseString { response in
              //  print("Response String: \(response.result.value)")
                
               if let dataFromString = response.result.value!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    let json = JSON(data: dataFromString)
                    
                    
                  /*  if let items = json["result"]["fulfillment"]["data"]["raw"].array {
                        for item in items {
                            if let title = item["name"].string {
                                print(title)
                            }
                        }
                    }*/
                    
                    var size = json["result"]["fulfillment"]["data"]["raw"].count
                
                if(size > 1)
                {
                    
                    for index in 1...size
                    {
                    let message = JSQMessage(senderId: "12345", displayName: "Server346", text: json["result"]["fulfillment"]["data"]["raw"][index-1]["Name"].string)
                        
                        self.messages += [message]
                        self.outgoingBubble
                        
                        let url = json["result"]["fulfillment"]["data"]["raw"][index-1]["Image"].string!
                        
                    let nsURL = NSURL(string: url)
                    let data = NSData(contentsOfURL: nsURL!) //make sure your image in this url does exist,
                        let photoItem = JSQPhotoMediaItem(image: UIImage(data: data!))
                        
                        let messageImage = JSQMessage(senderId: "12345", displayName: "Server346", media: photoItem)
                        self.messages.append(messageImage)
                        self.outgoingBubble
                        self.finishSendingMessageAnimated(true)
                        
                        var directionURL = json["result"]["fulfillment"]["data"]["raw"][index-1]["DirectionsUrl"].string
                        
                        var navigationString = "To get directions for  \(json["result"]["fulfillment"]["data"]["raw"][index-1]["Name"].string!)  please click \(directionURL!)";
                        
                        let navigationMessage = JSQMessage(senderId: "12345", displayName: "Server346", text:navigationString)
                        self.messages += [navigationMessage]

                        

                    self.reloadMessagesView()
                   }
                }//end of if
                else
                {
                    let message = JSQMessage(senderId: "12345", displayName: "Server346", text: "Sorry Activity not found in your Area")
                    
                    self.messages += [message]
                    self.outgoingBubble
                     self.reloadMessagesView()
                }
                
                }
        
            }
            .responseJSON { (responseJSON) in
             //   print(responseJSON.result.value)
        }

            self.finishSendingMessage()
    }
    
   override func didPressAccessoryButton(sender: UIButton!) {
    
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
    
    print("Pressed button ")
        let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .ActionSheet)
        
        let photoAction = UIAlertAction(title: "Send photo", style: .Default) { (action) in
            /**
             *  Create fake photo
             */
            
            let url = NSURL(string: "https://robohash.org/123.png")
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist,
            let photoItem = JSQPhotoMediaItem(image: UIImage(data: data!))
            self.addMedia(photoItem)
        }
        
        
        
        let locationAction = UIAlertAction(title: "Send current location", style: .Default) { (action) in
            
            let myCurrentLocation = CLLocation(latitude: self.lat, longitude: self.long)
            
            let currentLocationItem = JSQLocationMediaItem()
            currentLocationItem.setLocation(myCurrentLocation) {
                self.collectionView!.reloadData()
            }
            self.addMedia(currentLocationItem)
        }
        
        let videoAction = UIAlertAction(title: "Send video", style: .Default) { (action) in
            /**
             *  Add fake video
             */
            let videoItem = self.buildVideoItem()
            
            self.addMedia(videoItem)
        }
        
        let audioAction = UIAlertAction(title: "Send audio", style: .Default) { (action) in
            /**
             *  Add fake audio
             */
            let audioItem = self.buildAudioItem()
            
            self.addMedia(audioItem)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        sheet.addAction(photoAction)
        sheet.addAction(locationAction)
        sheet.addAction(videoAction)
        sheet.addAction(audioAction)
        sheet.addAction(cancelAction)
        
        self.presentViewController(sheet, animated: true, completion: nil)

    }
    
    func buildVideoItem() -> JSQVideoMediaItem {
        let videoURL = NSURL(fileURLWithPath: "file://")
        
        let videoItem = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
        
        return videoItem
    }

    
    func buildAudioItem() -> JSQAudioMediaItem {
        let sample = NSBundle.mainBundle().pathForResource("jsq_messages_sample", ofType: "m4a")
        let audioData = NSData(contentsOfFile: sample!)
        
        let audioItem = JSQAudioMediaItem(data: audioData)
        
        return audioItem
    }
    
    func addMedia(media:JSQMediaItem) {
        let message = JSQMessage(senderId: self.senderId, displayName: "Tosha", media: media)
        self.messages.append(message)
        
        //Optional: play sent sound
        
        self.finishSendingMessageAnimated(true)
    }
    
    func receiveMessagePressed(sender: UIBarButtonItem) {
        /**
         *  DEMO ONLY
         *
         *  The following is simply to simulate received messages for the demo.
         *  Do not actually do this.
         */
        
        /**
         *  Show the typing indicator to be shown
         */
        self.showTypingIndicator = !self.showTypingIndicator
        
        /**
         *  Scroll to actually view the indicator
         */
        self.scrollToBottomAnimated(true)
        
        /**
         *  Copy last sent message, this will be the new "received" message
         */
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
}

extension ViewController {
    func addDemoMessages() {
        for i in 1...3 {
            let sender = (i%2 == 0) ? "Server" : self.senderId
            let messageContent = "Message nr. \(i)"
            let message = JSQMessage(senderId: sender, displayName: sender, text: messageContent)
            self.messages += [message]
        }
        self.reloadMessagesView()
    }
    
    //how many messages we have (we return message count inside our array)
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    //which message to display where
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    //what to do when a message is deleted (delete if from messages array)
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    //which bubble to choose (outgoing if we are the sender, and incoming otherwise)
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
        
       func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0]
        long = userLocation.coordinate.longitude;
        lat = userLocation.coordinate.latitude;
        
      //  print("Latitude is \(long) and longitude is \(lat)")
    }
    }
    
    //what to use as an avatar (for now we'll return nil and will not show avatars yet)
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            print(senderId)
            return self.outGoingAvatar
        default:
            return self.incommingAvatar
        }
        
        }
    
}

