//
//  DetailViewModel.swift
//  RxMVVMSample
//
//  Created by Hiromi Fujita on 2020/12/24.
//

import Foundation

import RxCocoa
import RxSwift
import Action
import APIKit

protocol DetailViewModelInputs {}

protocol DetailViewModelOutputs {
    var repository: Repository { get }
    var request: URLRequest { get }
    var navigationBarTitle: Observable<String> { get }
}

protocol DetailViewModelType {
    var inputs: DetailViewModelInputs { get }
    var outputs: DetailViewModelOutputs { get }
}

final class DetailViewModel: DetailViewModelType, DetailViewModelInputs, DetailViewModelOutputs {

    var inputs: DetailViewModelInputs { return self }
    var outputs: DetailViewModelOutputs { return self }

    // MARK: - Inputs

    // MARK: - Outputs
    let repository: Repository
    let request: URLRequest
    let navigationBarTitle: Observable<String>

    private let disposeBag = DisposeBag()

    init(repository: Repository) {
        self.repository = repository
        self.request = URLRequest(url: repository.url)
        self.navigationBarTitle = Observable.just(repository.fullName)
    }

}


