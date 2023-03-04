//
//  ViewController.swift
//  Ind02_Sydam_Monisha
//
//  Created by Monisha Sydam on 3/4/23.
//

import UIKit

// Struct to record an image's center position and a boolean value to track a blank image
struct Cordinates{
    
    var x:CGFloat
    var y:CGFloat
    var IsValid:Bool
    
}

class ViewController: UIViewController {
    
    
    var imageViews: [UIImageView] = []  //Array for all the imageviews on screen
    
    var swapState: [UIImageView] = [] //Array to keep track of current position of imageviews                                                when they are moved
    
    var originalState: [CGPoint] = []  //Array that tracks the coordinates of original position of                                            imageviews
   
    var updatedState: [CGPoint] = []   //array to hold updated position of all the images
    
    var blankImage:UIImageView!  //Imageview of the blank image
    
    var lockScreen:Bool = true  // boolean variable to block user clicking on Images tiles when they click                              show answer button

    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        // Load all the imageviews
        // Store the center of the imageviews in an array
            
        var xMid = 67
        var yMid = 200
        var x = 1
        for _ in 0...4{
            for _ in 0...3{
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
                let imageView = UIImageView(frame: CGRect(x: xMid, y: yMid, width: 93, height: 93))
                imageView.image = UIImage(named: "\(x).jpg")
                let centerPoint = CGPoint(x: xMid, y: yMid)
                originalState.append(centerPoint)
                imageView.center = centerPoint
                imageView.addGestureRecognizer(tapRecognizer)
                imageView.isUserInteractionEnabled = true
                imageViews.append(imageView)
                view.addSubview(imageView)
                xMid += 93
                x += 1
            }
            xMid = 67
            yMid += 93
        }
            
