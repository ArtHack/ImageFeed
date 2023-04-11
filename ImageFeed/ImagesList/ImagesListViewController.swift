//
//  ViewController.swift
//  ImageFeed
//
//  Created by Unwraper Man on 20.01.2023.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        imagesListServiceObserver = NotificationCenter.default.addObserver(
                     forName: ImagesListService.didChangeNotification,
                     object: nil, queue: .main
                 ) { [weak self] _ in
                     guard let self = self else { return }
                     self.updateTableViewAnimated()
                 }
                imagesListService.fetchPhotosNextPage()
             }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: ImagesListService.didChangeNotification, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let imageName = photos[indexPath.row]
            let image = UIImage(named: "\(imageName)_full_size") ?? UIImage()
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates{
                    let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                    tableView.insertRows(at: indexPaths, with: .bottom)
            } completion: { _ in }
        }
    }
}

//MARK: - ImagesListViewController Extensions

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell,
                    with indexPath: IndexPath) {
        if let urlString = imagesListService.photos[indexPath.row].thumbImageURL,
           let imagesURL = URL(string: urlString) {
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(with: imagesURL,
                                       placeholder: UIImage(named: "scribble.variable")) { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            cell.dateLabel.text = dateFormatter.string(from: imagesListService.photos[indexPath.row].createdAt ?? Date())
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                     numberOfRowsInSection section: Int) -> Int {
        return imagesListService.photos.count
    }
    func tableView(_ tableView: UITableView,
                     cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
          return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                     didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageHeight = imagesListService.photos[indexPath.row].size.height
        let imageWidth = imagesListService.photos[indexPath.row].size.width
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

