//
//  ViewController.swift
//  myPhotoLibrary2
//
//  Created by Leonnardo Benjamin Hutama on 19/06/20.
//  Copyright © 2020 Leonnardo Benjamin Hutama. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var dateSegmentedControl: UISegmentedControl!
   
    var fetchResult: PHFetchResult<PHAsset>!
    let imageManager = PHCachingImageManager()
    
    var libraries = [Library]()
    
    var photoPerRow = 3
    
    let waitAlert = UIAlertController(title: "Please Wait", message: "\n", preferredStyle: .alert)
    
    var allDaysSelected = true
    
    var selectedIndex = IndexPath()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        PHPhotoLibrary.shared().register(self)
        
        setUp()
        
        fetchAssets()
        checkAuthorizationStatus()
        
    }
        
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func setUp() {
        setUpAlertView()
        setupCollectionViewLayout()
        setUpSegmentedControl()
    }
    
    func setUpSegmentedControl() {
        dateSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        dateSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.label], for: .selected)
        dateSegmentedControl.selectedSegmentIndex = 3
    }
    
    func setupCollectionViewLayout() {
        
        let itemSize = UIScreen.main.bounds.width/CGFloat(photoPerRow) - 2
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom:  20, right: 0)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 30)
        
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        layout.sectionHeadersPinToVisibleBounds = true
        
        collectionView.collectionViewLayout = layout
    }
    
    func setUpAlertView() {
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: waitAlert.view.frame.width/2-100, y: 30,width: 50, height: 50)) as UIActivityIndicatorView
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        
        waitAlert.view.addSubview(loadingIndicator)
    }

    func checkAuthorizationStatus() {
        
        let authPhotos = PHPhotoLibrary.authorizationStatus()
        
        if authPhotos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                self.checkAuthorizationStatus()
            })
        }
        else {
            
            if authPhotos == .authorized {
                DispatchQueue.main.async {
                    
                    self.present(self.waitAlert, animated: true) {
                        
                        self.fetchAssets()
                        self.collectionView.reloadData()
                    }
                }
            }
                
            else if authPhotos == .denied {
                
                let alert = UIAlertController(title: "Photos Access Denied", message: "App needs access to photos library.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            
            }
        }
    }
    
    func fetchAssets() {
        
        let fetchOptions=PHFetchOptions()
        fetchOptions.sortDescriptors=[NSSortDescriptor(key:"creationDate", ascending: false)]
        
        fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
//        waitAlert.dismiss(animated: true, completion: nil)
        sortAsset()
    }
    
    func sortAsset() {
        libraries.removeAll()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        var formattedDate = ""
        
        var arrayOfAsset = [PHAsset]()
        
        var dateTemp = ""
        
        if dateSegmentedControl.selectedSegmentIndex == 0 {
            allDaysSelected = false
            formatter.dateFormat = "yyyy"
            photoPerRow = 7
        }
        else if dateSegmentedControl.selectedSegmentIndex == 1 {
            allDaysSelected = false
            formatter.dateFormat = "MMMM yyyy"
            photoPerRow = 4
        }
        else if dateSegmentedControl.selectedSegmentIndex == 2 {
            allDaysSelected = false
            formatter.dateFormat = "dd MMMM, yyyy"
            photoPerRow = 3
        }
        else {
            allDaysSelected = true
            photoPerRow = 3
        }
        
        for index in 0..<fetchResult.count {
            
            if self.allDaysSelected {
                arrayOfAsset.append(fetchResult.object(at: index))
            }
            else {
                if let creationDate = fetchResult[index].creationDate {
                    formattedDate = formatter.string(from: creationDate)
                }
                
                if dateTemp == "" {
                    dateTemp = formattedDate
                    arrayOfAsset.append(fetchResult.object(at: index))
                }
                else {

                    if dateTemp != formattedDate {

                        var newLibrary = Library()
                        newLibrary.creationDate = dateTemp
                        newLibrary.assets = arrayOfAsset
                        self.libraries.append(newLibrary)

                        arrayOfAsset.removeAll()

                        dateTemp = formattedDate

                        arrayOfAsset.append(fetchResult.object(at: index))

                    }
                    else {

                        arrayOfAsset.append(fetchResult.object(at: index))
                    }
                }
                
            }
        }
        
        var newLibrary = Library()
        newLibrary.creationDate = ""
        newLibrary.assets = arrayOfAsset
        self.libraries.append(newLibrary)
        
        arrayOfAsset.removeAll()
        
        DispatchQueue.main.async {
            self.setupCollectionViewLayout()
            self.collectionView.reloadData()
            self.waitAlert.dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToDetail" {
            let nextVC = segue.destination as! DetailPhotoViewController
            nextVC.libraries.append(contentsOf: self.libraries)
            nextVC.selectedContentIndex = selectedIndex
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: Any) {
        
        if dateSegmentedControl.selectedSegmentIndex == 0 {
            allDaysSelected = false
            photoPerRow = 7
        }
        else if dateSegmentedControl.selectedSegmentIndex == 1 {
            allDaysSelected = false
            photoPerRow = 4
        }
        else if dateSegmentedControl.selectedSegmentIndex == 2 {
            allDaysSelected = false
            photoPerRow = 3
        }
        else {
            allDaysSelected = true
            photoPerRow = 3
        }
        
        self.present(waitAlert, animated: true) {
            self.sortAsset()
        }
    
    }
    
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return libraries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if libraries.count != 0 {
            return libraries[section].assets!.count
        }
        
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionViewCell
        
//        let asset = fetchResult.object(at: indexPath.item)
        let asset = libraries[indexPath.section].assets![indexPath.item]
        cell.id = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 500, height: 500), contentMode: .aspectFit, options: nil) { (image, _) in
            if cell.id == asset.localIdentifier {
                cell.imgView.image = image
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? HeaderCollectionReusableView {
            
            if libraries.count != 0 {
                sectionHeader.titleLabel.text = libraries[indexPath.section].creationDate ?? ""
            }
            else {
                sectionHeader.titleLabel.text = ""
            }
            
            return sectionHeader
        }
        
        return UICollectionReusableView()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndex = indexPath
        
        performSegue(withIdentifier: "segueToDetail", sender: self)
    }
        
}

extension ViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        self.fetchResult = changes.fetchResultAfterChanges
        
        DispatchQueue.main.async {
            if changes.hasIncrementalChanges {
                self.collectionView?.performBatchUpdates({
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        self.collectionView?.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        self.collectionView?.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    
                    changes.enumerateMoves { fromIndex, toIndex in
                        self.collectionView?.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                             to: IndexPath(item: toIndex, section: 0))
                    }
                })
                
                if let changed = changes.changedIndexes, !changed.isEmpty {
                    self.collectionView?.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                }
                
            } else {
                self.collectionView?.reloadData()
            }
        }
    }
}

