//
//  ViewController.swift
//  Math Buster
//
//  Created by Zamanbek Kozhas on 17.08.2023.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var problemLabel: UILabel!
    @IBOutlet weak var timerContainerView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var resultField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var difficultyControl: UISegmentedControl!
    
    var dataModel: ViewControllerDataModel = ViewControllerDataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
        generateProblem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dataModel.navigationBarPreviousTintColor = navigationController?.navigationBar.tintColor
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scheduleTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.tintColor = dataModel.navigationBarPreviousTintColor
    }

    func setupUI() {
        
        timerContainerView.layer.cornerRadius = 5
        resultField.keyboardType = .decimalPad
    }
    
    func generateProblem() {
        
        let selectedIndex: Int = difficultyControl.selectedSegmentIndex
        let range = dataModel.ranges[selectedIndex]
        
        let firstDigit = Int.random(in: range)
        let arithmeticOperator: String = ["+", "-", "x", "/"].randomElement()!
        
        var startingInteger: Int = range.lowerBound
        var endingInteger: Int = range.upperBound
        
        if arithmeticOperator == "/" && startingInteger == 0 {
            startingInteger = 1
        } else if arithmeticOperator == "-" {
            endingInteger = firstDigit
        }
        
        let secondDigit = Int.random(in: startingInteger...endingInteger)
        
        problemLabel.text = "\(firstDigit) \(arithmeticOperator) \(secondDigit) = "
        
        switch arithmeticOperator {
        case "+":
            dataModel.result = Double(firstDigit + secondDigit)
        case "-":
            dataModel.result = Double(firstDigit - secondDigit)
        case "x":
            dataModel.result = Double(firstDigit * secondDigit)
        case "/":
            dataModel.result = Double(firstDigit) / Double(secondDigit)
        default:
            dataModel.result = nil
        }
    }
    
    func scheduleTimer() {
        dataModel.countDown = 30
        dataModel.timer?.invalidate()
        dataModel.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerUI), userInfo: nil, repeats: true)
    }
    
    @objc
    func updateTimerUI() {
        dataModel.countDown -= 1
        
        let seconds: String = String(format: "%02d", dataModel.countDown)
        
        
        
        timerLabel.text = "00 : \(seconds)"
        progressView.progress = Float(30 - dataModel.countDown) / 30
        print("progressView.progress: \(progressView.progress)")
        
        if dataModel.countDown <= 0 {
            finishTheGame()
        }
    }
    
    
    @IBAction func submitPressed(_ sender: Any) {
        guard let text = resultField.text else {
            print("Text is nil")
            return
        }
        guard !text.isEmpty else {
            print("Text is empty")
            return
        }
        guard let userResult = Double(text) else {
            print("Could not convert text: \(text) to Double")
            return
        }
        
        if userResult == dataModel.result {
            print("Correct answer!")
            let selectedIndex = difficultyControl.selectedSegmentIndex
            dataModel.score += dataModel.scoreAmount[selectedIndex]
            scoreLabel.text = "Score: \(dataModel.score)"
            
        } else {
            print("Incorrect answer!")
        }
        
        generateProblem()
        resultField.text = nil
    }
    
    @IBAction func restartPressed(_ sender: Any) {
        restart()
    }
    
    func restart() {
        
        dataModel.score = 0
        scoreLabel.text = "Score: 0"
        
        generateProblem()
        
        scheduleTimer()
        
        resultField.isEnabled = true
        submitButton.isEnabled = true
        
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        restart()
    }
    
    func finishTheGame() {
        
        dataModel.timer?.invalidate()
        resultField.isEnabled = false
        submitButton.isEnabled = false
        
        askForName()
    }
    
    func askForName() {
        let alertController = UIAlertController(title: "Game is Over!", message: "Save your score: \(dataModel.score)", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter your name"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alertController.textFields?.first else {
                print("Textfield is absent")
                return
            }
            guard let text = textField.text, !text.isEmpty else {
                print("Textfield is nil or empty")
                return
            }
            print("Name: \(text)")
            
            //TO DO: Save user score record permanently on device
//            self.saveUserScore(name: text)
            self.saveUserScoreAsStruct(name: text)
        }
        alertController.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
//        let skipAction = UIAlertAction(title: "Skip", style: .destructive)
//        alertController.addAction(skipAction)
        
        present(alertController, animated: true)
    }
    
    func saveUserScoreAsStruct(name: String) {
        let userScore: UserScore = UserScore(name: name, score: dataModel.score)
        
        var level: Level?
        switch difficultyControl.selectedSegmentIndex {
        case 0:
            level = .easy
        case 1:
            level = .medium
        case 2:
            level = .hard
        default:
            ()
        }
        
        guard let level = level else {
            print("Lvel is nil because index out of [0,1,2]")
            return
        }
        
        let userScoreArray: [UserScore] = ViewController.getAllUserScores(level: level) + [userScore]
        
        do {
            
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(userScoreArray)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: level.key())
            
        } catch {
            print("Could not encode given [UserScore] into data with error: \(error.localizedDescription)")
        }
    }
    
    static func getAllUserScores(level: Level) -> [UserScore] {
        var result: [UserScore] = []
        
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.object(forKey: level.key()) as? Data {
            do {
                
                let decoder = JSONDecoder()
                result = try decoder.decode([UserScore].self, from: data)
                
            } catch {
                print("Could not decode given data to [UserScore] with error: \(error.localizedDescription)")
            }
        }
        return result
    }
    
    func saveUserScore(name: String) {
        let userScore: [String: Any] = ["name": name, "score": dataModel.score]
        let userScoreArray: [[String: Any]] = getUserScoreArray() + [userScore]
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(userScoreArray, forKey: ViewControllerDataModel.userScoreKey)
    }
    
    func getUserScoreArray() -> [[String: Any]] {
        let userDefaults = UserDefaults.standard
        let array = userDefaults.array(forKey: ViewControllerDataModel.userScoreKey) as? [[String: Any]]
        return array ?? []
    }
}

struct ViewControllerDataModel {
    var timer: Timer?
    var countDown: Int = 30
    var result: Double?
    var score: Int = 0
    var ranges = [0...9, 10...99, 100...999]
    var scoreAmount = [1,2,3]
    
    var navigationBarPreviousTintColor: UIColor?
    
    static let userScoreKey : String = "userScore"
}

struct UserScore: Codable {
    let name: String
    let score: Int
}

enum Level {
    case easy
    case medium
    case hard
    
    func key() -> String {
        switch self {
        case .easy:
            return "easuUserScore"
        case .medium:
            return "mediumUserScore"
        case .hard:
            return "hardUserScore"
        }
    }
}
