////
////  UICollectionView.swift
////  Feature
////
////  Created by 제이콥 on 1/17/24.
////  Copyright © 2024 hollys. All rights reserved.
////
//
//import SwiftUI
//import MusicKit
//
//
//public struct RecentPopularSongView: UIViewControllerRepresentable {
//    @Binding var musicChart: MusicItemCollection<Song>
//    
//    public init(musicChart: Binding<MusicItemCollection<Song>>) {
//        self._musicChart = musicChart
//    }
//    
//    public func makeUIViewController(context: Context) -> UIViewController {
//        let collectionView = CollectionView(musicChart: musicChart)
//        return collectionView
//    }
//    
//    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        if let collectionView = uiViewController as? CollectionView {
//            print("update")
//            print("music length in update: \(musicChart.count)")
//            collectionView.musicChart = musicChart
//            collectionView.collectionView.reloadData()
//        }
//    }
//    
//
//    
//    public typealias UIViewControllerType = UIViewController
//    
//    
//}
//
//public class CollectionView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
//
//    
//    init(musicChart: MusicItemCollection<Song>) {
//        print("in init")
//        self.musicChart = musicChart
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    var musicChart: MusicItemCollection<Song> {
//        didSet{
//            collectionView.reloadData()
//            print("collectionview size3 - width: \(collectionView.frame.width), height: \(collectionView.frame.height)")
//        }
//    }
//
//    var collectionView: UICollectionView = {
//        print("in collectionview init")
//        let flowlayout = UICollectionViewFlowLayout()
//        flowlayout.scrollDirection = .horizontal
//        flowlayout.minimumInteritemSpacing = 20
//        flowlayout.itemSize = CGSize(width: 20, height: 50)
//        
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowlayout)
//        collectionView.isScrollEnabled = true
////        collectionView.isPagingEnabled = true
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.showsVerticalScrollIndicator = false
//        collectionView.backgroundColor = .blue
//        collectionView.register(PopularSongItem.self, forCellWithReuseIdentifier: "PopularSongCell")
//        return collectionView
//    }()
//    
//    public override func viewDidLoad() {
//        super.viewDidLoad()
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        
////        collectionView.frame = view.frame
////        collectionView.contentSize = CGSize(width: 1000, height: collectionView.frame.height)
//        
//        collectionView.frame = view.bounds
////        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        
//        view.addSubview(collectionView)
//        
//    }
//    public func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return musicChart.count / 4
//    }
//    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("music legnth: \(musicChart.count)")
//        return 4
//    }
//    
//    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularSongCell", for: indexPath) as! PopularSongItem
//        let music = musicChart[indexPath.row]
//        cell.label.text = music.title
//        return cell
//    }
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 20, height: 50)
//    }
//}
//
//final class PopularSongItem: UICollectionViewCell{
//    static let id = "PopularSongCell"
//    
//    let label: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 15)
//        label.textColor = .white
//        label.text = "야호 야호"
//        return label
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .purple
//        setUI()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func setUI(){
////        addSubview(label)
//        
////        NSLayoutConstraint.activate([
////            label.topAnchor.constraint(equalTo: topAnchor),
////            label.leadingAnchor.constraint(equalTo: leadingAnchor),
////            label.trailingAnchor.constraint(equalTo: trailingAnchor),
////            label.bottomAnchor.constraint(equalTo: bottomAnchor)
////        ])
//    }
//    
//}
//extension UIImageView {
//    func load(url: URL) {
//        DispatchQueue.global().async { [weak self] in
//            if let data = try? Data(contentsOf: url) {
//                if let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        self?.image = image
//                    }
//                }
//            }
//        }
//    }
//}