        swapState = imageViews
        blankImage = imageViews[0]
    }

    // Tap gesture functionality for each imageView
    @objc func tapAction(_ sender: UITapGestureRecognizer) {
        // Check if the tapped view is not the blankImage and if the screen is not locked
        if (sender.view != blankImage && lockScreen){
            // Get updated coordinates for the tapped image view
            let result: Cordinates = updatedCoordinates(sender.view as! UIImageView)
            
            // Check if the updated coordinates are valid for swapping the images
            if (result.IsValid){
                // Swap the empty image with the image touched by user in its right, left, up, or down location
                swap_images(curr_Image: sender.view as! UIImageView)
                
                // Check if the puzzle is solved or not
                if(is_puzzle_solved()){
                    // Create a new alert to show if the puzzle is solved
                    let dialogMessage = UIAlertController(title: "Solved", message: "Click Ok to Play Again!!", preferredStyle: .alert)
                    
                    // Create OK button with action handler
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    })
                    
                    // Add OK button to the dialog message
                    dialogMessage.addAction(ok)
                    
                    // Present the alert to the user
                    self.present(dialogMessage, animated: true, completion: nil)
                }
            }
        }
    }

    // Function to swap the images with the blank image
    func swap_images(curr_Image: UIImageView) {
        // Get the index of blank image and the image to be swapped
        guard let i = swapState.firstIndex(of: blankImage),
              let j = swapState.firstIndex(of: curr_Image)
        else {
            return
        }
        
        // Swap the positions of the images
        let tempCenter = blankImage.center
        blankImage.center = curr_Image.center
        curr_Image.center = tempCenter
        
        // Swap the images in the swapState array
        swapState.swapAt(i, j)
        
        // Animate the swapping of images
        UIView.transition(with: curr_Image, duration: 0.25, options: .transitionFlipFromRight, animations: {}, completion: nil)
    }
    
    // Fetching the coordinates of images that are tapped
    func updatedCoordinates(_ view: UIImageView) -> Cordinates {
        // gets the origin of the blank image
        let currentGridX = view.frame.origin.x
        let currentGridY = view.frame.origin.y
        
        // calculates the position of the left, right, up and down image
        let currentGridXLeft = currentGridX - 93
        let currentGridYLeft = currentGridY
        
        let currentGridXRight = currentGridX + 93
        let currentGridYRight = currentGridY
        
        let upGridXPosition = currentGridX
        let upGridYPosition = currentGridY - 93
        
        let downGridXPosition = currentGridX
        let downGridYPosition = currentGridY + 93
        
        // checks at which direction of the tapped image is blank image and return that position
        if (currentGridXLeft == blankImage.frame.origin.x && currentGridYLeft == blankImage.frame.origin.y) {
            return Cordinates(x: currentGridXLeft, y: currentGridYLeft, IsValid: true)
        }
        if (currentGridXRight == blankImage.frame.origin.x && currentGridYRight == blankImage.frame.origin.y) {
            return Cordinates(x: currentGridXRight, y: currentGridYRight, IsValid: true)
        }
        if (upGridXPosition == blankImage.frame.origin.x && upGridYPosition == blankImage.frame.origin.y) {
            return Cordinates(x: upGridXPosition, y: upGridYPosition, IsValid: true)
        }
        if (downGridXPosition == blankImage.frame.origin.x && downGridYPosition == blankImage.frame.origin.y) {
            return Cordinates(x: downGridXPosition, y: downGridYPosition, IsValid: true)
        }
        return Cordinates(x: downGridXPosition, y: downGridYPosition, IsValid: false)
    }


    //Shuffle functionality to shuffle all the images

    @IBAction func shuffle(_ sender: Any) {

        var randomShuffleCount = Int.random(in: 30..<40)
        
        for _ in 0..<randomShuffleCount {
            let curr_tile = do_shuffle()
            swap_images(curr_Image: curr_tile)
        }
    }
    
    
    //Function to get the randomised imageviews on screen

    func do_shuffle() -> UIImageView{
        
        var validTiles:[UIImageView] = []
        let emptyTile_xPosition = blankImage.frame.origin.x
        let emptyTile_yPosition = blankImage.frame.origin.y
        
        //checks the location of the tiles adjacent to blank tile
        let leftTile_Position = CGPoint(x: emptyTile_xPosition-93, y: emptyTile_yPosition)
        let rightTile_Position = CGPoint(x: emptyTile_xPosition+93, y: emptyTile_yPosition)
        let upTile_Position = CGPoint(x: emptyTile_xPosition, y: emptyTile_yPosition-93)
        let downTile_Position = CGPoint(x: emptyTile_xPosition, y: emptyTile_yPosition+93)
        //adds the location of the tiles adjacent to blank tile and add it in an array
        for index in 0...imageViews.count-1{
            
            if imageViews[index].frame.origin == leftTile_Position || imageViews[index].frame.origin == rightTile_Position ||
                imageViews[index].frame.origin == upTile_Position || imageViews[index].frame.origin == downTile_Position
            {
                validTiles.append(imageViews[index])
                
            }
        }
        //return any random tile adjacent to blank tile
        guard let randomTile = validTiles.randomElement() else {
            fatalError("There are no valid tiles to shuffle.")
        }
        return randomTile
    }

    
    //Getting the current position of imageview
    //Saving the current position coordinates
    
    func save_currentState(){
        for i in 0...swapState.count-1{
            updatedState.append(swapState[i].center)
        }
        
    }
    
    //Shown answer button functionality to display the original image in the imageview
    //Function for show answer and hide answer buttons
    
    @IBAction func showAnswer(_ sender: Any) {
        if let title = (sender as AnyObject).titleLabel?.text {
            if (title == "Show Answer") {
                lockScreen = false
                //saves the current state of all the images
                save_currentState()
                
                //loops to imageviews and display it according to the initial position
                for i in 0..<imageViews.count {
                    imageViews[i].center = originalState[i]
                }
                (sender as AnyObject).setTitle("Hide", for: .normal)
            } else if (title == "Hide") {
                //loops to imagevies and display it according to the updated position
                for i in 0..<imageViews.count {
                    if i < updatedState.count {
                        swapState[i].center = updatedState[i]
                    }
                }
                (sender as AnyObject).setTitle("Show Answer", for: .normal)
                lockScreen = true
                updatedState = []
            }
        }
    }
    
    // Function to check if puzzle is solved or not
    // Returns a boolean value
    func is_puzzle_solved() -> Bool {
        for i in 0..<imageViews.count {
            if swapState[i] != imageViews[i] {
                return false
            }
        }
        return true
    }

   
}


