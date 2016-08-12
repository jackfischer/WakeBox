//
//  AppDelegate.swift
//  WakeBox
//
//  Created by Jack Fischer on 11/14/15.
//  Copyright © 2015 trump6. All rights reserved.
//

import Cocoa
import IOKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet var speedOut: NSSlider!
    @IBOutlet var sliderOut: NSSlider!
    @IBOutlet var datePicker: NSDatePicker!
    @IBOutlet var dateClock: NSDatePicker!
    @IBOutlet var speedBlurb: NSTextField!
    let caff_task = Task()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        print("Up")
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        caff_task.terminate()
    }
    
    
    @IBAction func pickerChange(_ sender: NSDatePicker) {
        dateClock.dateValue = sender.dateValue
    }
    @IBAction func clockChange(_ sender: NSDatePicker) {
        datePicker.dateValue = sender.dateValue
    }
    @IBAction func speedChange(_ sender: NSSlider) {
        speedBlurb.stringValue = "Wake Speed (\(speedOut.integerValue) minutes)"
    }
   
    
    @IBAction func setWakeBox(_ sender: NSButton) {
        //Create gregorian calendar and formatter
        let calendar: Calendar = Calendar.current
        //let formatter: NSDateFormatter = NSDateFormatter()
        
        //extract hour/minute from ui
        let components: DateComponents = calendar.components([Calendar.init.hour, Calendar.Unit.minute] , from: datePicker.dateValue)
        //print(components)
        
        //calculate next_date in GMT
        var next_date: Date = calendar.nextDate(after: Date(), matching: components, matchingPolicy: Calendar.Options.matchNextTime)!
        
        //print(calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: next_date))

        //subtract wakeup speed from next_date, so time fires at beginning of increase in brightness
        next_date = next_date.addingTimeInterval(TimeInterval.init(-60*speedOut.integerValue))
        
        //set up NSTimeInterval and NSTimer
        let interval: TimeInterval = next_date.timeIntervalSinceNow
        print(interval)
        Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(AppDelegate.timerFire(_:)), userInfo: nil, repeats: false)
        
        //Turn down brightness and brightness slider
        setBrightnessLevel(0.0)
        sliderOut.floatValue = 0.0 //Adjust brightness slider
        
        //launch caffeinate
        caff_task.launchPath = "/usr/bin/caffeinate"
        caff_task.launch()
    }
    
    @objc func timerFire(_ timer: Timer) {
        print("in timerFire")
        
        var iteration = 0
        let end = Int(self.speedOut.integerValue * 60)
        var currentLevel: Float = 0
        let step = Float(self.speedOut.integerValue * 60)
        
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
        let timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: queue)
        timer.setTimer(start: DispatchTime.now(), interval: 1 * NSEC_PER_SEC, leeway: NSEC_PER_SEC / 10)
        timer.setEventHandler {
            currentLevel += step
            self.setBrightnessLevel(currentLevel)
            
            iteration += 1
            if iteration == end {
                timer.cancel()
                self.caff_task.terminate()
                print("Everything done.")
            }
        }
        
        timer.resume()
        
        /*
        let qualityOfServiceClass = QOS_CLASS_USER_INTERACTIVE
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            print("This is run on the background queue")
            
            let totalSeconds: Float = Float(self.speedOut.integerValue * 60)
            for (var i = 0; i < Int(totalSeconds); i++){
                //TODO: use a timer to fire every second or whatever to increase brightness instad of loop
                sleep(1)
                let brightness: Float = Float(i)/totalSeconds
                self.setBrightnessLevel(brightness)
                print("Setting brightness to \(brightness)")
            }
        })
        */
    }
    
    @IBAction func slider(_ sender: NSSlider) {
        //var x: Double
        let x: Float = sender.floatValue / 100
        print(x)
        setBrightnessLevel(x)
    }
    

    func setBrightnessLevel(_ level: Float) {
        //Change screen brightness
        var iterator: io_iterator_t = 0
        if IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("IODisplayConnect"), &iterator) == kIOReturnSuccess {
            var service: io_object_t = 1
            while service != 0 {
                service = IOIteratorNext(iterator)
                IODisplaySetFloatParameter(service, 0, kIODisplayBrightnessKey, level)
                IOObjectRelease(service)
            }
        }
    }
    
    
}

