//
//  ProductViewViewControllerChiman.swift
//  MarketKurly
//
//  Created by MK-Mac-210 on 2021/02/23.
//  Copyright © 2021 TheFarmers, Inc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import ReusableKit

class ProductReviewViewControllerChiman: BaseViewController, Themeable, TabPageContentViewControllerProtocol {
 
  private enum Reusable {
    static let reviewCell = ReusableCell<ProductReviewCollectionViewCell>()
    static let footerCell = ReusableView<ViewAllCollectionViewFooterCell>()
  }
  
  //MARK: - Property
  private let notificationManager = NotificationManager()
  
  var productData: Product? {
    didSet {
      if let identifier = productData?.identifier {
        self.requestProductReviewsPickOut(identifier)
      }
    }
  }
  
  var postsData: [Post] = [] {
    didSet {
      self.collectionView.reloadData()
    }
  }
  
  var bottomButtonContentInset: CGFloat? {
    didSet {
      self.collectionView.contentInset.bottom += self.bottomButtonContentInset ?? 0.f
    }
  }
  
  var footerHeight: CGFloat = 0
  
  //MARK: - UI Components
  private let writeButton = UIButton().then {
    $0.applyStyle(.write)
    $0.setTitle(R.string.localizable.productReviewBtnCompose(), for: .normal)
    $0.layer.cornerRadius = 6
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.presetKurlyPurple.cgColor
    $0.addTarget(self, action: #selector(presentComposeViewController), for: .touchUpInside)
  }
  
  private var collectionView: UICollectionView!
    
  override func makeConstraints() {
    super.makeConstraints()
    self.writeButton.snp.makeConstraints { make in
      make.top.equalTo(self.view.snp.top).offset(20)
      make.width.equalTo(self.view.frame.width - 40)
      make.height.equalTo(48)
      make.centerX.equalTo(self.view)
    }
    
    self.collectionView.snp.makeConstraints { make in
      make.top.equalTo(self.writeButton.snp.bottom).offset(10)
      make.left.right.equalToSuperview()
      make.bottom.equalTo(self.view.snp.bottom)
    }
  }
  
  deinit {
    print("product review controller deinit successfull")
    DLog.verbose("product review controller 👋")
  }
}

// MARK: - Data
extension ProductReviewViewControllerChiman {
  func requestProductReviewsPickOut(_ productIdentifier: String) {
    RequestManager.shared.requestProductReviewsPickOut(productIdentifier) { [weak self] in
      guard let `self` = self else { return }
      guard let json = $0.json else {
        DLog.error($0.error as Any)

        return
      }

      let data = json["data"]
      self.footerHeight = data["has_more_data"].boolValue ? 44 : 0
      self.postsData = data["reviews"].arrayValue.map { Post($0) }
    }
  }
}

// MARK: - Lifecycle
extension ProductReviewViewControllerChiman {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.configureCollectionView()
    self.configureNotificationManager()
    self.addComponentsToView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    guard canHandleLifeCycleAction else {
      return
    }
    DLog.verbose("")

    AmplitudeManager.shared.updateScreenName(.productDetailReview, isForce: false)

    self.view.applyBorder()
  }
}

// MARK: - Private
private extension ProductReviewViewControllerChiman {
  func addComponentsToView() {
    self.view.add(
      self.writeButton,
      self.collectionView
    )
  }
  
  func configureCollectionView() {
    let layout = UICollectionViewFlowLayout()
    self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    self.collectionView.backgroundColor = .white
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
    self.collectionView.register(Reusable.reviewCell)
    self.collectionView.register(Reusable.footerCell, kind: .footer)
  }
  
  func configureNotificationManager() {
    notificationManager.addObserver(forNames: [.updateProductReviews, .removeProductReview], object: nil) { [weak self] _ in
      guard let `self` = self, let identifier = self.productData?.identifier else { return }
      self.requestProductReviewsPickOut(identifier)
    }
  }
  
  func presentWeb(link: Linkable) {
    guard let productViewController = self.tabPageViewController?.parent as? ProductViewController else { return }
    guard let controller = R.storyboard.main.webViewController() else { return }
    controller.isShowNavigationPanel = false
    controller.link = link
    productViewController.show(controller, sender: nil)
  }
  
  @objc func presentComposeViewController() {
    DispatchQueue.main.async {
      let isGuest = SessionManager.shared.isGuest
      if isGuest {
        self.presentLogin()
      } else {
        guard let productIdentifier = self.productData?.identifier else {
          return
        }

        RequestManager.shared.requestProductReviewsVerifyPermissions(productIdentifier) { [weak self] in
          guard let `self` = self else { return }
          guard $0.json != nil else {
            DLog.error($0.error as Any)

            ToastManager.shared.show($0.error?.message, type: .error)

            return
          }

          self.presentMyReview()
        }
      }
    }
  }
  
  func presentLogin() {
    guard let controller = R.storyboard.main.loginViewController() else { return }
    controller.configure(
      successDismissType: .block { [weak self] in
        self?.presentComposeViewController()
      },
      guestOrderType: .disable
    )
    let navigationController = LoginNavigationController(rootViewController: controller).then {
      $0.modalPresentationStyle = .fullScreen
    }
    self.present(navigationController, animated: true)
  }
  
  func presentMyReview() {
    guard let controller = R.storyboard.myKurly.reviewViewController() else { return }
    let navigationController = ReviewNavigationController(rootViewController: controller).then {
      $0.modalPresentationStyle = .fullScreen
    }
    self.present(navigationController, animated: true)
  }
    
  func presentReviewList() {
    guard let productViewController = self.tabPageViewController?.parent as? ProductViewController else { return }
    guard let controller = R.storyboard.product.productReviewListViewController() else { return }
    controller.product = self.productData
    productViewController.show(controller, sender: nil)
  }
}

extension ProductReviewViewControllerChiman: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let post = postsData[indexPath.row]
    if let productIdentifier = productData?.identifier, let postIdentifier = post.identifier {
      AmplitudeManager.shared.updateProductReviewPosition(indexPath.row, in: postsData)

      let link = Godo.productReviewContent(productIdentifier, postIdentifier, .product, post.postType)
      self.presentWeb(link: link)
    }
  }
}

extension ProductReviewViewControllerChiman: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.postsData.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell: ProductReviewCollectionViewCell = collectionView.dequeue(Reusable.reviewCell, for: indexPath)
    let data = postsData[indexPath.item]
    cell.postData = data
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch kind {
    case UICollectionView.elementKindSectionFooter:
      let cell: ViewAllCollectionViewFooterCell = collectionView.dequeue(Reusable.footerCell, kind: .footer, for: indexPath)
      cell.delegate = self
      return cell
    default:
      fatalError()
    }
  }
}

extension ProductReviewViewControllerChiman: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let data = postsData[indexPath.item]
    if data.postType == .notice {
      return CGSize(width: view.frame.width - 40, height: 36)
    } else {
      return CGSize(width: view.frame.width - 40, height: 77)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    CGSize(width: view.frame.width, height: self.footerHeight)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
}

extension ProductReviewViewControllerChiman: ViewAllCollectionViewFooterCellDelegate {
  func didTapViewAllButton() {
    self.presentReviewList()
  }
}
