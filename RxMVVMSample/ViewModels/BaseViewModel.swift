//
//  BaseViewModel.swift
//  RxMVVMSample
//
//  Created by Hiromi Fujita on 2020/12/24.
//

import RxSwift

class BaseViewModel {
    var title: Observable<String> {
        return titleSubject
    }
    //private let titleSubject = PublishSubject<String>()
    private let titleSubject = BehaviorSubject<String>(value: "")
    
    func set(text: String) {
        titleSubject.onNext(text)
    }
}
