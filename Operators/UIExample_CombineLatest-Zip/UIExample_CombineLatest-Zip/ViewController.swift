//
//  ViewController.swift
//  UIExample_CombineLatest-Zip
//
//  Created by Wonseok Lee on 2022/02/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class ViewController: UIViewController {
	
	private let pwTextField = UITextField().then {
		$0.font = UIFont.systemFont(ofSize: 20, weight: .medium)
		$0.placeholder = "비밀번호 입력"
		$0.autocapitalizationType = .none
		$0.autocorrectionType = .no
		$0.textColor = .black
		$0.borderStyle = .roundedRect
	}
	
	private let pwCheckTextField = UITextField().then {
		$0.font = UIFont.systemFont(ofSize: 20, weight: .medium)
		$0.placeholder = "비밀번호 한번 더 입력"
		$0.autocapitalizationType = .none
		$0.autocorrectionType = .no
		$0.textColor = .black
		$0.borderStyle = .roundedRect
	}
	
	private let signalView = UIView().then {
		$0.backgroundColor = .red
		$0.layer.cornerRadius = 25
		$0.layer.cornerCurve = .continuous
	}
	
	private let viewModel = ViewModel()
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		layout()
		bind()
	}
}

private extension ViewController {
	func layout() {
		view.backgroundColor = .systemGray6
		view.addSubview(pwTextField)
		view.addSubview(pwCheckTextField)
		view.addSubview(signalView)
		
		pwTextField.snp.makeConstraints {
			$0.centerX.centerY.equalToSuperview()
		}
		
		pwCheckTextField.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(pwTextField.snp.bottom).offset(20)
			$0.left.right.equalTo(pwTextField)
		}
		
		signalView.snp.makeConstraints {
			$0.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
			$0.right.equalTo(self.view.safeAreaLayoutGuide).inset(20)
			$0.size.equalTo(50)
		}
	}
	
	func bind() {
		let input = ViewModel.Input(
			pwText: pwTextField.rx.text.orEmpty.asObservable(),
			pwCheckerText: pwCheckTextField.rx.text.orEmpty.asObservable()
		)
		
		let output = viewModel.checkingPwCorrection(input: input)
		
		output.isSamePw.bind(
			with: self,
			onNext: { owner, response in
				owner.signalView.backgroundColor = response ? .green : .red
			}
		).disposed(by: disposeBag)
	}
}
