//
//  ViewController.swift
//  Drink1216
//
//  Created by change on 2021/12/16.
//

import UIKit

public let apiKey = "keyeTqOp10kNwpVIp"
private let reuseIdentifier = "MenuCollectionViewCell"

class MainVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet weak var largeTitle: UILabel!
    @IBOutlet weak var menuCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    
    var menuData: Array<Record> = []
    let urlStr = "https://api.airtable.com/v0/appn2v5vLq94npVwP/Menu?sort[][field]=sort"
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //自動刷新
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { [weak self] timer in self?.fetchData(urlStr: "https://api.airtable.com/v0/appn2v5vLq94npVwP/Menu?sort[][field]=sort") { (menuData) in
            guard let menuData = menuData else { return }
            Record.saveToFile(records: menuData)
        }})
        
        setCell()
        
        fetchData(urlStr: urlStr) { (menuData) in
            guard let menuData = menuData else { return }
            Record.saveToFile(records: menuData)
        }
        
   
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        // 將timer的執行緒停止
        if self.timer != nil {
            self.timer?.invalidate()
        }
    }
    
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        menuData.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainCCell
        cell.label.text = menuData[indexPath.item].fields.drinkName
        cell.imageView.image = nil
        if let imageUrl = URL(string: menuData[indexPath.item].fields.drinkImage[0].url) {
            URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.imageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        return cell
    }
    
    
    
    //設定大小
    func setCell() {
        menuCollectionViewFlowLayout.itemSize = CGSize(width: 280, height: 280)
        menuCollectionViewFlowLayout.estimatedItemSize = .zero
        menuCollectionViewFlowLayout.minimumInteritemSpacing = 10
        menuCollectionViewFlowLayout.minimumLineSpacing = 10
    }
    
    
    
    // 切換至訂餐頁面
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? DrinkOrderVC
        if let item = menuCollectionView.indexPathsForSelectedItems?.first?.item {
            controller?.drinkName = menuData[item].fields.drinkName
        }
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}
