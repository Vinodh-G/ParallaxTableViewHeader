//
//  ParallaxHeaderView.swift
//  ParallaxTableViewHeaderSwift
//
//  Created by Christopher Reitz on 24.04.16.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import UIKit

class ParallaxHeaderView: UIView {

    // MARK: - Properties

    var headerImage = UIImage() {
        didSet {
            imageView.image = headerImage
            refreshBlurViewForNewImage()
        }
    }

    var headerTitleLabel = UILabel()
    var imageScrollView = UIScrollView()
    var imageView = UIImageView()
    var bluredImageView = UIImageView()
    var subView: UIView?

    var kDefaultHeaderFrame = CGRect()
    let kParallaxDeltaFactor: CGFloat = 0.5
    let kMaxTitleAlphaOffset: CGFloat = 100.0
    let kLabelPaddingDist: CGFloat = 8.0

    // MARK: - Initializer

    init(image: UIImage, forSize headerSize: CGSize) {
        super.init(frame: CGRect(x: 0, y: 0, width: headerSize.width, height: headerSize.height))

        kDefaultHeaderFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)

        headerImage = image
        initialSetupForDefaultHeader()
    }

    init(subView: UIView) {
        super.init(frame: CGRect(x: 0, y: 0, width: subView.frame.size.width, height: subView.frame.size.height))

        kDefaultHeaderFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)

        initialSetupForCustomSubView(subView: subView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        if let subView = self.subView {
            initialSetupForCustomSubView(subView: subView)
        }
        else {
            initialSetupForDefaultHeader()
        }
    }

    // MARK: - Public

    func layoutHeaderViewForScrollViewOffset(offset: CGPoint) {
        if offset.y > 0 {
            var frame = imageScrollView.frame
            frame.origin.y = max(offset.y * kParallaxDeltaFactor, 0)
            imageScrollView.frame = frame
            bluredImageView.alpha = 1 / kDefaultHeaderFrame.size.height * offset.y * 2
            clipsToBounds = true
        }
        else {
            let delta: CGFloat = abs(min(0.0, offset.y))
            var rect = kDefaultHeaderFrame
            rect.origin.y -= delta
            rect.size.height += delta
            imageScrollView.frame = rect
            clipsToBounds = false
            headerTitleLabel.alpha = 1 - delta * 1 / kMaxTitleAlphaOffset
        }
    }

    func refreshBlurViewForNewImage() {
        var screenShot = screenShotOfView(view: self)
        screenShot = screenShot.applyBlurWithRadius(blurRadius: 5, tintColor: UIColor.white.withAlphaComponent(0.2), saturationDeltaFactor: 1.0, maskImage: nil)!
        bluredImageView.image = screenShot
    }

    // MARK: - Private

    private func initialSetupForDefaultHeader() {
        imageScrollView = UIScrollView(frame: bounds)
        imageView = UIImageView(frame: imageScrollView.bounds)
        imageView.autoresizingMask = [
            .flexibleLeftMargin,
            .flexibleRightMargin,
            .flexibleTopMargin,
            .flexibleBottomMargin,
            .flexibleHeight,
            .flexibleWidth
        ]
        imageView.contentMode = .scaleAspectFill
        imageView.image = headerImage
        imageScrollView.addSubview(imageView)

        var labelRect = imageScrollView.bounds
        labelRect.origin.x = kLabelPaddingDist
        labelRect.origin.y = kLabelPaddingDist
        labelRect.size.width = labelRect.size.width - 2 * kLabelPaddingDist
        labelRect.size.height = labelRect.size.height - 2 * kLabelPaddingDist

        headerTitleLabel = UILabel(frame: labelRect)
        headerTitleLabel.textAlignment = .center
        headerTitleLabel.numberOfLines = 0
        headerTitleLabel.lineBreakMode = .byWordWrapping
        headerTitleLabel.autoresizingMask = imageView.autoresizingMask
        headerTitleLabel.textColor = UIColor.white
        headerTitleLabel.font = UIFont(name: "AvenirNextCondensed-Regular", size: 23)
        imageScrollView.addSubview(headerTitleLabel)

        bluredImageView = UIImageView(frame: imageView.frame)
        bluredImageView.autoresizingMask = imageView.autoresizingMask
        bluredImageView.alpha = 0.0
        imageScrollView.addSubview(bluredImageView)

        addSubview(imageScrollView)
        refreshBlurViewForNewImage()
    }

    private func initialSetupForCustomSubView(subView: UIView) {
        let scrollView = UIScrollView(frame: bounds)
        imageScrollView = scrollView
        self.subView = subView
        subView.autoresizingMask = [
            .flexibleLeftMargin,
            .flexibleRightMargin,
            .flexibleTopMargin,
            .flexibleBottomMargin,
            .flexibleHeight,
            .flexibleWidth
        ]
        imageScrollView.addSubview(subView)

        bluredImageView = UIImageView(frame: subView.frame)
        bluredImageView.autoresizingMask = subView.autoresizingMask
        bluredImageView.alpha = 0.0
        imageScrollView.addSubview(bluredImageView)

        addSubview(imageScrollView)
        refreshBlurViewForNewImage()
    }

    private func screenShotOfView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(kDefaultHeaderFrame.size, true, 0.0)
        drawHierarchy(in: kDefaultHeaderFrame, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}
