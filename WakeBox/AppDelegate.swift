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
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        print("Up")
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
    @IBAction func pickerChange(sender: NSDatePicker) {
        dateClock.dateValue = sender.dateValue
    }
    @IBAction func clockChange(sender: NSDatePicker) {
        datePicker.dateValue = sender.dateValue
    }
    @IBAction func speedChange(sender: NSSlider) {
        speedBlurb.stringValue = "Wake Speed (\(speedOut.integerValue) minutes)"
    }
   
    
    @IBAction func setWakeBox(sender: NSButton) {
        //Create gregorian calendar and formatter
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        //let formatter: NSDateFormatter = NSDateFormatter()
        
        //extract hour/minute from ui
        let components: NSDateComponents = calendar.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute] , fromDate: datePicker.dateValue)
        //print(components)
        
        //calculate next_date in GMT
        var next_date: NSDate = calendar.nextDateAfterDate(NSDate(), matchingComponents: components, options: NSCalendarOptions.MatchNextTime)!
        
        //print(calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: next_date))

        //subtract wakeup speed from next_date, so time fires at beginning of increase in brightness
        next_date = next_date.dateByAddingTimeInterval(NSTimeInterval.init(-60*speedOut.integerValue))
        
        //set up NSTimeInterval and NSTimer
        let interval: NSTimeInterval = next_date.timeIntervalSinceNow
        print(interval)
        NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: Selector("timerFire:"), userInfo: nil, repeats: false)
        
        //Turn down brightness and brightness slider
        setBrightnessLevel(0.0)
        sliderOut.floatValue = 0.0 //Adjust brightness slider
    }
    
    @objc func timerFire(timer: NSTimer) {
        print("in timerFire")
        
        var iteration = 0
        let end = Int(self.speedOut.integerValue * 60)
        var currentLevel: Float = 0
        let step = Float(self.speedOut.integerValue * 60)
        
        let queue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, NSEC_PER_SEC / 10)
        dispatch_source_set_event_handler(timer) {
            currentLevel += step
            self.setBrightnessLevel(currentLevel)
            
            iteration += 1
            if iteration == end {
                dispatch_source_cancel(timer)
            }
        }
        
        dispatch_resume(timer)
        
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
    
    @IBAction func slider(sender: NSSlider) {
        //var x: Double
        let x: Float = sender.floatValue / 100
        print(x)
        setBrightnessLevel(x)
    }
    

    func setBrightnessLevel(level: Float) {
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

