//
//  ViewController.swift
//  lecture8
//
//  Created by admin on 08.02.2021.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var feelsLikeTemp: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var citySegment: UISegmentedControl!
    
    var myData: Model?
    var url = "https://api.openweathermap.org/data/2.5/onecall?lat=51.1801&lon=71.446&exclude=minutely,alerts&appid=0e9477e67e53c8c91844f7d87860ae02&units=metric"
    
    private var decoder: JSONDecoder = JSONDecoder()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCell.nib, forCellReuseIdentifier: TableViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.nib, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        fetchData()
    }
    
    
    @IBAction func changeCity(_ sender: Any) {
        switch citySegment.selectedSegmentIndex{
        case 0:
            url = "https://api.openweathermap.org/data/2.5/onecall?lat=51.1801&lon=71.446&exclude=minutely,alerts&appid=0e9477e67e53c8c91844f7d87860ae02&units=metric"
        case 1:
            url = "https://api.openweathermap.org/data/2.5/onecall?lat=40.730610&lon=-73.935242&exclude=minutely,alerts&appid=0e9477e67e53c8c91844f7d87860ae02&units=metric"
        case 2:
            url = "https://api.openweathermap.org/data/2.5/onecall?lat=48.137154&lon=11.576124&exclude=minutely,alerts&appid=0e9477e67e53c8c91844f7d87860ae02&units=metric"
            
        default:
            break
        }
        fetchData()
    }
    func updateUI(){
        temp.text = "\(myData?.current?.temp ?? 0.0)"
        feelsLikeTemp.text = "\(myData?.current?.feels_like ?? 0.0)"
        desc.text = myData?.current?.weather?.first?.description
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func fetchData(){
        AF.request(url).responseJSON { (response) in
            switch response.result{
            case .success(_):
                guard let data = response.data else { return }
                guard let answer = try? self.decoder.decode(Model.self, from: data) else{ return }
                self.myData = answer
                self.updateUI()
            case .failure(let err):
                print(err.errorDescription ?? "")
            }
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myData?.daily?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier, for: indexPath) as! TableViewCell
        let item = myData?.daily?[indexPath.item]
        cell.tempLabel.text = "\(item?.temp?.day ?? 0.0)"
        cell.feelsLikeLabel.text = "\(item?.feels_like?.day ?? 0.0)"
        cell.descriptionLabel.text = item?.weather?.first?.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    
}


extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myData?.hourly?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
        let item = myData?.hourly?[indexPath.item]
        cell.temp.text = "\(item?.temp ?? 0.0)"
        cell.feelsLike.text = "\(item?.feels_like ?? 0.0)"
        cell.desc.text = item?.weather?.first?.description
        return cell

    }
    
    
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}


