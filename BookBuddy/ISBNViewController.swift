//
//  TestViewController.swift
//  BookBuddy
//
//  Created by Tony Nguyen on 1/6/2023.
//

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
    private func updateUI() {

        scanBarButton.addTarget(self, action: #selector(scanBarTapped), for: .touchUpInside)
    }
    
    @objc func scanBarTapped() {
        self.navigationController?.pushViewController(scannerViewController, animated: true)
    }
}

