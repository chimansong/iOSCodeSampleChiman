//
//  ViewAllCollectionViewFooterCell.swift
//  MarketKurly
//
//  Created by MK-Mac-210 on 2021/02/24.
//  Copyright © 2021 TheFarmers, Inc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol ViewAllCollectionViewFooterCellDelegate: class {
  func didTapViewAllButton()
}

final class ViewAllCollectionViewFooterCell: BaseCollectionViewCell {
  
  private lazy var listButton = UIButton().then {
    $0.applyStyle(.list)
    $0.setTitle(R.string.localizable.productReviewBtnShowAll(), for: .normal)
    $0.titleLabel?.font = UIFont.system.medium(14)
    $0.titleLabel?.textColor = .presetText
    $0.setImage(R.image.arrowGray()?.withRenderingMode(.alwaysTemplate), for: .normal)
    $0.setImageSide(side: .right)
    $0.imageView?.tintColor = .presetText
    $0.addTarget(self, action: #selector(viewMoreTapped), for: .touchUpInside)
  }
  
  weak var delegate: ViewAllCollectionViewFooterCellDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubviews()
    makeConstraints()
  }
  
  func addSubviews() {
    self.contentView.addSubview(self.listButton)
  }
  
  // MARK: Layout
  override func makeConstraints() {
    super.makeConstraints()
    self.listButton.snp.makeConstraints {
      $0.center.equalTo(contentView.snp.center)
      $0.size.equalTo(CGSize(width: 49 + 16, height: 20))
    }
  }
  
  @objc func viewMoreTapped() {
    self.delegate?.didTapViewAllButton()
  }
  
  deinit {
    DLog.verbose("view all button 👋")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
