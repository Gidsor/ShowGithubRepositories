//
//  RepositoriesViewController.swift
//  ShowGithubRepositories
//
//  Created by Vadim Denisov on 22/10/2018.
//  Copyright © 2018 Vadim Denisov. All rights reserved.
//

import UIKit
import ObjectMapper
import RxAlamofire
import RxSwift
import RxCocoa

class RepositoriesViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var idSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    let disposeBag = DisposeBag()
    var repositoryNetworkModel: RepositoriesViewModel!
    
    var idSearchBarObservable: Observable<String> {
        return idSearchBar.rx.text
            .filter { $0 != nil }
            .map { $0! }
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupModel()
        
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func setupModel() {
        repositoryNetworkModel = RepositoriesViewModel(nameObservable: idSearchBarObservable)
        
        repositoryNetworkModel.repositoriesDriver
            .drive(tableView.rx.items) { (tv, i, repository) in
                let cell = tv.dequeueReusableCell(withIdentifier: "RepositoryCell", for: IndexPath(row: i, section: 0)) as! RepositoryCell
                
                cell.id.text = String(repository.id)
                cell.name.text = repository.owner.login + "/" + repository.name
                cell.descriptionRepository.text = repository.description
                
                return cell
            }
            .disposed(by: disposeBag)
    }


}

