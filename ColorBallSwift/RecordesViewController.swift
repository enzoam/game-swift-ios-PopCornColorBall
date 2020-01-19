//
//  RecordesViewController.swift
//  ColorBallSwift
//
//  Created by Oscar Silva on 04/10/14.
//  Copyright (c) 2014 Oscar Silva. All rights reserved.
//

import UIKit

class RecordesViewController: UIViewController {

    @IBOutlet weak var recordTableView: UITableView!
    
    var recordes: Array<AnyObject> = []
    
    var tableDelegate : TableRecordsDelegate?
    var tableDataSource : TableRecordsDatasource?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableDelegate = TableRecordsDelegate()
        tableDataSource = TableRecordsDatasource(itens: recordes)

        self.recordTableView.delegate = tableDelegate
        self.recordTableView.dataSource = tableDataSource
    }
    
    override func viewWillAppear(animated: Bool) {
        tableDataSource?.itens = Utils.sharedInstance.lerRecordes();
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        recordes = Utils.sharedInstance.lerRecordes()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

}

