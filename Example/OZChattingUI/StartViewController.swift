/*
MIT License

Copyright (c) 2020 OZChattingUI, Henry Kim <neoroman@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
//
//  StartViewController.swift
//  OZChattingUI_Example
//
//  Created by Henry Kim on 2020/06/04.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit
import OZChattingUI
import SafariServices

let kMainColor = UIColor(red: 44/255, green: 187/255, blue: 182/255, alpha: 1)

class StartViewController: UITableViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    let cells = ["Basic Example", "Basic Example (storyboard)", 
                 "Advanced Example (storyboard)", 
                 "Advanced Example + TabBar (storyboard)", 
                 "Advanced Example (storyboard)\n + custom frame", 
                 "Source Code", "CocoaPods"]
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = kMainColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.view.backgroundColor = kMainColor

        title = "OZChattingUI"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
                    vc.isFromStoryboard = true
                }
            case "Advanced Example (storyboard)":
                let storyboard = UIStoryboard(name: "OZChattingUI2", bundle: Bundle.main)
                if let vc = storyboard.instantiateViewController(withIdentifier: "OZChattingUI2") as? ChattingViewController {
                    navigationController?.pushViewController(vc, animated: true)
                    vc.title = cell
                }
            case "Advanced Example + TabBar (storyboard)":
                let tabVC = UITabBarController();
                let storyboard = UIStoryboard(name: "OZChattingUI2", bundle: Bundle.main)
                if let vc = storyboard.instantiateViewController(withIdentifier: "OZChattingUI2") as? ChattingViewController,
                   let vc2 = storyboard.instantiateViewController(withIdentifier: "OZChattingUI2") as? ChattingViewController {
                    vc.tabBarItem = UITabBarItem(title: "tab1", image: UIImage(named: "oz1024"), tag: 0) 
                    vc2.view.frame = vc.view.frame;
                    vc2.view.backgroundColor = UIColor.yellow
                    vc2.tabBarItem = UITabBarItem(title: "tab2", image: UIImage(named: "oz1013"), tag: 0)
                    let vc3 = UIViewController();
                    vc3.view.frame = vc.view.frame;
                    vc3.view.backgroundColor = UIColor.brown
                    vc3.tabBarItem = UITabBarItem(title: "tab3", image: UIImage(named: "oz1003"), tag: 0)
                    let vc4 = UIViewController();
                    vc4.view.frame = vc.view.frame;
                    vc4.view.backgroundColor = UIColor.gray
                    vc4.tabBarItem = UITabBarItem(title: "tab4", image: UIImage(named: "oz1004"), tag: 0)
                    tabVC.viewControllers = [vc, vc2, vc3, vc4];
                    tabVC.selectedIndex = 0
                    navigationController?.pushViewController(tabVC, animated: true)
                    tabVC.title = cell
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                        let cv = vc.collectionView                        
                        if let ozic = vc.ozInputContainer {
                            cv.translatesAutoresizingMaskIntoConstraints = false
                            cv.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
                            cv.bottomAnchor.constraint(equalTo: ozic.topAnchor, constant: 0).isActive = true
                            cv.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 0).isActive = true
                            cv.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: 0).isActive = true
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+3.1) {
                        if let timer = vc.receiveTimer {
                            timer.invalidate()
                        }
                        if let timer = vc2.receiveTimer {
                            timer.invalidate()
                        }

                    }
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
