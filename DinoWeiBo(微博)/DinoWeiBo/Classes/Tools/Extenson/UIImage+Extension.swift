//
//  UIImage+Extension.swift
//  003@照片选择
//
//  Created by liu yao on 2017/3/9.
//  Copyright © 2017年 深圳多诺信息科技有限公司. All rights reserved.
//

import UIKit

extension UIImage {
    
    
    /// View的高
    var height : CGFloat {
        get {
            return self.size.height
        }
    }
    
    /// View的宽
    var width : CGFloat {
        get {
            return self.size.width
        }
    }
    
    /// 水平翻转
    ///
    /// - Returns: 返回水平翻转的图片
    func flipHorizontal() -> UIImage? {
        return self.rotate(orientation: .upMirrored)
    }
    /// 向下翻转
    ///
    /// - Returns: <#return value description#>
    func flipDown() -> UIImage? {
        return self.rotate(orientation: .down)
    }
    
    /// 向左翻转
    ///
    /// - Returns: <#return value description#>
    func flipLeft() -> UIImage? {
        return self.rotate(orientation: .left)
    }
    
    /// 镜像向左翻转
    ///
    /// - Returns: <#return value description#>
    func flipLeftMirrored() -> UIImage? {
        return self.rotate(orientation: .leftMirrored)
    }
    
    /// 向右翻转
    ///
    /// - Returns: <#return value description#>
    func flipRight() -> UIImage? {
        return self.rotate(orientation: .right)
    }
    
    /// 镜像向右翻转
    ///
    /// - Returns: <#return value description#>
    func flipRightMirrored() -> UIImage? {
        return self.rotate(orientation: .rightMirrored)
    }
    
