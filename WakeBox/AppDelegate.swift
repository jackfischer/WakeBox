//
//  AppDelegate.swift
//  WakeBox
//
//  Created by Jack Fischer on 11/14/15.
//  Copyright © 2015 trump6. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet var sliderOut: NSSlider!
    @IBOutlet var datePicker: NSDatePicker!
    @IBOutlet var dateClock: NSDatePicker!
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
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
   
    /*
    func getHourFromDatePicker(datePicker:UIDatePicker) -> String
    {
        let date = datePicker.date
        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute] , fromDate: date)
        
        return "\(components.hour):\(components.minute)"
    }
*/
    
    @IBAction func setWakeBox(sender: NSButton) {
        //Create gregorian calendar and formatter
        let calendar: NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        //let formatter: NSDateFormatter = NSDateFormatter()
        
        //extract hour/minute from ui
        let components: NSDateComponents = calendar.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute] , fromDate: datePicker.dateValue)
        print(components)
        
        //calculate next_date in GMT
        let next_date: NSDate = calendar.nextDateAfterDate(NSDate(), matchingComponents: components, options: NSCalendarOptions.MatchNextTime)!
        
        /*print date
        print(calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: next_date))
        */
        let interval: NSTimeInterval = next_date.timeIntervalSinceNow
        print(interval)
    }
    
    @IBAction func slider(sender: NSSlider) {
        //var x: Double
        var x: Float
        x = sender.floatValue / 100
        print(x)
        setBrightnessLevel(x)
        
        
    }
    
    func setBrightnessLevel(level: Float) {
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

