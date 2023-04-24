//
//  ViewController.swift
//  ImageFeed
//
//  Created by Unwraper Man on 20.01.2023.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListCellDelegate {
    
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
            let photo = photos[indexPath.row]
            guard let imageURL = URL(string: photo.largeImageURL!) else { return }
            viewController.imageURL = imageURL
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
            if let date = imagesListService.photos[indexPath.row].createdAt {
                cell.dateLabel.text = dateFormatter.string(from: date)
            } else {
                cell.dateLabel.text = ""
            }
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
        imageListCell.delegate = self
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
        let cell = photos[indexPath.row]
        let imageSize = CGSize(width: cell.width, height: cell.height)
        let aspectRatio = imageSize.width / imageSize.height
        return tableView.frame.width / aspectRatio
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD().show()
        imagesListService.changeLike(photoId: photo.id,
                                     isLiked: photo.isLiked) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                    UIBlockingProgressHUD().dismiss()
                case .failure(let error):
                    UIBlockingProgressHUD().dismiss()
                    self.showLikeErrorAlert(with: error)
                }
            }
        }
    }
    
    private func showLikeErrorAlert(with error: Error) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось поставить лайк",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}

