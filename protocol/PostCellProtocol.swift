//
//  PostCellProtocol.swift
//  MarketKurly
//
//  Created by MK-Mac-210 on 2021/02/26.
//  Copyright © 2021 TheFarmers, Inc. All rights reserved.
//

import Foundation
import UIKit

protocol PostCellComponentProtocol {
  var postType: PostType? { get set }
  var isNoticeCell: Bool { get }
  var typeForTagView: TagType { get }
  var isTitleTagHidden: Bool { get }
  var fontTypeForTitleLabel: UIFont { get }
}

extension PostCellComponentProtocol {
  var isNoticeCell: Bool {
    switch postType {
    case .notice:
      return true
    default:
      return false
    }
  }

  var typeForTagView: TagType {
    switch postType {
    case .notice:
      return .notice
    case .best:
      return .best
    default:
      return .none
    }
  }

  var isTitleTagHidden: Bool {
    switch postType {
    case .notice, .best:
      return false
    case .normal:
      return true
    default:
      return true
    }
  }

  var fontTypeForTitleLabel: UIFont {
    switch postType {
    case .notice:
      return UIFont.system.semibold(14)
    case .best:
      return UIFont.system.regular(14)
    default:
      return UIFont.system.regular(14)
    }
  }
}
