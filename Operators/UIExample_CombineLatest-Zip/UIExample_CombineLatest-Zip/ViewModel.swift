//
//  ViewModel.swift
//  UIExample_CombineLatest-Zip
//
//  Created by Wonseok Lee on 2022/02/25.
//

import Foundation
import RxSwift

final class ViewModel {
	struct Input {
		let pwText: Observable<String>
		let pwCheckerText: Observable<String>
	}
	struct Output {
		let isSamePw: Observable<Bool>
	}
}

extension ViewModel {
	func checkingPwCorrection(input: Input) -> Output {
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
