# 1교시 - 개념잡기

> 01:23:00 / 03:41:52

## RxSwift를 사용한 비동기 프로그래밍

<img width=20% src="/Users/ws/Library/Application Support/typora-user-images/image-20210821193637067.png" alt="image-20210821193637067"/>

### 1. 동기 / 비동기

초단위로 시간이 계속 흐르는 `타이머`가 있고 Json을 `Load`할 수 있는 버튼이 있다고 할 때 `Load`를 눌렀을 때 `타이머`가 멈추지 않으면서 `Load`에 따른 동작도 동시에 병행되려면 **이 작업은 모두 비동기적으로 이루어져야한다. ** 

> 동기적으로 이루어진다면 Load 버튼을 누름과 동시에 데이터를 받아오기 전까지 타이머는 멈출것이다.



그러면 Load에 대한 동작 코드를 이렇게 짤 수 있다.  

이 때, 고려해야할 것은 UI 처리는 Main에서 이루어져야한다는 것이다. 그렇기 때문에 데이터를 받아오는 부분만 Concurrent Queue인 global() 쓰레드에서 처리해주었다.

```swift
let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

// 데이터의 로드는 비동기로 하되 그 결과 값은 메인 스레드로 탈출 클로저를 활용하여 넘겨준다.
// 굳이 탈출 클로저를 사용하는 이유는 그냥 return 값으로 둘 경우 데이터를 받기 전까지 return문에서 문제가 생기기 때문.
func downloadJson(_ url: String, _ completion: @escaping(String?) -> Void) {
        DispatchQueue.global().async {
            let url = URL(string: url)!
            let data = try! Data(contentsOf: url)
            let json = String(data: data, encoding: .utf8)
            DispatchQueue.main.async {
                completion(json)
            }
        }
    }

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
      	self.downloadJson(MEMBER_LIST_URL) { json in
            self.editView.text = json
            self.setVisibleWithAnimation(self.activityIndicator, false)
        }
    }
}
```



이렇게 비동기로 처리할 수 있는데 문제는 이러한 코드가 많아질 경우 굉장히 복잡해지며 상용구 코드가 많아진다는 단점이 있었다.  

만약 Json을 4번 연속적으로 순서대로 받아야한다면 코드는 아래와 같아질 것이다.

```swift
@IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        self.downloadJson(MEMBER_LIST_URL) { json in
            self.editView.text = json
            self.setVisibleWithAnimation(self.activityIndicator, false)
            
            self.downloadJson(MEMBER_LIST_URL) { json in
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
                
                self.downloadJson(MEMBER_LIST_URL) { json in
                    self.editView.text = json
                    self.setVisibleWithAnimation(self.activityIndicator, false)
                    
                    self.downloadJson(MEMBER_LIST_URL) { json in
                        self.editView.text = json
                        self.setVisibleWithAnimation(self.activityIndicator, false)
                    }
                }
            }
        }
    } 
```



### 2. 불편함에서 온 아이디어

애초에 탈출 클로저를 사용하지 않고 비동기로 생긴 데이터를 return 값으로 받을 수 있다면 보다 코드가 간결해질텐데..

```swift
// 탈출 클로저
self.downloadJson(MEMBER_LIST_URL) { json in
            self.editView.text = json
            self.setVisibleWithAnimation(self.activityIndicator, false)
        }

// 일반 Return문
let json = downloadJson(MEMBER_LIST_URL)
self.editView.text = json
self.setVisibleWithAnimation(self.activityIndicator, false)
```



비동기적으로 생겨나는 데이터를 클로저로 주지않고 return 값으로 줄 수 있게 만드는 방법

```swift

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class 나중에생기는데이터<T> {
    private let task: (@escaping (T) -> Void) -> Void
  
    init(task: @escaping (@escaping (T) -> Void) -> Void) {
      self.task = task
    }
  
    func 나중에오면(_ f: @escaping (T) -> Void) {
      task(f)
    }
}

class ViewController: UIViewController {
    
  	//...
  
    func downloadJson(_ url: String) -> 나중에생기는데이터<String?> {
        return 나중에생기는데이터() { f in
            DispatchQueue.global().async {
                let url = URL(string: url)!
                let data = try! Data(contentsOf: url)
                let json = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    f(json)
                }
            }
        }
    }
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        let json: 나중에생기는데이터<String?> = downloadJson(MEMBER_LIST_URL)
        json.나중에오면 { json in
            self.editView.text = json
            self.setVisibleWithAnimation(self.activityIndicator, false)
        }
    }
}
```

그래서 위와 같이 동작하는 유틸리티들이 생겨남!

* PromiseKit
* Bolt

그리고..

* ### **`RxSwift`** 



### 3. RxSwift의 등장

`RxSwift의 목적`: **비동기적으로 생겨나는 데이터(나중에 생기는 데이터)를 클로저로 주지않고 return 값으로 줄 수 있게 만들기 위해 만들어진 유틸리티**



RxSwift에서는 `나중에오면` == `subscribe` / `나중에생기는데이터` == `Observable`

* 나중에 생기는 데이터를 사용할 때에는 subscribe을 통해 사용하면 된다.

