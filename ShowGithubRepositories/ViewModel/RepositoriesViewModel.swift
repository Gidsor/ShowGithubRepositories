//
//  RepositoryNetworkModel.swift
//  ShowGithubRepositories
//
//  Created by Vadim Denisov on 22/10/2018.
//  Copyright © 2018 Vadim Denisov. All rights reserved.
//

import ObjectMapper
import RxAlamofire
import RxSwift
import RxCocoa

class RepositoriesViewModel {
    private var repositoryName: Observable<String>
    
    lazy var repositoriesDriver: Driver<[Repository]> = self.fetchRepositories()
    
    init(nameObservable: Observable<String>) {
        self.repositoryName = nameObservable
    }
    
    private func fetchRepositories() -> Driver<[Repository]> {
        return repositoryName
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { text -> Observable<(HTTPURLResponse, Any)> in
                
                let link = text != "" ? GitHubAPI.allPublicRepositories + "?since=\(Int(text)! - 1)" : GitHubAPI.allPublicRepositories
                
                return RxAlamofire
                    .requestJSON(.get, link)
                    .catchError { error in
                        return Observable.never()
                }
            }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { (response, json) -> [Repository] in
                if let repos = Mapper<Repository>().mapArray(JSONObject: json) {
                    return repos
                } else {
                    return []
                }
            }
            .observeOn(MainScheduler.instance)
            .do(onNext: { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            .asDriver(onErrorJustReturn: [] as [Repository])
    }
}
