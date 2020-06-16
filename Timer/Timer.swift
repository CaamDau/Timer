//Created  on 2019/3/4 by  LCD:https://github.com/liucaide .

/***** 模块文档 *****
 *
 */




import Foundation
import CaamDauExtension
public protocol TimeProtocol {
    func time(withModel model:Time.Model, id:String)
}

public class Time {
    private init(){}
    public static let shared:Time = Time()
    ///时间倒计时标识存储 - 区别每个计时队列
    private var timers:[String:Time.Timer] = [:]
    
    public static func remove(_ id:String) {
        Time.shared.timers.removeValue(forKey: id)
    }
}

extension Time {
    /// 计时器
    public class Timer {
        private init(){}
        private var timer:DispatchSourceTimer?
        /// 初始化一个计时器 handler: () -> Bool:是否停止  mainThread:主线程操作
        public init(id:String,
                    repeatSecond:Double,
                    handler:@escaping (() -> Bool),
                    mainThread:@escaping (() -> Void),
                    qos:DispatchQoS = .default) {
            let queue = DispatchQueue(label: id, qos:qos)
            self.timer = DispatchSource.makeTimerSource(queue:queue)
            self.timer?.schedule(wallDeadline:.now(), repeating: .milliseconds(Int(repeatSecond*1000)), leeway: .milliseconds(10))
            self.timer?.setEventHandler { [weak self] in
                //print(tv)
                if handler() {
                    self?.timer?.cancel()
                    self?.timer = nil
                }
                DispatchQueue.main.async(execute: mainThread)
            }
            self.timer?.resume()
        }
    }
    /// 回调类型
    public enum Style {
        case delegate(_ d:TimeProtocol, _ tag:String, _ remainTime:TimeInterval, _ repeatSecond:Double)
        case notification(_ tag:String, _ remainTime:TimeInterval, _ repeatSecond:Double)
        case callBack( _ tag:String, _ remainTime:TimeInterval, _ repeatSecond:Double, _ block:((Time.Model)->Void))
    }
    
    /// 计时模型
    public class Model {
        public var year:Int = 0
        public var month:Int = 0
        public var day:Int = 0
        public var hour:Int = 0
        public var minute:Int = 0
        public var second:Int = 0
        public var millisecond:Int = 0
        
        /// 剩余时间
        public var remainTime:TimeInterval = 0
    }
}


public extension Time {
    class func make(id:String,
                    remainTime:TimeInterval,
                    repeatSecond:Double,
                    mainThread block:@escaping ((Time.Model) -> Void),
                    qos:DispatchQoS = .default){
        guard !Time.shared.timers.keys.contains(id) else {return}
        // 监听用户手动改变系统时间 UIApplicationSignificantTimeChangeNotification
        /*
         NotificationCenter.default.addObserver(forName: UIApplication.Significant.timeChangeNotification, object: nil, queue: nil) { (n) in
         
         }*/
        /// 当前时间
        let endTime = Date().cd.timestamp()+remainTime
        let endDate = endTime.cd.date()
        let time = Time.Model()
        time.remainTime = endTime
        Time.shared.timers[id] = Time.Timer(id: id, repeatSecond: repeatSecond, handler: { () -> Bool in
            /// 当前时间 与 结束时间间隔 即剩余时间
            let nowDate2 = Date()
            let nowTime2 = nowDate2.cd.timestamp()
            let interval = endTime - nowTime2
            let coms = nowDate2.cd.interval(endDate)
            if interval <= 0 {
                time.year = 0
                time.month = 0
                time.day = 0
                time.hour = 0
                time.minute = 0
                time.second = 0
                time.millisecond = 0
                time.remainTime = 0
                Time.shared.timers.removeValue(forKey: id)
            }else{
                time.year = coms.year ?? 0
                time.month = coms.month ?? 0
                time.day = coms.day ?? 0
                time.hour = coms.hour ?? 0
                time.minute = coms.minute ?? 0
                time.second = coms.second ?? 0
                time.millisecond = Int((interval - TimeInterval(Int(endTime - nowTime2))) * 1000.0)
                time.remainTime = interval
            }
            return interval <= 0
        }, mainThread: {
            block(time)
        }, qos:qos)
    }
}
public extension Time {
    class func make(_ style:Time.Style, qos:DispatchQoS = .default) {
        switch style {
        case let .delegate(d, id, time, second):
            Time.make(id: id, remainTime: time, repeatSecond: second, mainThread: { (model) in
                d.time(withModel: model, id:id)
            }, qos: qos)
        case let .notification(id, time, second):
            Time.make(id: id, remainTime: time, repeatSecond: second, mainThread: { (model) in
                NotificationCenter.default.post(name: Notification.Name(id), object: id, userInfo: [id:model])
            }, qos: qos)
        case let .callBack(id, time, second, block):
            Time.make(id: id, remainTime: time, repeatSecond: second, mainThread: block, qos: qos)
        }
    }
}
public extension Time {
    /// 剩余时间转换 - *提供一个参照样例*
    class func remainTime<T>(_ time:T) -> TimeInterval {
        switch time {
        case let t as String:
            guard let date = t.cd.date() else{
                return 0
            }
            return date.cd.timestamp() - Date().cd.timestamp()
        case let t as (String, String):
            guard let date = t.0.cd.date(t.1) else{
                return 0
            }
            return date.cd.timestamp() - Date().cd.timestamp()
        case let t as Date:
            return t.cd.timestamp() - Date().cd.timestamp()
        default:
            return 0
        }
    }
}

//MARK:--- 延时执行 ----------
public extension Time {
    /// 如果时间大于 30 建议使用 Time.make
    class func after(_ time:Double, _ block:@escaping (() -> Void)){
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: block)
        /*
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2*NSEC_PER_SEC))/Double(NSEC_PER_SEC)) {
            
        }*/
    }
}
