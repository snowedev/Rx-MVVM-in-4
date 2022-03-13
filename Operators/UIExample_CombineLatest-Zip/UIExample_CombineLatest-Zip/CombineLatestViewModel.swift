//
//  ViewModel.swift
//  UIExample_CombineLatest-Zip
//
//  Created by Wonseok Lee on 2022/02/25.
//

import Foundation
import RxSwift

final class CombineLatestViewModel {
	struct PasswordCheckInput {
		let pwText: Observable<String>
		let pwCheckerText: Observable<String>
	}
	struct PasswordCheckOutput {
		let isSamePw: Observable<Bool>
	}
}

extension CombineLatestViewModel {
	func checkingPwCorrection(input: PasswordCheckInput) -> PasswordCheckOutput {
		return .init(
			isSamePw:
				Observable
				.combineLatest(input.pwText, input.pwCheckerText)
				.map { first, second in
					return (!first.isEmpty && !second.isEmpty) && first == second ? true : false
				}
		)
	}
}

final class ZipViewModel {
	struct firstInput {
		fileprivate let text: PublishSubject<String> = .init()
		func callAPI(text: String) {
			self.text.onNext(text+"<< API(1) Result")
		}
	}
	
	struct secondInput {
		fileprivate let text: PublishSubject<String> = .init()
		func callAPI(text: String) {
			self.text.onNext(text+"<< API(2) Result")
		}
	}
	
	struct Output {
		let result: Observable<String>
	}
}

extension ZipViewModel {
	func zipTwoAPI(first: firstInput, second: secondInput) -> Output {
		return .init(
			result: Observable
				.zip(first.text, second.text)
				.map { $0+"\n"+$1 }
		)
	}
}
