//
//  ViewController.swift
//  RxMVVMSample
//
//  Created by Hiromi Fujita on 2020/12/24.
//

import UIKit
import RxCocoa
import RxSwift

final class HomeViewController: UIViewController {

    static func make(with viewModel: HomeViewModel) -> HomeViewController {
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        vc.viewModel = viewModel
        return vc
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    private var viewModel: HomeViewModelType!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Bind ViewModel Outputs
        viewModel.outputs.navigationBarTitle
            .observeOn(MainScheduler.instance)
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)

        viewModel.outputs.repositories
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items) { tableView, row, repository in
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "subtitle")
                cell.textLabel?.text = "\(repository.fullName)"
                cell.detailTextLabel?.textColor = .lightGray
                cell.detailTextLabel?.text = "\(repository.description)"
                return cell
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(Repository.self)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                let vc = DetailViewController.make(with: DetailViewModel(repository: $0))
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.isLoading
            .observeOn(MainScheduler.instance)
            .bind(to: indicatorView.rx.isAnimating)
            .disposed(by: disposeBag)

        viewModel.outputs.isLoading
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: $0 ? 50 : 0, right: 0)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.error
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                let ac = UIAlertController(title: "Error \($0)", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(ac, animated: true)
            })
            .disposed(by: disposeBag)
        

        // Bind ViewModel Inputs
        tableView.rx.reachedBottom.asObservable()
            .bind(to: viewModel.inputs.reachedBottomTrigger)
            .disposed(by: disposeBag)

        viewModel.inputs.fetchTrigger.onNext(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.indexPathsForSelectedRows?.forEach { [weak self] in
            self?.tableView.deselectRow(at: $0, animated: true)
        }
    }
}
