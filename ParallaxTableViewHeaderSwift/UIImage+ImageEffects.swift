/*
 File: UIImage+ImageEffects.m
 Abstract: This is a category of UIImage that adds methods to apply blur and tint effects to an image. This is the code you’ll want to look out to find out how to use vImage to efficiently calculate a blur.
 Version: 1.0

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2013 Apple Inc. All Rights Reserved.


 Copyright © 2013 Apple Inc. All rights reserved.
 WWDC 2013 License

 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2013
 Session. Please refer to the applicable WWDC 2013 Session for further
 information.

 IMPORTANT: This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and
 your use, installation, modification or redistribution of this Apple
 software constitutes acceptance of these terms. If you do not agree with
 these terms, please do not use, install, modify or redistribute this
 Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple. Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES
 NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
 IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 EA1002
 5/3/2013
 */

//
//  UIImage.swift
//  Today
//
//  Created by Alexey Globchastyy on 15/09/14.
//  Copyright (c) 2014 Alexey Globchastyy. All rights reserved.
//

import UIKit
import Accelerate

public extension UIImage {
    func applyLightEffect() -> UIImage? {
        return applyBlurWithRadius(blurRadius: 30, tintColor: UIColor(white: 1.0, alpha: 0.3), saturationDeltaFactor: 1.8)
    }

    func applyExtraLightEffect() -> UIImage? {
        return applyBlurWithRadius(blurRadius: 20, tintColor: UIColor(white: 0.97, alpha: 0.82), saturationDeltaFactor: 1.8)
    }

    func applyDarkEffect() -> UIImage? {
        return applyBlurWithRadius(blurRadius: 20, tintColor: UIColor(white: 0.11, alpha: 0.73), saturationDeltaFactor: 1.8)
    }

    func applyTintEffectWithColor(tintColor: UIColor) -> UIImage? {
        let effectColorAlpha: CGFloat = 0.6
        var effectColor = tintColor

        let componentCount = tintColor.cgColor.numberOfComponents

        if componentCount == 2 {
            var b: CGFloat = 0
            if tintColor.getWhite(&b, alpha: nil) {
                effectColor = UIColor(white: b, alpha: effectColorAlpha)
            }
        } else {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0

            if tintColor.getRed(&red, green: &green, blue: &blue, alpha: nil) {
                effectColor = UIColor(red: red, green: green, blue: blue, alpha: effectColorAlpha)
            }
        }

        return applyBlurWithRadius(blurRadius: 10, tintColor: effectColor, saturationDeltaFactor: -1.0, maskImage: nil)
    }