* 사용할 때 event가 오는데 그 event의 종류는 `.next`, `.completed`, `.error` 세가지이다.

  * .next: 데이터가 전달될 때
  * .completed: 데이터가 완전히 다 전달되고 끝났을 때
  * .error: 에러났을 때

* 아래 코드에서 살펴봐야 하는 부분

  **1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법**

  **2. Observable로 오는 데이터를 받아서 처리하는 방법** 

```swift
import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController {
	  // ...
    
    func downloadJson(_ url: String) -> Observable<String?> {
	      // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
        return Observable.create { f in
            DispatchQueue.global().async {
                let url = URL(string: url)!
                let data = try! Data(contentsOf: url)
                let json = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    f.onNext(json) // 데이터 전달(여러개도 가능)
                  	f.onComplete() // 데이터 전달 종료, 순환 참조 풀기위해서 클로져 사용이 끝났다면 없애준다.
                }
            }
                                  
            // 이것 역시 return 해주어야 함
            return Disposables.create()
        }
    }
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
      
        // 2. Observable로 오는 데이터를 받아서 처리하는 방법
				 _ = downloadJson(MEMBER_LIST_URL)
        .subscribe { event in
            switch event {
            case .next(let json) :
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
                
            case .completed:
                break
            case .error:
                break
            }
        }
    }
}

```



### 4. Observable의 create(), subscribe()

`Observable의 생명주기` 

> 동작이 끝난 Observable은 재사용하지 못함

1. create

2. Subscribe -> 이 때 Observable이 실행됨 그냥 Observable을 만든다고 실행되지 않음

3. onNext

   ---- 끝 ----

4. onCompleted / onError

5. Disposed

```swift
import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController {
    // ...
    
    func downloadJson(_ url: String) -> Observable<String?> {
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
        let disposable = downloadJson(MEMBER_LIST_URL)
        .subscribe {event in
            switch event {
            // .next: 데이터가 전달될 때
            case .next(let json) :
                DispatchQueue.main.async {
                    self.editView.text = json
                    self.setVisibleWithAnimation(self.activityIndicator, false)
                }
            // .completed: 데이터가 완전히 다 전달되고 끝났을 때
            case .completed:
                break
            // error: 에러났을 때
            case .error:
                break
            }
        }
        
        // 작업 취소
        // disposable.dispose()
    }
}

```

RxSwift의 기본 사용법

---



## Sugar API

기본 사용법을 좀 더 간소화 시켜주는 API를 지칭(여러줄을 한줄로) / 지금 소개하는 것 이외에도 엄청 다양함

Sugar = Operator

 **[Operator의 종류](http://reactivex.io/documentation/operators.html) (각 설명 페이지에 존재하는 마블 그림에서 "화살표"는 Observable, "화살표의 색상"은 쓰레드, "|"는 onCompleted)**

> 그림을 이해하면 좀 더 쉽게 해당  Operator를 이해할 수 있음



###  `just` : 데이터를 하나만 전달하면 될 때 / [설명](http://reactivex.io/documentation/operators/just.html)

```swift
func downloadJson(_ url: String) -> Observable<String?> {
  return Observable.just("Hello World")
  // 아래의 것을 간소화 한 것
  //        return Observable.create { emitter in
  //            emitter.onNext("Hello World")
  //            emitter.onCompleted()
  //            return Disposables.create()
  //        }
  
  // onNext()에서는
  // Optional("Hello World")
}

// or 

func downloadJson(_ url: String) -> Observable<Array?> {
  return Observable.just(["Hello", "World"])
  // onNext()에서는
  // Optional(["Hello","World"])
}
```



### `from`: 데이터를 나눠서 보낼 때 / [설명](http://reactivex.io/documentation/operators/from.html)

```swift
func downloadJson(_ url: String) -> Observable<String?> {
	return Observable.just(["Hello", "World"])
  
  // onNext()에서는
  // Optional("Hello")
  // Optional("World")
}
```



### `Subscribe 간소화`

```swift
// 위에서 사용한 subscribe 간소화
_ = downloadJson(MEMBER_LIST_URL)
					.subscribe(onNext: { print($0) },
           onError: { err in print(err) },
           onCompleted: { print("Com") })
```



### `observeOn, subscribeOn` / [설명](http://reactivex.io/documentation/operators/observeon.html)

> observeOn 이외에도 map, filter등도 사용된다.

UI처리를 Main Thread해야하니까 써야하는 main 큐 간소화

```swift
case .next(let json) :
    DispatchQueue.main.async {
        self.editView.text = json
        self.setVisibleWithAnimation(self.activityIndicator, false)
    }

// 위에서 사용한 subscribe 간소화
_ = downloadJson(MEMBER_LIST_URL)
					// observeOn을 제외한 나머지 동작들을 어느 쓰레드에서 할것인지 정함 , 위치 무관: Operator
					.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default)) 
					// UI처리를 Main Thread해야하니까 써야하는 main 큐 간소화: Operator
          .observeOn(MainScheduler.instance)
          .subscribe(onNext: { print($0) },
           onError: { err in print(err) },
           onCompleted: { print("Com") })
```

