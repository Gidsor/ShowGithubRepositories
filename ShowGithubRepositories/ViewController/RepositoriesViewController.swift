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
import SafariServices

class RepositoriesViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var idSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refresh Repositories ...")
        refreshControl.addTarget(self, action: #selector(RepositoriesViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    private let idSearchBehaviorRelay = BehaviorRelay<String?>(value: "")
    private let disposeBag = DisposeBag()
    
    private var repositoryNetworkModel: RepositoriesViewModel!
    
    var idSearchObservable: Observable<String?> {
        return idSearchBehaviorRelay.asObservable()
            .map { $0 }
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupModel()
        
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refreshControl
    }
    
    func setupModel() {
        idSearchBar.rx.text.asDriver().drive(idSearchBehaviorRelay).disposed(by: disposeBag)
        
        repositoryNetworkModel = RepositoriesViewModel(nameObservable: idSearchObservable)
        
        repositoryNetworkModel.repositoriesDriver
            .drive(tableView.rx.items) { (tv, i, repository) in
                let cell = tv.dequeueReusableCell(withIdentifier: "RepositoryCell", for: IndexPath(row: i, section: 0)) as! RepositoryCell
                
                cell.id.text = String(repository.id)
                cell.name.text = repository.owner.login + "/" + repository.name
                cell.descriptionRepository.text = repository.description
                cell.url = repository.url
                
                return cell
            }
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RepositoryCell
        guard let url = URL(string: cell.url) else { return }
        
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.numberOfRows(inSection: indexPath.section) - 1 == indexPath.row {
            DispatchQueue.main.async {
                self.idSearchBehaviorRelay.accept((cell as! RepositoryCell).id.text)
                tableView.setContentOffset(.zero, animated: true)
            }
        }
        
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        idSearchBar.text = ""
        idSearchBehaviorRelay.accept("")
        refreshControl.endRefreshing()
    }

}
