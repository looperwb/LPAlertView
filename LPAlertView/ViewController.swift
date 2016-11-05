//
//  ViewController.swift
//  LPAlertView
//
//  Created by zwb on 2016/11/5.
//  Copyright © 2016年 zwb. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickButton(sender: UIButton) {
        
        let data = ["已出库", "未出库", "将出库"]
        
        let alert = LPAlertView()
        let startDate = alert.addDatePicker("请输入开始时间", withLabel: "开始时间") { date in
            print(date)
        }
        let endDate = alert.addDatePicker("请输入结束时间", withLabel: "结束时间", action: nil)
        
        let txt0 = alert.addTextField("请输入公司名称", withLabel: "公司名称")
        let txt1 = alert.addTextField("请输入单据编号", withLabel: "单据编号")
        let txt2 = alert.addTextField("请输入结束时间", withLabel: "客户名称")
        let txt3 = alert.addTextField("请输入公司名称", withLabel: "车牌号码")
        
        let txt4 = alert.addPicker("请输入出库标识", singleConditionSelection: data, withLabel: "出库标识") { item in
            print("item: \(item)")
        }
        
        alert.addButton("查询") {
            print("start value: \(startDate.text)")
            print("end   value: \(endDate.text)")
            print("txt0  value: \(txt0.text)")
            print("txt1  value: \(txt1.text)")
            print("txt2  value: \(txt2.text)")
            print("txt3  value: \(txt3.text)")
            print("txt4  value: \(txt4.text)")
            
            let string = startDate.text! + "\n" + endDate.text! + "\n" + txt0.text! + "\n" + txt1.text! + "\n" + txt2.text! + "\n" + txt3.text! + "\n" + txt4.text!
            
            self.label.text = string
            
            self.delay(1.0, message: string)
        }
        
        alert.addButton("统计")
        alert.show("查询条件", duration: 0.2, completeText: nil)
        
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "确定", style: .Default, handler: nil)
        alertController.addAction(ok)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func delay(Interval: NSTimeInterval, message: String) {
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(Interval * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            self.showAlert("输出信息", message: message)
        }
    }
    
}
