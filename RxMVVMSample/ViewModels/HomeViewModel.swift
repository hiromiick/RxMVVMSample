//
//  HomeViewModel.swift
//  RxMVVMSample
//
//  Created by Hiromi Fujita on 2020/12/24.
//

import UIKit
import RxCocoa
import RxSwift
import Action
import APIKit

protocol HomeViewModelInputs {
    var fetchTrigger: PublishSubject<Void> { get }
    var reachedBottomTrigger: PublishSubject<Void> { get }
}

protocol HomeViewModelOutputs {
    var navigationBarTitle: Observable<String> { get }
    var repositories: Observable<[Repository]> { get }
    var isLoading: Observable<Bool> { get }
    var error: Observable<NSError> { get }
}

protocol HomeViewModelType {
    var inputs: HomeViewModelInputs { get }
    var outputs: HomeViewModelOutputs { get }
}

final class HomeViewModel: HomeViewModelType, HomeViewModelInputs, HomeViewModelOutputs {

    var inputs: HomeViewModelInputs { return self }
    var outputs: HomeViewModelOutputs { return self }

    // MARK: - Inputs
    let fetchTrigger = PublishSubject<Void>()
    let reachedBottomTrigger = PublishSubject<Void>()
    private let page = BehaviorRelay<Int>(value: 1)

    // MARK: - Outputs
    let navigationBarTitle: Observable<String>
    let repositories: Observable<[Repository]>
    let isLoading: Observable<Bool>
    let error: Observable<NSError>

    private let searchAction: Action<Int, [Repository]>
    private let disposeBag = DisposeBag()

    init(language: String) {
        self.navigationBarTitle = Observable.just("\(language) Repositories")
        self.searchAction = Action { page in
            return Session.shared.rx.response(Api.RepositoryRequest(language: language, page: page))
        }
        let response = BehaviorRelay<[Repository]>(value: [])
        self.repositories = response.asObservable()

        self.isLoading = searchAction.executing.startWith(false)
        self.error = searchAction.errors.map { _ in NSError(domain: "Network Error", code: 0, userInfo: nil) }

        searchAction.elements
            .withLatestFrom(response) { ($0, $1) }
            .map { $0.1 + $0.0 }
            .bind(to: response)
            .disposed(by: disposeBag)

        searchAction.elements
            .withLatestFrom(page)
            .map { $0 + 1 }
            .bind(to: page)
            .disposed(by: disposeBag)

        fetchTrigger
            .withLatestFrom(page)
            .bind(to: searchAction.inputs)
            .disposed(by: disposeBag)

        reachedBottomTrigger
            .withLatestFrom(isLoading)
            .filter { !$0 }
            .withLatestFrom(page)
            .filter { $0 < 5 }
            .bind(to: searchAction.inputs)
            .disposed(by: disposeBag)
    }

}

