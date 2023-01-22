import UIKit

class SecondViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    @IBOutlet weak var controlSpeed: UISlider!
    @IBOutlet weak var controlTimer: UISlider!
    @IBOutlet weak var controlColor: UIPickerView!
    @IBOutlet weak var controlButtonColor: UISlider!
    
    @IBOutlet weak var speedText: UILabel!
    @IBOutlet weak var timerText: UILabel!
    @IBOutlet weak var colorText: UILabel!
    @IBOutlet weak var scoreOne: UILabel!
    @IBOutlet weak var scoreTwo: UILabel!
    @IBOutlet weak var scoreThree: UILabel!
    
    
    //first screen objects
    var spawnSpeed : Double?
    var gameDuration : Double?
    var backgroundColor : UIColor?
    var buttonColor: Double?
    
    var mainController: ViewController?
    
    var scores = UserDefaults.standard.array(forKey: "highScores") as? [Int] ?? [0,0,0]
    
    var gamePaused: Bool?
    var gameStarted: Bool?
    
    @IBAction func sliderValue(_ sender:UISlider){
        var currentValue = Double(sender.value)
        speedText.text = "\(currentValue)"
        spawnSpeed = currentValue
        print(spawnSpeed)
        mainController?.newRectInterval = spawnSpeed!
    }
    
    @IBAction func timerSliderValue(_ sender:UISlider){
        var currentValue = Double(sender.value)
        timerText.text = "\(currentValue)"
        gameDuration = currentValue
        print(gameDuration)
        mainController?.gameDuration = gameDuration!
    }
    
    @IBAction func buttonSliderValue(_ sender:UISlider) {
        var currentValue = Double(sender.value)
        colorText.text = "\(currentValue)"
        buttonColor = currentValue
        mainController?.colorRange = Float(buttonColor!)
    }
    
    let colorArr = ["Blue", "Green", "Red", "White", "Brown"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("second view loaded")
        
        mainController = self.navigationController!.viewControllers[0] as! ViewController
        
        controlColor.dataSource = self
        controlColor.delegate = self
        
        speedText.text = "\(spawnSpeed!)"
        timerText.text = "\(gameDuration!)"
        colorText.text = "\(buttonColor!)"
        
        gamePaused = mainController?.gamePaused
        gameStarted = mainController?.gameStarted
        
        controlTimer.value = Float(gameDuration!)
        controlSpeed.value = Float(spawnSpeed!)
        controlButtonColor.value = Float(buttonColor!)
        
        controlTimer.maximumValue = 100
        controlTimer.minimumValue = 15
        
        controlSpeed.maximumValue = 10
        controlSpeed.minimumValue = 0
        
        controlButtonColor.maximumValue = 1
        controlButtonColor.minimumValue = 0
        
        scoreOne.text = "1. \(scores[0])"
        scoreTwo.text = "2. \(scores[1])"
        scoreThree.text = "3. \(scores[2])"
        
        print(gameDuration)
        
        print(scores)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if gamePaused! && gameStarted! {
            //mainController?.gamePaused = false
            mainController?.pauseGame()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colorArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return colorArr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            // This method is triggered whenever the user makes a change to the picker selection.
            // The parameter named row and component represents what was selected.
        let selected = controlColor.selectedRow(inComponent: 0)
        switch selected{
        case 0:
            backgroundColor = .blue
            mainController?.view.backgroundColor = .blue
            break
        case 1:
            backgroundColor = .green
            mainController?.view.backgroundColor = .green
            break
        case 2:
            backgroundColor = .red
            mainController?.view.backgroundColor = .red
            break
        case 3:
            backgroundColor = .white
            mainController?.view.backgroundColor = .white
            break
        case 4:
            backgroundColor = .brown
            mainController?.view.backgroundColor = backgroundColor
            break
        default:
            backgroundColor = .white
            mainController?.view.backgroundColor = backgroundColor
            break
        }
    }

    
}
