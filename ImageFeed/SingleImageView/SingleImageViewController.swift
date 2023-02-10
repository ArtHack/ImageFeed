//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by arthack on 08.02.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {

    @IBAction func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        
        
    }
}
