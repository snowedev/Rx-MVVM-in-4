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
	private let combineLatestTitleLabel = UILabel().then {
		$0.font = .systemFont(ofSize: 20, weight: .bold)
		$0.textColor = .link
		$0.text = "combineLatest"
	}
	
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
		$0.backgroundColor = .systemRed
		$0.layer.cornerRadius = 17
		$0.layer.cornerCurve = .continuous
	}
	
	private let zipTitleLabel = UILabel().then {
		$0.font = .systemFont(ofSize: 20, weight: .bold)
		$0.textColor = .link
		$0.text = "Zip"
	}
	
	private let firstRequestTextField = UITextField().then {
		$0.font = UIFont.systemFont(ofSize: 20, weight: .medium)
		$0.placeholder = "입력"
		$0.autocapitalizationType = .none
		$0.autocorrectionType = .no
		$0.textColor = .black
		$0.borderStyle = .roundedRect
	}
	
	private let firstReqeustButton = UIButton().then {
		$0.backgroundColor = .systemRed
		$0.layer.cornerRadius = 10
		$0.layer.cornerCurve = .continuous
		$0.setTitle("API(1) Reqeust", for: .normal)
	}
	
	private let secondRequestTextField = UITextField().then {
		$0.font = UIFont.systemFont(ofSize: 20, weight: .medium)
		$0.placeholder = "입력"
		$0.autocapitalizationType = .none
		$0.autocorrectionType = .no
		$0.textColor = .black
		$0.borderStyle = .roundedRect
	}
	
	private let secondReqeustButton = UIButton().then {
		$0.backgroundColor = .systemRed
		$0.layer.cornerRadius = 10
		$0.layer.cornerCurve = .continuous
		$0.setTitle("API(2) Reqeust", for: .normal)
	}
	
	private let resultLabel = UILabel().then {
		$0.font = .systemFont(ofSize: 20, weight: .bold)
		$0.textColor = .systemGreen
		$0.textAlignment = .center
		$0.numberOfLines = 2
	}
	
	private let combineLatestViewModel = CombineLatestViewModel()
	private let zipViewModel = ZipViewModel()
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		layout()
		bind()
		zipBind()
	}
}

private extension ViewController {
	func layout() {
		view.backgroundColor = .systemGray6
		view.addSubview(combineLatestTitleLabel)
		view.addSubview(pwTextField)
		view.addSubview(pwCheckTextField)
		view.addSubview(signalView)
		view.addSubview(zipTitleLabel)
		view.addSubview(firstRequestTextField)
		view.addSubview(firstReqeustButton)
		view.addSubview(secondRequestTextField)
		view.addSubview(secondReqeustButton)
		view.addSubview(resultLabel)
		
		combineLatestTitleLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
		}
		
		pwTextField.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(self.combineLatestTitleLabel.snp.bottom).offset(20)
		}
		
		pwCheckTextField.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(pwTextField.snp.bottom).offset(20)
			$0.left.right.equalTo(pwTextField)
		}
		
		signalView.snp.makeConstraints {
			$0.top.equalTo(self.pwTextField.snp.top)
			$0.left.equalTo(self.pwTextField.snp.right).offset(10)
			$0.size.equalTo(self.pwTextField.snp.height)
		}
		
		zipTitleLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(self.pwCheckTextField.snp.bottom).offset(20)
		}
		
		firstRequestTextField.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(self.zipTitleLabel.snp.bottom).offset(20)
			$0.left.right.equalTo(pwTextField)
		}
		
		firstReqeustButton.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(self.firstRequestTextField.snp.bottom).offset(20)
			$0.left.right.equalTo(pwTextField)
			$0.height.equalTo(50)
		}
		
		secondRequestTextField.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(self.firstReqeustButton.snp.bottom).offset(20)
			$0.left.right.equalTo(pwTextField)
		}
		
		secondReqeustButton.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(self.secondRequestTextField.snp.bottom).offset(20)
			$0.left.right.equalTo(pwTextField)
			$0.height.equalTo(50)
		}
		
		resultLabel.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(self.secondReqeustButton.snp.bottom).offset(20)
			$0.left.right.equalTo(pwTextField)
		}
	}
	
	func bind() {
		let pwInput = CombineLatestViewModel.PasswordCheckInput(
			pwText: pwTextField.rx.text.orEmpty.asObservable(),
			pwCheckerText: pwCheckTextField.rx.text.orEmpty.asObservable()
		)
		
		let pwOutput = combineLatestViewModel.checkingPwCorrection(input: pwInput)
		
		pwOutput.isSamePw.bind(
			with: self,
			onNext: { owner, response in
				owner.signalView.backgroundColor = response ? .systemGreen : .systemRed
			}
		).disposed(by: disposeBag)
	}
	
	func zipBind() {
		let firstInput = ZipViewModel.firstInput()
		let secondInput = ZipViewModel.secondInput()
		
		firstReqeustButton.rx.tap.bind(
			with: self,
			onNext: { (owner, _) in
				owner.firstReqeustButton.backgroundColor = .systemGreen
				firstInput.callAPI(text: owner.firstRequestTextField.text ?? "")
			}).disposed(by: disposeBag)
		
		secondReqeustButton.rx.tap.bind(
			with: self,
			onNext: { (owner, _) in
				owner.secondReqeustButton.backgroundColor = .systemGreen
				secondInput.callAPI(text: owner.secondRequestTextField.text ?? "")
			}).disposed(by: disposeBag)
		
		let output = zipViewModel.zipTwoAPI(
			first: firstInput,
			second: secondInput
		)
		
		output.result.debug("result").bind(
			with: self,
			onNext: { (owner, result) in
				owner.firstReqeustButton.backgroundColor = .systemRed
				owner.secondReqeustButton.backgroundColor = .systemRed
				owner.firstRequestTextField.text?.removeAll()
				owner.secondRequestTextField.text?.removeAll()
				owner.resultLabel.text = result
			}).disposed(by: disposeBag)
	}
}
