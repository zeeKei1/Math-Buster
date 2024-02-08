//
//  WelcomeViewController.swift
//  Math Buster
//
//  Created by Zamanbek Kozhas on 29.08.2023.
//

import UIKit

class WelcomeViewController: UIViewController {
    
   
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: [[UserScore]] = [] {
        didSet {
            print("Value of variable 'dataSource' was changed")
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "ScoreTableViewCell", bundle: nil), forCellReuseIdentifier: ScoreTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
//        tableView.rowHeight = 60
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(getUserScore), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getUserScore()
    }
    
    @objc
    func getUserScore() {
        tableView.refreshControl?.endRefreshing()
        
        var easyScoreList = ViewController.getAllUserScores(level: .easy)
        easyScoreList.sort { userScore1, userScore2 in
            return userScore1.score > userScore2.score
        }
        
        var mediumScoreList = ViewController.getAllUserScores(level: .medium)
        mediumScoreList.sort { userScore1, userScore2 in
            return userScore1.score > userScore2.score
        }
        
        var hardScoreList = ViewController.getAllUserScores(level: .hard)
        hardScoreList.sort { userScore1, userScore2 in
            return userScore1.score > userScore2.score
        }
        
        self.dataSource = [easyScoreList, mediumScoreList, hardScoreList]
    }
    
    func getSingleUserText(indexPath: IndexPath) -> String? {
        let userScore: UserScore = dataSource[indexPath.section][indexPath.row]
        let text = "Name: \(userScore.name), Score: \(userScore.score)"
        return text
    }
}

//MARK: UITableViewDataSource & UITableViewDelegate
extension WelcomeViewController:  UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScoreTableViewCell.identifier, for: indexPath) as!
            ScoreTableViewCell
        cell.scoreTextLabel.text = getSingleUserText(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController = ScoreDetailViewController()
        viewController.text = getSingleUserText(indexPath: indexPath)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Easy"
        case 1:
            return "Medium"
        case 2:
            return "Hard"
        default:
            return "Default"
        }
    }
}
