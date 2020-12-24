//
//  BaseViewController.swift
//  RxMVVMSample
//
//  Created by Hiromi Fujita on 2020/12/24.
//

import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    private let viewModel = BaseViewModel()
    private let disposeBag = DisposeBag()
    private var query: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    @IBAction func tapButton(_ sender: Any) {
        guard let query = query else { return }
        let vc = HomeViewController.make(with: HomeViewModel(language: query))
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension BaseViewController {
    private func bind() {
        textField.rx.text.orEmpty.asObservable()
            .subscribe { [weak self] in
                guard let value = $0.element else { return }
                self?.viewModel.set(text: value)
            }
            .disposed(by: disposeBag)
        
        viewModel.title.asObservable()
            .subscribe { [weak self] in
                if let inputText = $0.element {
                    self?.label.text = "「\(inputText)」で検索"
                    self?.query = inputText
                }
            }.disposed(by: disposeBag)
    }
}
