//
//  DetailPhotoViewController.swift
//  myPhotoLibrary2
//
//  Created by Leonnardo Benjamin Hutama on 19/06/20.
//  Copyright © 2020 Leonnardo Benjamin Hutama. All rights reserved.
//

import UIKit
import Photos

class DetailPhotoViewController: UIViewController {
    
    @IBOutlet var detailPhotoCollectionView: UICollectionView!
   
    var libraries = [Library]()
    var selectedContentIndex = IndexPath()
    
    let imageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailPhotoCollectionView.delegate = self
        detailPhotoCollectionView.dataSource = self
        
        setupCollectionViewLayout()
        
        setUpCollectionView()
    }
    
    func setUpCollectionView() {
        
        detailPhotoCollectionView.scrollToItem(at: selectedContentIndex, at: .left, animated: true)
    }
    
    func setupCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = detailPhotoCollectionView.frame.size
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing=0
        layout.minimumLineSpacing=0
        layout.scrollDirection = .horizontal
        
        detailPhotoCollectionView.collectionViewLayout = layout
    }
    
}

extension DetailPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if libraries.count != 0 {
            return libraries.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if libraries.count != 0 {
            return libraries[section].assets!.count
        }
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell
        
        let asset = libraries[indexPath.section].assets![indexPath.item]
        cell.id = asset.localIdentifier
        
        let option = PHImageRequestOptions()
        
        option.isSynchronous = true
        option.deliveryMode = .highQualityFormat
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFit, options: option) { (image, _) in
            if cell.id == asset.localIdentifier {
                cell.imgView.image = image
            }
        }
        
        return cell
    }

}
