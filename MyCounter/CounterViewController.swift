//
//  CounterViewController.swift
//  MyCounter
//
//  Created by WangQi on 16/2/29.
//  Copyright © 2016年 WangQi. All rights reserved.
//

import Foundation
import UIKit

class CounterViewController: UIViewController {
    
    var timeLabel: UILabel?
    var timeButtons: [UIButton]?
    var startStopButton: UIButton?
    var clearButton: UIButton?
    
    let timeButtonInfos = [("1min", 60), ("3mins", 180), ("5mins",300), ("sec", 1)]
    
    var remainingSeconds: Int = 0 {
        willSet(newSeconds) {
            let mins = newSeconds / 60
            let seconds = newSeconds % 60
            self.timeLabel!.text = String(format: "%02d:%02d", mins, seconds)
        } //willSet观察器会将新的属性值即是remainingSeconds的变化的值作为常量参数传入
    }
    
    var isCounting: Bool = false {
        willSet(newValue) {
            if newValue {
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(CounterViewController.updateTimer(_:)), userInfo: nil, repeats: true)
                //timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer:", userInfo: nil, repeats: true)
                
            } else {
                timer?.invalidate()
                timer = nil
            }
            setSettingButtonsEnabled(!newValue)
            //设置按钮在不同isCounting状态下的样式（settingButtons是指在计时器停止时可以操作按钮设置时间）
        }
        
    }
    
    func setSettingButtonsEnabled(enabled: Bool) {
        for button in self.timeButtons! {
            button.enabled = enabled
            button.alpha = enabled ? 1.0 : 0.3
        }
        clearButton!.enabled = enabled
        clearButton!.alpha = enabled ? 1.0 : 0.3
    }
   
    var timer: NSTimer?
    // ?可以写出更安全的代码
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        //self.view.alpha = 0.78
        setupTimeLabel()
        setuptimeButtons()
        setupActionButtons()
        
       // [self alertViewControl]
        
    }
    
    //重载ViewController中的viewWillLayoutSubviews方法。在ViewController中的视图view大小改变时自动调用（横竖屏切换会改变视图控制器中view的大小）,设置UI控件的位置和大小。
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        timeLabel!.frame = CGRectMake(10, 40, self.view.bounds.size.width - 20, 200)
        
        let gap = (self.view.bounds.size.width - 10 * 2 - (CGFloat(timeButtons!.count) * 64)) / CGFloat(timeButtons!.count - 1)
        for (index, button) in timeButtons!.enumerate() {
            let buttonLeft = 10 + (64 + gap) * CGFloat(index)
            button.frame = CGRectMake(buttonLeft, self.view.bounds.size.height - 130, 64, 44)
        }
        
        startStopButton!.frame = CGRectMake(10, self.view.bounds.size.height - 65, self.view.bounds.size.width - 20 - 100, 44)
        clearButton!.frame = CGRectMake(10 + self.view.bounds.size.width - 20 - 100 + 20, self.view.bounds.size.height - 65, 80, 44)
        
    }
    
    // 创建倒计时剩余时间标签
    func setupTimeLabel() {
        timeLabel = UILabel()
        timeLabel!.textColor = UIColor.whiteColor()
        timeLabel!.font = UIFont(name: "Helvetica", size: 115)
        timeLabel!.backgroundColor = UIColor.blackColor()
        timeLabel!.textAlignment = NSTextAlignment.Center
        
        self.view.addSubview(timeLabel!) //将timeLabel添加到了控制器对应的view上
    }
    
    func setuptimeButtons() {
        
        var buttons: [UIButton] = [UIButton]()
        for (index, (title, _)) in timeButtonInfos.enumerate() {
            // _替代命名，表示不生成对应得变量
            
            let button: UIButton = UIButton()
            button.tag = index
            button.setTitle("\(title)", forState: UIControlState.Normal)

            button.backgroundColor = UIColor.orangeColor()
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
            
            button.addTarget(self, action: #selector(CounterViewController.timeButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            //button.addTarget(self, action: "timeButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            
            buttons += [button]
            self.view.addSubview(button)
            
        }
        timeButtons = buttons
    }
    
    
    func setupActionButtons() {
        
        startStopButton = UIButton()
        startStopButton!.backgroundColor = UIColor.redColor()
        startStopButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        startStopButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        
        startStopButton!.setTitle("Start/Stop", forState:UIControlState.Normal)
        startStopButton!.addTarget(self, action: #selector(CounterViewController.startStopButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(startStopButton!)
        
        clearButton = UIButton()
        clearButton!.backgroundColor = UIColor.redColor()
        clearButton!.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        clearButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        
        clearButton!.setTitle("Reset", forState: UIControlState.Normal)
        clearButton!.addTarget(self, action: #selector(CounterViewController.clearButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(clearButton!)
    }
    
    //为startStopButton设置了点击后的回调方法startStopButtonTapped:；为clearButton设置了点击后的回调方法clearButtonTapped:.
    //回调方法  Actions & Callbacks
    func startStopButtonTapped(sender: UIButton) {
        isCounting = !isCounting
        
        if isCounting {
            createAndFireLocalNotificationAfterSeconds(remainingSeconds)
        } else {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        } // 启动计时器时创建并注册计时结束时的本地提醒；停止时，取消当前app所注册的所有本地提醒
    }
    
    func clearButtonTapped(sender: UIButton) {
        remainingSeconds = 0
    }
    
    func timeButtonTapped(sender: UIButton) {
        let (_, seconds) = timeButtonInfos[sender.tag]
        remainingSeconds += seconds
        //通过控件tag 找到对应的按钮信息。按钮信息时一个元组，第二个参数seconds 存储着每次点击增加的seconds
    }
    
    func updateTimer(timer: NSTimer) {
       
        remainingSeconds -= 1
     
        if remainingSeconds == 0 {
            timer.invalidate()
            let alertController = UIAlertController(title: "Invalidate!", message: "", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            //let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    //本地通知系统UILocalNotification 定义一个方法createAndFireLocalNotificationAfterSeconds
    func createAndFireLocalNotificationAfterSeconds(seconds: Int) {
        
        UIApplication.sharedApplication().cancelAllLocalNotifications() //cancel所有当前app已注册的本地消息
        let notification = UILocalNotification()   //create 一个新的本地消息对象notification
        
        let timeIntervalSinceNow = Double(seconds)
        notification.fireDate = NSDate(timeIntervalSinceNow: timeIntervalSinceNow)
        // NSDate(timeIntervalSinceNow: double) 构造器创建从当前时间往后推n秒的一个时间
        
        notification.timeZone = NSTimeZone.systemTimeZone()
        notification.alertBody = "wangqi"
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }
    
}