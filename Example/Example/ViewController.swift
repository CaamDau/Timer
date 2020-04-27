//Created  on 2019/3/12 by  LCD:https://github.com/liucaide .

/***** 模块文档 *****
 *
 */



import Foundation
import UIKit
import CaamDauTimer

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CD_Timer.after(1) {
            
        }
        
        CD_Timer.make(.callBack("123", 60, 1, { (m) in
            
        }))
    }
}



