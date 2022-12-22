//
//  ViewController.swift
//  MatchEmNav
//
//  Created by Joseph Neighbors on 11/9/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var gameLabel: UILabel!
    @IBOutlet weak var playGame: UIButton!
    
    var screenBackgroundColor : UIColor? = .white {
        didSet {
            print(screenBackgroundColor)
            
        }
    }
    
    var gamePaused = true
    
    var colorRange: Float = 1.0
    
    var scores = UserDefaults.standard.array(forKey: "highScores") as? [Int] ?? [0,0,0]
    

    @IBAction func play(sender: UIButton!){
        //print("Button pressed")
        startGame()
        playGame.setTitle("", for: .normal)
        playGame.isEnabled = false
        if !buttonDict.isEmpty {
            buttonDict.forEach { button in
                button.key.self.removeFromSuperview()
            }
        }
        if pairCount != 0 {
            pairCount = 0
        }
        if score != 0 {
            score = 0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "test"{
            if let destVC = segue.destination as? SecondViewController {
                
                pauseGame()
                destVC.gameDuration = gameDuration
                destVC.spawnSpeed = newRectInterval
                destVC.backgroundColor = screenBackgroundColor
                destVC.buttonColor = Double(colorRange)
                print("Values sent to second view")
            }
        }
    }
    
    //swipe action
    @IBAction func swipeHander(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            print("Swipe detected")
            //load second view
            //nextView.loadView()
            pauseGame()
            performSegue(withIdentifier: "test", sender: self)
        }
    }
    
    let minRectSize: Float = 50.0
    let maxRectSize: Float = 150.0
    
    var game = Game()
    var matchedButtons = [UIButton: PieceID]()
    var buttonDict = [UIButton: PieceID]()
    var selectedButton: UIButton?
    
    var newRectTimer: Timer?
    var newRectInterval = 1.0
    var gameTimer: Timer?
    var gameDuration = 15.0
    
    let defaults = UserDefaults.standard
    
    var gameStarted = false
    
    var score = 0
    
    var pairCount = 0 {
        didSet {
            gameLabel.text = gameLabelText
        }
    }
    
    lazy var gameTimeRemaining = gameDuration {
        didSet {
            gameLabel?.text = gameLabelText
        }
    }
    
    var gameLabelText: String {
        return "Count: \(pairCount), Score: \(score), Time: \(gameTimeRemaining)"
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted && touches.count == 1 {
            print("Game paused")
            
            pauseGame()
        }
    }
    
    func pauseGame() {
        if gameStarted {
            gamePaused = !gamePaused
            if gamePaused {
                newRectTimer?.invalidate()
            } else {
                newRectTimer = Timer.scheduledTimer(withTimeInterval: newRectInterval, repeats: true, block: {Timer in
                    self.createButton()
                })
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //startGame()
        self.view.isMultipleTouchEnabled = true
        self.view.backgroundColor = screenBackgroundColor
    }
    
    func createButton() {
        
        let id = game.createPiece()
        
        pairCount += 1
        
        let buttonSize: CGSize? = randomSize()
        var buttonLocation: CGPoint?
        var button: UIButton?
        let randomColor = randomColor()
        
        for _ in 0...1{
            buttonLocation = randomLocation(size: buttonSize!)
            button = UIButton(frame: CGRect(origin: buttonLocation!, size: buttonSize!))
            
            button?.backgroundColor = randomColor
            print(button?.backgroundColor)
            button?.titleLabel?.text = ""
            button?.titleLabel?.font = UIFont(name: "Times New Roman", size: 16)
            
            buttonDict[button!] = id
            
            button?.addTarget(self, action: #selector(touchHandler(sender:)), for: .touchUpInside)
            
            self.view.addSubview(button!)
            
            self.view.bringSubviewToFront(gameLabel)
            
            gameTimeRemaining -= 0.5
            
        }
        
        
    }
    
    func startGame() {
        if let highScore = defaults.value(forKey: "highScores") {
            print(highScore)
        } else {
            print("No High Scores")
        }
        
        print(scores)
        
        gamePaused = false
        gameStarted = true
        
        gameTimeRemaining = gameDuration
        
        newRectTimer = Timer.scheduledTimer(withTimeInterval: newRectInterval, repeats: true, block: {Timer in
            self.createButton()
        })
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: gameDuration, repeats: false, block: {Timer in
            self.stopGame()
        })
        
    }
    
    func stopGame() {
        if (newRectTimer != nil) {
            newRectTimer?.invalidate()
            newRectTimer = nil
        }
        
        if (gameTimer != nil) {
            print("Game time set nil")
            gameTimer?.invalidate()
            gameTimer = nil
        }
        //re-enable button to restart game
        playGame.setTitle("Play Again", for: .normal)
        playGame.isEnabled = true
        self.view.bringSubviewToFront(playGame)
        
        gamePaused = true
        gameStarted = false
        
        guard score > scores.last ?? 0 else {return}
        print("New high score")
        scores.append(score)
        scores.sort(by: >)
        
        if gameTimer == nil {
            print("New high score added")
            defaults.setValue(scores, forKey: "highScores")
        }
    }
    
    func removeFromView(_ button:UIButton) {
        button.removeFromSuperview()
        var buttonsRemain = false
        for elem in view.subviews {
            if elem.isKind(of: UIButton.self) {
                buttonsRemain = true
                print("This is a test")
            }
        }
    }
    
    func toMatchedDict(btn1: UIButton, btn2: UIButton) {
        matchedButtons[btn1] = buttonDict[btn1]
        matchedButtons[btn2] = buttonDict[btn2]
    }
    
    var streak = 0
    
    @objc func touchHandler(sender: UIButton) {
        if gameStarted && !gamePaused {
            //change emoji based on streak 💀->😎->🔥
            let pieceID = buttonDict[sender]
            
            if selectedButton == nil {
                selectedButton = sender
                if streak < 3 {
                    selectedButton?.setTitle("💀", for: .normal)
                } else if streak >= 3 && streak < 8 {
                    selectedButton?.setTitle("😎", for: .normal)
                } else if streak >= 8 {
                    selectedButton?.setTitle("🔥", for: .normal)
                }
                print("First button selected")
            } else {
                if buttonDict[selectedButton!] == pieceID && selectedButton !== sender {
                    score += 1
                    streak += 1
                    removeFromView(sender)
                    removeFromView(selectedButton!)
                    
                    toMatchedDict(btn1: sender, btn2: selectedButton!)
                    print("Second button selected")
                } else {
                    selectedButton?.setTitle("", for: .normal)
                    if(score > 0) {
                        score -= 1
                        streak = 0
                    }
                    print("Not a match ):")
                }
                selectedButton = nil
            }
            print("Button \(pieceID!) was selected")
        }
        
        
        
        
        //sender.removeFromSuperview()
        //figure out how to end game when not tapping on button
    }
    
    func randomFloatInRange(start: Float, end:Float) -> Float {
        return Float.random(in: start...end)
    }
    
    func randomFloatZeroToOne() -> Float {
        return Float.random(in: 0.0...1.0)
    }
    
    func randomColorRange() -> Float {
        return Float.random(in: 0.0...colorRange)
    }
    
    func randomSize() -> CGSize {
        let width = randomFloatInRange(start: minRectSize, end: maxRectSize)
        let height = randomFloatInRange(start: minRectSize, end: maxRectSize)
        
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
    
    func randomLocation(size: CGSize) -> CGPoint {
        let x = CGFloat(randomFloatZeroToOne()) * (view.bounds.size.width - size.width)
        let y = CGFloat(randomFloatZeroToOne()) * (view.bounds.size.height - size.height)
        
        return CGPoint(x: x, y: y)
    }
    
    func randomColor() -> UIColor {
        let r = CGFloat(randomColorRange())
        let g = CGFloat(randomColorRange())
        let b = CGFloat(randomColorRange())
        
        let alpha = 1.0
        
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }

}

typealias PieceID = Int

class Game: NSObject {
    var nextID = 0
    
    func createPiece() -> PieceID {
        nextID += 1
        
        return nextID
    }
    
    func isSelected() -> Bool {
        return false
    }
}
