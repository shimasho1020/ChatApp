//
//  CustomView.swift
//  ChatApp
//
//  Created by 島田将太郎 on 2023/01/01.
//

import Foundation
import UIKit

extension UIImage {
    func resize(toWidth width: CGFloat) -> UIImage? {
        let resizedSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
