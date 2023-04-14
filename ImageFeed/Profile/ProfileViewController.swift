//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by arthack on 04.02.2023.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileService = ProfileService.shared
    private let token = OAuth2TokenStorage()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 35.0
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.font = .boldSystemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.font = .systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "logout_button")!,
            target: self,
            action: #selector(self.didTapLogoutButton)
        )
        button.tintColor = .ypRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        setupLayout()
        updateProfileDetails()
        updateAvatar()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidCahngeNottification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        }

    private func addSubviews() {
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([

            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),

            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),

            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26),
            logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
            ])
    }
    
    private func updateProfileDetails() {
        nameLabel.text = profileService.profile?.name
        loginNameLabel.text = profileService.profile?.loginName
        descriptionLabel.text = profileService.profile?.bio
    }
    
    private func updateAvatar() {
        view.backgroundColor = .ypBlack
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url,
                              placeholder: UIImage(named: "tab_profile_active"),
                              options: [.cacheSerializer(FormatIndicatedCacheSerializer.png)]
        )
        imageView.contentMode = .scaleAspectFill
    }
    
    @objc
    private func didTapLogoutButton() {
        showLogoutAlert()
    }
    
    private func logOut() {
        token.clearToken()
        WebViewViewController.clean()
        cleanServiceData()
        tabBarController?.dismiss(animated: true)
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        window.rootViewController = SplashViewController()
    }
    
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да",
                                      style: .default,
                                     handler: { [weak self] action in
            guard let self = self else { return }
            self.logOut()
        }))
        alert.addAction(UIAlertAction(title: "Нет",
                                      style: .default,
                                     handler: nil))
        present(alert, animated: true, completion: nil)
    }
                        
    private func cleanServiceData() {
            ImagesListService.shared.imagesListServiceClean()
            ProfileImageService.shared.clean()
            profileService.clean()
            
    }
}

