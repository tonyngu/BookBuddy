//
//  TestViewController.swift
//  BookBuddy
//
//  Created by Tony Nguyen on 1/6/2023.
//  Tutorial followed: https://levelup.gitconnected.com/building-bar-code-scanner-app-in-swift-1de4ab1e1079

import UIKit

class ISBNViewController: UIViewController, ScannerViewDelegate {
    func didFindScannedText(text: String) {
        scanTextField.text = text
    }
    
    @IBOutlet weak var scanTextField: UITextField!
    @IBOutlet weak var scanBarButton: UIButton!
    let scannerViewController = ScannerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        scannerViewController.delegate = self
    }
}

extension ISBNViewController {
    
    // updateUI method trigger when button is push
    private func updateUI() {

        scanBarButton.addTarget(self, action: #selector(scanBarTapped), for: .touchUpInside)
    }
    // send user to scannerViewContrller
    @objc func scanBarTapped() {
        self.navigationController?.pushViewController(scannerViewController, animated: true)
    }
}

