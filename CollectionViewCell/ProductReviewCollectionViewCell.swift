//
//  ProductReviewCollectionViewCell.swift
//  MarketKurly
//
//  Created by MK-Mac-210 on 2021/02/23.
//  Copyright © 2021 TheFarmers, Inc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class ProductReviewCollectionViewCell: BaseCollectionViewCell, PostCellComponentProtocol {
  
  // MARK: - UI comoponents
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.distribution = .fill
    $0.spacing = 7
  }
  
  private let titleStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fill
    $0.spacing = 8
  }
  
  private let nameAndDateStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fill
    $0.spacing = 8
  }
  
  private let titleTagView = PostTagView(frame: .zero)
  
  private let titleLabel = UILabel().then {
    $0.font = UIFont.system.bold(14)
  }
  
  private let attatchedImage = UIImageView().then {
    $0.image = R.image.review_btn_attc()
    $0.contentMode = .scaleAspectFit
  }
  
  private let userTag = PostTagView(frame: .zero)
  
  private let userNameLabel = UILabel().then {
    $0.font = UIFont.system.regular(14)
    $0.textColor = .presetTextMedium
  }
  
  private let verticalLineView = UIView().then {
    $0.backgroundColor = .presetLightGray
  }
  
  private let dateLabel = UILabel().then {
    $0.font = UIFont.system.regular(14)
    $0.textColor = .presetTextMedium
  }
  
  private let bottomLine = UIView().then {
    $0.backgroundColor = .presetBg
  }
  
  // MARK: - PostCellComponentProtocol Property
  var postType: PostType?
  
  var postData: Post? {
    didSet {
      guard let `postData` = postData else { return }
      postType = postData.postType
      self.configureData(post: postData)
    }
  }
  
  // MARK: Initializer
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.contentView.backgroundColor = .white
    self.addSubviews()
  }
  
  private func addSubviews() {

    self.contentView.add(
      self.contentStackView.withArranged(
        self.titleStackView.withArranged(
          self.titleTagView,
          self.titleLabel,
          self.attatchedImage
        ),
        self.nameAndDateStackView.withArranged(
          self.userTag,
          self.userNameLabel,
          self.verticalLineView,
          self.dateLabel
        )
      ),
      self.bottomLine
    )
  }
  
  // MARK: Layout
  override func makeConstraints() {
    super.makeConstraints()
    
    self.contentStackView.snp.makeConstraints { make in
      make.top.equalTo(contentView).offset(0)
      make.leading.trailing.equalTo(contentView)
    }

    self.titleStackView.snp.makeConstraints { make in
      make.height.equalTo(20)
    }

    self.nameAndDateStackView.snp.makeConstraints { make in
      make.height.equalTo(16)
    }
    
    self.titleTagView.snp.makeConstraints { make in
      make.height.equalTo(20)
    }
        
    self.attatchedImage.snp.makeConstraints { make in
      make.width.height.equalTo(CGSize(width: 14, height: 14))
    }
        
    self.verticalLineView.snp.makeConstraints { make in
      make.width.height.equalTo(CGSize(width: 1, height: 12))
    }
    
    self.userTag.snp.makeConstraints { make in
      make.width.height.equalTo(CGSize(width: 38, height: 18))
    }
    
    self.bottomLine.snp.makeConstraints { make in
      make.bottom.equalTo(contentView.snp.bottom)
      make.leading.trailing.equalTo(contentView)
      make.height.equalTo(1)
    }
  }
    
  func configureData(post: Post) {

    self.titleStackView.snp.remakeConstraints { make in
      make.top.equalTo(contentView).offset(isNoticeCell ? 8 : 16)
    }
    
    self.nameAndDateStackView.isHidden = isNoticeCell
    self.bottomLine.isHidden = isNoticeCell
    self.attatchedImage.isHidden = true
    
    self.titleTagView.tagType = typeForTagView
    self.titleTagView.isHidden = isTitleTagHidden
    self.titleTagView.snp.remakeConstraints { make in
      make.width.equalTo(post.postType == .notice ? 30 : 38)
    }
      
    self.titleLabel.text = post.subject
    self.titleLabel.font = fontTypeForTitleLabel
    
    if post.postType != .notice {
      self.attatchedImage.isHidden = !post.hasAttachment
      self.userTag.tagType = .userGrade(type: post.userGrade)
      self.userTag.isHidden = post.userGrade.isHiddenInList
      
      self.userNameLabel.text = post.userName
      self.userNameLabel.snp.remakeConstraints { make in
        make.width.equalTo(userNameLabel.intrinsicContentSize.width)
      }
      
      self.dateLabel.text = post.registeredDate.format()
    }
  }
  
  deinit {
    DLog.verbose("product review cell 👋")
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