    func applyBlurWithRadius(blurRadius: CGFloat, tintColor: UIColor?, saturationDeltaFactor: CGFloat, maskImage: UIImage? = nil) -> UIImage? {
        // Check pre-conditions.
        if (size.width < 1 || size.height < 1) {
            print("*** error: invalid size: \(size.width) x \(size.height). Both dimensions must be >= 1: \(self)")
            return nil
        }
        if self.cgImage == nil {
            print("*** error: image must be backed by a CGImage: \(self)")
            return nil
        }
        if maskImage != nil && maskImage!.cgImage == nil {
            print("*** error: maskImage must be backed by a CGImage: \(maskImage ?? UIImage())")
            return nil
        }

        let __FLT_EPSILON__ = CGFloat(Float.ulpOfOne)
        let screenScale = UIScreen.main.scale
        let imageRect = CGRect(origin: .zero, size: size)
        var effectImage = self

        let hasBlur = blurRadius > __FLT_EPSILON__
        let hasSaturationChange = abs(saturationDeltaFactor - 1.0) > __FLT_EPSILON__

        if hasBlur || hasSaturationChange {
            func createEffectBuffer(context: CGContext?) -> vImage_Buffer {
                let data = context!.data
                let width = vImagePixelCount(context!.width)
                let height = vImagePixelCount(context!.height)
                let rowBytes = context!.bytesPerRow

                return vImage_Buffer(data: data, height: height, width: width, rowBytes: rowBytes)
            }

            UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
            let effectInContext = UIGraphicsGetCurrentContext()

            effectInContext!.scaleBy(x: 1.0, y: -1.0)
            effectInContext!.translateBy( x: 0, y: -size.height)
            
            //effectInContext!.draw(imageRect, self.cgImage)
            effectInContext!.draw(self.cgImage!, in: imageRect, byTiling: false)
            
            var effectInBuffer = createEffectBuffer(context: effectInContext)


            UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
            let effectOutContext = UIGraphicsGetCurrentContext()

            var effectOutBuffer = createEffectBuffer(context: effectOutContext)


            if hasBlur {
                // A description of how to compute the box kernel width from the Gaussian
                // radius (aka standard deviation) appears in the SVG spec:
                // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
                //
                // For larger values of 's' (s >= 2.0), an approximation can be used: Three
                // successive box-blurs build a piece-wise quadratic convolution kernel, which
                // approximates the Gaussian kernel to within roughly 3%.
                //
                // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
                //
                // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
                //

                let inputRadius = blurRadius * screenScale
                let temp1 = CGFloat(sqrt(2 * Double.pi))
                var radius = UInt32(floor(inputRadius * 3.0 * temp1 / 4 + 0.5))
                
                if radius % 2 != 1 {
                    radius += 1 // force radius to be odd so that the three box-blur methodology works.
                }

                let imageEdgeExtendFlags = vImage_Flags(kvImageEdgeExtend)

                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
                vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
            }

            var effectImageBuffersAreSwapped = false

            if hasSaturationChange {
                let s: CGFloat = saturationDeltaFactor
                let floatingPointSaturationMatrix: [CGFloat] = [
                    0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                    0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                    0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                    0,                    0,                    0,  1
                ]

                let divisor: CGFloat = 256
                let matrixSize = floatingPointSaturationMatrix.count
                
                //var saturationMatrix = [Int16](_unsafeUninitializedCapacity: matrixSize, initializingWith: 0)
                //var saturationMatrix = [Int16](count: matrixSize, initializingWith: 0)
                var saturationMatrix = [Int16](repeating: 0, count: matrixSize)
                
                for i: Int in 0 ..< matrixSize {
                    saturationMatrix[i] = Int16(round(floatingPointSaturationMatrix[i] * divisor))
                }

                if hasBlur {
                    vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, Int32(divisor), nil, nil, vImage_Flags(kvImageNoFlags))
                    effectImageBuffersAreSwapped = true
                } else {
                    vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, Int32(divisor), nil, nil, vImage_Flags(kvImageNoFlags))
                }
            }

            if !effectImageBuffersAreSwapped {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()!
            }

            UIGraphicsEndImageContext()

            if effectImageBuffersAreSwapped {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()!
            }

            UIGraphicsEndImageContext()
        }

        // Set up output context.
        UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
        let outputContext = UIGraphicsGetCurrentContext()
        outputContext!.scaleBy(x: 1.0, y: -1.0)
        outputContext!.translateBy(x: 0, y: -size.height)

        // Draw base image.
        //outputContext.draw(imageRect, self.cgImage)
        outputContext!.draw(self.cgImage!, in: imageRect, byTiling: false)
        
        // Draw effect image.
        if hasBlur {
            outputContext!.saveGState()
            if let image = maskImage {
                outputContext!.clip(to: imageRect, mask: image.cgImage!);
            }
            
            //outputContext!.draw( imageRect, effectImage.cgImage)
            outputContext!.draw(self.cgImage!, in: imageRect, byTiling: false)
            
            outputContext!.restoreGState()
        }

        // Add in color tint.
        if let color = tintColor {
            outputContext!.saveGState()
            outputContext!.setFillColor(color.cgColor)
            outputContext!.fill(imageRect)
            outputContext!.restoreGState()
        }
        
        // Output image is ready.
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return outputImage
    }
}
