<p>
  <img src="https://github.com/liucaide/Images/blob/master/CaamDau/caamdau.png" align=centre />
</p>

[![CI Status](https://img.shields.io/travis/CaamDau/Timer.svg?style=flat)](https://travis-ci.org/CaamDau/Timer)
[![Version](https://img.shields.io/cocoapods/v/CaamDauTimer.svg?style=flat)](https://cocoapods.org/pods/CaamDauTimer)
[![License](https://img.shields.io/cocoapods/l/CaamDauTimer.svg?style=flat)](https://cocoapods.org/pods/CaamDauTimer)
[![Platform](https://img.shields.io/cocoapods/p/CaamDauTimer.svg?style=flat)](https://cocoapods.org/pods/CaamDauTimer)
[![](https://img.shields.io/badge/Swift-4.0~5.0-orange.svg?style=flat)](https://cocoapods.org/pods/CaamDauTimer)

# Timer
计时管理

```
pod 'CaamDauTimer'

pod 'CaamDau/Timer'
```

#### 创建倒计时
```ruby
func countDown(_ tag:Int){
        switch tag {
        case 0:// 代理接收
            CD_Timer.make(.delegate(self, "123", 120, 0.1))
        case 1://广播
            CD_Timer.make(.notification("456", 120, 0.1))
        case 2://闭包回调接收
            CD_Timer.make(.callBack("789", 60, 0.1, { [weak self](model) in
                self?.lab_3.cd.text("\(model.day)天\(model.hour):\(model.minute):\(model.second):\(model.millisecond/100)")
            }))
        default:
            break
        }
    }
```

#### 接收
```ruby

extension ViewController:CD_TimerProtocol {
    func cd_timer(withModel model: CD_Timer.Model, id: String) {
        self.lab_1.cd.text("\(model.day)天\(model.hour):\(model.minute):\(model.second):\(model.millisecond/100)")
    }
}

NotificationCenter.default.rx
    .notification(Notification.Name(rawValue: "456"), object: nil)
    .asObservable()
    .subscribe(onNext: { [weak self](n) in
        if let model = n.object as? CD_Timer.Model {
            self?.title = "\(model.day)天\(model.hour):\(model.minute):\(model.second)"
        }
    })
    .disposed(by: disposeBag)

deinit {
    //如果不需要保持 可以移除
    CD_Timer.remove("456")
}
```
