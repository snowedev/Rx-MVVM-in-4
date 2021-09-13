//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }
    
    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }
    
    
    /** Observable의 생명주기
        > 동작이 끝난 Observable은 재사용하지 못함
        1. create
        2. Subscribe -> 이 때 Observable이 실행됨 그냥 Observable을 만든다고 실행되지 않음
        3. onNext
           ---- 끝 ----
        4. onCompleted / onError
        5. Disposed
    */
    
    /** Sugar API
     just, from ...
     */
    func downloadJson(_ url: String) -> Observable<String> {
        // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
        return Observable.create() { emitter in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { (data, _, err) in
                guard err == nil else {
                    // 에러 발생
                    emitter.onError(err!)
                    return
                }
                
                if let dat = data, let json = String(data: dat, encoding: .utf8) {
                    // 데이터 전달
                    emitter.onNext(json)
                }
                
                // 데이터 전달 완료, Observable 생명주기의 마지막 단계
                emitter.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create() {
                // .dispose()가 불렸을 때 실행
                task.cancel()
            }
        }
    }
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        // 2. Observable로 오는 데이터를 받아서 처리하는 방법
//        let disposable = downloadJson(MEMBER_LIST_URL)
//            .subscribe {event in
//                switch event {
//                // .next: 데이터가 전달될 때
//                case .next(let json) :
//                    DispatchQueue.main.async {
//                        self.editView.text = json
//                        self.setVisibleWithAnimation(self.activityIndicator, false)
//                    }
//                // .completed: 데이터가 완전히 다 전달되고 끝났을 때
//                case .completed:
//                    break
//                // error: 에러났을 때
//                case .error:
//                    break
//                }
//            }
        
        // 작업 취소
        // disposable.dispose()
        
        
        // 위에서 사용한 subscribe 간소화
//        _ = downloadJson(MEMBER_LIST_URL)
//            .observeOn(MainScheduler.instance) // UI처리를 Main Thread해야하니까 써야하는 main 큐 간소화: Operator
//            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default)) // observeOn을 제외한 나머지 동작들을 어느 쓰레드에서 할것인지 정함: Operator
//            .subscribe(onNext: { print($0) },
//                       onError: { err in print(err) },
//                       onCompleted: { print("Com") })
        
        let jsonObservable = downloadJson(MEMBER_LIST_URL)
        let helloObservable = Observable.just("Hello World")
        
        Observable.zip(jsonObservable, helloObservable) { $1 + "\n" + $0 }
            .observeOn(MainScheduler.instance) // UI처리를 Main Thread해야하니까 써야하는 main 큐 간소화: Operator
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default)) // observeOn을 제외한 나머지 동작들을 어느 쓰레드에서 할것인지 정함: Operator
            .subscribe(onNext: { json in
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
                
            })
    }
}
