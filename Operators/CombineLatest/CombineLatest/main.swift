//
//  main.swift
//  CombineLatest
//
//  Created by 이원석 on 2022/02/20.
//

import Foundation
import RxSwift


let left = PublishSubject<String>()
let right = PublishSubject<String>()
let disposeBag = DisposeBag()

//MARK: CombineLatest

func testCombineLatest_Setup() {
	Observable
		.combineLatest(left, right, resultSelector: { (lastLeft, lastRight) in
			"\(lastLeft) \(lastRight)"
		})
		.subscribe(onNext: { str in print(str) })
		.disposed(by: disposeBag)
}

func testCombineLatest_Implement() {
	print("> Sending a value to Left")
	left.onNext("Hello,")
	print("> Sending a value to Right")
	right.onNext("world")
	print("> Sending another value to Right")
	right.onNext("RxSwift")
	print("> Sending another value to Left")
	left.onNext("Have a good day,")
}

testCombineLatest_Setup()
testCombineLatest_Implement()

/**
 `Result`
 > Sending a value to Left
 > Sending a value to Right
 Hello, world
 > Sending another value to Right
 Hello, RxSwift
 > Sending another value to Left
 Have a good day, RxSwift
 */