    /// 图片翻转
    ///
    /// - Parameter orientation: 翻转类型
    /// - Returns: 翻转后的图片
    private func rotate(orientation: UIImageOrientation) -> UIImage? {
        
        let imageRef = self.cgImage
        let rect = CGRect(x: 0, y: 0, width: (imageRef?.width)!, height: (imageRef?.height)!)
        var bounds = rect
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch orientation {
            
        case .up:
            return self
            
        case .upMirrored:
            transform = CGAffineTransform(translationX: rect.size.width, y: 0)  //图片左平移width个像素
            transform = transform.scaledBy(x: -1, y: 1)                         //缩放
            
        case .down:
            transform = CGAffineTransform(translationX: rect.size.width, y: rect.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
            
        case .downMirrored:
            transform = CGAffineTransform(translationX: 0, y: rect.size.height)
            transform = transform.scaledBy(x: 1, y: -1)
            
        case .left:
            swapWidthAndHeight(rect: &bounds)
            transform = CGAffineTransform(translationX:0 , y: rect.size.width)
            transform = transform.rotated(by:  CGFloat(M_PI) * 1.5)
            
        case .leftMirrored:
            swapWidthAndHeight(rect: &bounds)
            transform = CGAffineTransform(translationX:rect.size.height , y: rect.size.width)
            transform = transform.scaledBy(x: -1, y: 1)
            transform = transform.rotated(by: CGFloat(M_PI) * 1.5)
            
        case .right:
            swapWidthAndHeight(rect: &bounds)
            transform = CGAffineTransform(translationX:rect.size.height , y: 0)
            transform = transform.rotated(by: CGFloat(M_PI) / 2)
            
        case .rightMirrored:
            swapWidthAndHeight(rect: &bounds)
            transform = transform.scaledBy(x: -1, y: 1)
            transform = transform.rotated(by: CGFloat(M_PI) / 2)
        }
        
        UIGraphicsBeginImageContext(bounds.size)
        let context = UIGraphicsGetCurrentContext()
        
        //图片绘制时进行图片修正
        switch orientation {
        case .left:
            fallthrough
        case .leftMirrored:
            fallthrough
        case .right:
            fallthrough
        case .rightMirrored:
            context!.scaleBy(x: -1.0, y: 1.0);
            context!.translateBy(x: -bounds.size.width, y: 0.0);
        default:
            context!.scaleBy(x: 1.0, y: -1.0);
            context!.translateBy(x: 0.0, y: -rect.size.height);
        }
        context!.concatenate(transform)
        context!.draw(imageRef!, in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// 交换宽高
    ///
    /// - Parameter rect: <#rect description#>
    private func swapWidthAndHeight(rect: inout CGRect) {
        let swap = rect.size.width
        rect.size.width = rect.size.height
        rect.size.height = swap
    }
    
    /// 将View转换成图片
    ///
    /// - Parameter view: 要转换成Image的View
    /// - Returns: 返回生成的图片
    class func imageFrom(view: UIView) -> UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(view.size, false, scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return viewImage
    }
    
    
}


// MARK: - 压缩缩放
extension UIImage {
    
    /// 将图像缩放到指定宽高
    ///
    /// - Parameter width: 宽度
    /// - Returns: 缩放后的image.如果图片宽度小于宽度，直接返回
    func scaleToWidth(width: CGFloat) -> UIImage {
        if width > size.width {
            return self
        }
        let height = size.height * width / size.width
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        //使用核心绘图绘制图像
        // 1 > 上下文
        UIGraphicsBeginImageContext(rect.size)
        // 2 > 绘图
        self.draw(in: rect)
        // 3 > 去结果
        let result = UIGraphicsGetImageFromCurrentImageContext()
        // 4 > 关闭上下文
        UIGraphicsEndImageContext()
        // 5 > 返回结果
        return result!
    }

    
    /// 图片等比缩放
    ///
    /// - Parameter imageSize: 要缩放的尺寸
    /// - Returns: 返回缩放后的图片
    func imageByScaling(imageSize: CGSize) -> UIImage? {
        let sourceImageSize = self.size
        var scaleFactor : CGFloat = 0
        var scaleWidth : CGFloat = imageSize.width
        var scaleHeight : CGFloat = imageSize.height
        var thumbnailPoint = CGPoint(x: 0, y: 0)
        var thumbnailRect = CGRect.zero
        
        if !imageSize.equalTo(sourceImageSize) {
            let widthFactor = imageSize.width / sourceImageSize.width
            let heightFactor = imageSize.height / sourceImageSize.height
            scaleFactor = widthFactor < heightFactor ? widthFactor : heightFactor
            
            scaleWidth = sourceImageSize.width * scaleFactor
            scaleHeight = sourceImageSize.height * scaleFactor
            
            if widthFactor < heightFactor {
                thumbnailPoint.y = (imageSize.height - scaleHeight) * 0.5
            } else {
                thumbnailPoint.x = (imageSize.width - scaleWidth) * 0.5
            }
        }
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width = scaleWidth
        thumbnailRect.size.height = scaleHeight
        
        UIGraphicsBeginImageContext(imageSize)
        self.draw(in: thumbnailRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// 获取图片的局部
    ///
    /// - Parameter rect: 局部图片的范围
    /// - Returns: 截取后的图片
    func subImage(rect: CGRect) -> UIImage? {
        let imageRef: CGImage = (self.cgImage?.cropping(to: rect))!
        return UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
    }
    
    /// 压缩图片致指定尺寸
    ///
    /// - Parameter toSize: 压缩到的尺寸
    /// - Returns: 返回压缩后的图片
    func rescaleImage(toSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(toSize)
        self.draw(in: CGRect(origin: CGPoint.zero, size: toSize))
        let resImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return resImage
    }
    
    /// 压缩图片致指定像素
    ///
    /// - Parameter toPx: 像素
    /// - Returns: 返回压缩后的图片
    func rescaleImage(toPx: CGFloat) -> UIImage? {
        if self.width <= toPx && self.height <= toPx {
            return self
        }
        var newSize = self.size
        let scale = self.width / self.height
        if self.width > self.height {
            newSize.width = toPx
            newSize.height = toPx / scale
        } else {
            newSize.width = toPx * scale
            newSize.height = toPx
        }
        return self.rescaleImage(toSize: newSize)
    }
}
