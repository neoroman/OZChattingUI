//
//  StartViewController.swift
//  OZChattingUI_Example
//
//  Created by Henry Kim on 2020/06/04.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import OZChattingUI
import SafariServices

let kMainColor = UIColor(red: 44/255, green: 187/255, blue: 182/255, alpha: 1)

class StartViewController: UITableViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    let cells = ["Basic Example", "Basic Example (storyboard)", "Advanced Example (storyboard)", "Advanced Example (storyboard)\n + custom frame", "Source Code", "CocoaPods"]
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = kMainColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        }
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.view.backgroundColor = kMainColor

        title = "OZChattingUI"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
    
    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        cell.textLabel?.text = cells[indexPath.row]
        cell.textLabel?.numberOfLines = 2
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = cells[indexPath.row]
        switch cell {
        case "Basic Example":
            let vc = ExampleViewController()
            vc.title = cell
            navigationController?.pushViewController(vc, animated: true)
        case "Basic Example (storyboard)":
            let storyboard = UIStoryboard(name: "OZChattingUI", bundle: Bundle.main)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ExampleViewController") as? ExampleViewController {
                navigationController?.pushViewController(vc, animated: true)
                vc.title = cell
            }
        case "Advanced Example (storyboard)":
            let storyboard = UIStoryboard(name: "OZChattingUI2", bundle: Bundle.main)
            if let vc = storyboard.instantiateViewController(withIdentifier: "OZChattingUI2") as? ChattingViewController {
                navigationController?.pushViewController(vc, animated: true)
                vc.title = cell
            }
        case "Advanced Example (storyboard)\n + custom frame":
            let storyboard = UIStoryboard(name: "OZChattingUI2", bundle: Bundle.main)
            if let vc = storyboard.instantiateViewController(withIdentifier: "OZChattingUI2") as? ChattingViewController {
                navigationController?.pushViewController(vc, animated: true)
                vc.title = cell
                vc.isCustomFrame = true
            }
        case "Real Advanced Example":
            let message = "ChattingViewController not implemented yet."
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let viewController = UIApplication.shared.keyWindow?.rootViewController
            viewController?.present(alert, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                alert.dismiss(animated: true, completion: nil)
            })
        case "Source Code":
            guard let url = URL(string: "https://github.com/neoroman/OZChattingUI") else { return }
            openURL(url)
        case "CocoaPods":
            guard let url = URL(string: "https://cocoapods.org/pods/OZChattingUI") else { return }
            openURL(url)
        default:
            assertionFailure("You need to impliment the action for this cell: \(cell)")
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = cells[indexPath.row]
        switch cell {
        case "Advanced Example (storyboard)\n + custom frame":
            return 80
        default:
            return 60
        }
    }
    
    func openURL(_ url: URL) {
        let webViewController = SFSafariViewController(url: url)
        if #available(iOS 10.0, *) {
            webViewController.preferredControlTintColor = kMainColor
        }
        present(webViewController, animated: true, completion: nil)
    }

}
