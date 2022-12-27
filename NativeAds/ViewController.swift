//
//  ViewController.swift
//  NativeAds
//
//  Created by Muhammad Awais on 27/12/2022.
//

import UIKit
import GoogleMobileAds

class ViewController: UIViewController {
    
    @IBOutlet weak var placementView: UIView!
    
    var adLoader: GADAdLoader!
    
    var nativeAdView: GADNativeAdView!
    
    /// The ad unit ID.
    let adUnitID = "ca-app-pub-3940256099942544/3986624511"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard
            let nibObjects = Bundle.main.loadNibNamed("GADNativeAdView", owner: nil, options: nil),
            let adView = nibObjects.first as? GADNativeAdView
        else {
            assert(false, "Could not load nib file for adView")
        }
        setAdView(adView)
        addRequest()
        
    }
    
    func addRequest(){
        adLoader = GADAdLoader(
            adUnitID: adUnitID, rootViewController: self,
            adTypes: [.native], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    
    //MARK: - Other Functions
    
    func setAdView(_ view: GADNativeAdView) {
        
        // Remove the previous ad view.
        nativeAdView = view
        placementView.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints for positioning the native ad view to stretch the entire width and height
        // of the nativeAdPlaceholder.
        let viewDictionary = ["_nativeAdView": nativeAdView!]
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
        self.view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
    }
    
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }
        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        } else {
            return nil
        }
    }
    
}



extension ViewController: GADVideoControllerDelegate {
    
    func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
        print("Video playback has ended.")
    }
}

extension ViewController: GADAdLoaderDelegate,GADNativeAdDelegate,GADNativeAdLoaderDelegate {
    
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        
    }
    
    // Mark: - GADNativeAdLoaderDelegate
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        DispatchQueue.main.async { [self] in
            print("Received native ad: \(nativeAd)")
            // Create and place ad in view hierarchy.
            let nibView = Bundle.main.loadNibNamed("GADNativeAdView", owner: nil, options: nil)?.first
            guard let nativeAdView = nibView as? GADNativeAdView else {
                return
            }
            setAdView(nativeAdView)
            
            // Set ourselves as the native ad delegate to be notified of native ad events.
            nativeAd.delegate = self
            
            // Populate the native ad view with the native ad assets.
            // The headline and mediaContent are guaranteed to be present in every native ad.
            (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
            nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
            
            // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
            // ratio of the media it displays.
            if let mediaView = nativeAdView.mediaView, nativeAd.mediaContent.aspectRatio > 0 {
                let heightConstraint = NSLayoutConstraint(
                    item: mediaView,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: mediaView,
                    attribute: .width,
                    multiplier: CGFloat(1 / nativeAd.mediaContent.aspectRatio),
                    constant: 0)
                heightConstraint.isActive = true
            }
            
            // These assets are not guaranteed to be present. Check that they are before
            // showing or hiding them.
            (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
            nativeAdView.bodyView?.isHidden = nativeAd.body == nil
            
            (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
            nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
            
            (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
            nativeAdView.iconView?.isHidden = nativeAd.icon == nil
            
            (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(
                from: nativeAd.starRating)
            nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil
            
            (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
            nativeAdView.storeView?.isHidden = nativeAd.store == nil
            
            (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
            nativeAdView.priceView?.isHidden = nativeAd.price == nil
            
            (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
            nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
            
            // In order for the SDK to process touch events properly, user interaction should be disabled.
            nativeAdView.callToActionView?.isUserInteractionEnabled = false
            
            // Associate the native ad view with the native ad object. This is
            // required to make the ad clickable.
            // Note: this should always be done after populating the ad views.
            nativeAdView.nativeAd = nativeAd
        }
        
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        // The native ad was shown.
    }
    
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        // The native ad was clicked on.
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
        // The native ad will present a full screen view.
    }
    
    func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
        // The native ad will dismiss a full screen view.
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        // The native ad did dismiss a full screen view.
    }
    
    func nativeAdWillLeaveApplication(_ nativeAd: GADNativeAd) {
        // The native ad will cause the application to become inactive and
        // open a new application.
    }
}
