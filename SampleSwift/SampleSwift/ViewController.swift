//
//  ViewController.swift
//  SampleSwift
//
//  Created by Subhransu Behera on 16/10/16.
//  Copyright © 2016 Singapore Power. All rights reserved.
//

import UIKit
import CocoaMQTT
import Charts

class ViewController: UIViewController {
    var ll1: ChartLimitLine?
    var ll2: ChartLimitLine?
    
    @IBOutlet weak var statusLabel: UILabel!
    
    
    @IBOutlet weak var lineChartView: LineChartView!
    var values: [ChartDataEntry] = []
    var count = 1
    var statusFlag = true

    var mqtt:CocoaMQTT?

    @IBAction func buttonTapped(_ sender: AnyObject) {
        mqtt?.subscribe("hello")
        
        toggleLabelText()
        
        SPPlatformAuthNetworkHelper().GET(urlString: "http://192.168.123.200:8090", successHandler: { (response) in
                print(response)
            }) { (error) in
                print(error)
        }
    }
    
    func toggleLabelText() {
        if statusFlag {
            statusLabel.text = "Relay is Up"
            statusLabel.backgroundColor = UIColor.yellow
            statusFlag = false
        } else {
            statusLabel.text = "Red is Up"
            statusLabel.backgroundColor = UIColor.red

            statusFlag = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mqtt = CocoaMQTT(clientId: "hello", host: "192.168.123.200", port: 1883)
        mqtt?.keepAlive = 90
        mqtt?.username = "hello"
        mqtt?.password = "test"
        mqtt?.delegate = self
        mqtt?.connect()
        
        lineChartView.delegate = self
        lineChartView.chartDescription?.text = ""
        lineChartView.dragEnabled = false
        lineChartView.pinchZoomEnabled = false
        lineChartView.setScaleEnabled(false)
        lineChartView.drawGridBackgroundEnabled = false
        lineChartView.rightAxis.enabled = false
        
        values.append(ChartDataEntry(x: Double(count), y: 0.0))
        count = count + 1
        setDataCount()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: CocoaMQTTDelegate {
    
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("connected")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("connect acknowledged")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        
        if (((message.string?.components(separatedBy: "-")) != nil) && (message.string?.components(separatedBy: "-").count)! > 1) {
            let humidity = Double((message.string?.components(separatedBy: "-")[1])!)!
            values.append(ChartDataEntry(x: Double(count), y: humidity))
            count = count + 1
        
            if values.count == 10 {
                values.remove(at: 0)
            }

            setDataCount()
            lineChartView.setNeedsDisplay()
        } else {
            toggleLabelText()
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("did ping")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
    }
}

extension ViewController: ChartViewDelegate {
    func setDataCount() {
        var set1: LineChartDataSet?
        

            set1 = LineChartDataSet(values: values, label: "Humidity")
            set1?.setColor(UIColor.purple)
            set1?.setCircleColor(UIColor.red)
            set1?.lineWidth = 3.0
            set1?.circleRadius = 6.0
            set1?.drawCircleHoleEnabled = true
            set1?.valueFont = UIFont.systemFont(ofSize: 9.0)
            
            let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor, ChartColorTemplates.colorFromString("#ffff0000").cgColor]
            
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)
            set1?.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
            
            set1?.fillAlpha = 0.0
            set1?.drawFilledEnabled = true
            
            var dataSets: [LineChartDataSet] = []
            dataSets.append(set1!)
            
            let data = LineChartData(dataSets: dataSets)
            lineChartView.data = data
    }
}

