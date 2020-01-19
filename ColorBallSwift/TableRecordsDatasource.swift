//
//  TableRecordsDatasource.swift
//  ColorBallSwift
//
//  Created by Oscar Silva on 09/10/14.
//  Copyright (c) 2014 Oscar Silva. All rights reserved.
//

import UIKit

class TableRecordsDatasource: NSObject, UITableViewDataSource {
    
    var itens: Array<AnyObject> = []
    
    init(itens: Array<AnyObject>) {
        self.itens = itens
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itens.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("RecordDetail") as RowRecordViewCell
        
        var reg = itens[indexPath.row] as Dictionary<String, AnyObject>
        
        var jogador: AnyObject? = reg["jogador"]
        var pontos: AnyObject? = reg["pontos"]
        var fase: AnyObject? = reg["fase"]
        var medalhas: AnyObject? = reg["medalhas"]
        
        cell.lbNome.text = jogador as? String
        cell.lbFase.text = "P:\(pontos as Int) /F:\(fase as Int)"
        
        for var i = 0; i < medalhas as Int; ++i {
            if i == 0 {
                cell.imgMedalha1.image = UIImage(named: "medal-24")
            }
            if i == 1 {
                cell.imgMedalha2.image = UIImage(named: "medal-24")
            }
            if i == 2 {
                cell.imgMedalha3.image = UIImage(named: "medal-24")
            }
            if i == 3 {
                cell.imgMedalha4.image = UIImage(named: "medal-24")
            }
            if i == 4 {
                cell.imgMedalha5.image = UIImage(named: "medal-24")
            }
        }
        
        return cell
    }
}
