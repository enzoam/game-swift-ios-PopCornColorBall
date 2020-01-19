//
//  Utils.swift
//  ColorBallSwift
//
//  Created by Oscar Silva on 04/10/14.
//  Copyright (c) 2014 Oscar Silva. All rights reserved.
//

import UIKit

class Utils: NSObject {

    var tabBarHeight: CGFloat = 0
    var tabBarWidth: CGFloat = 0
    var navBarHeight: CGFloat = 0
    var navBarWidth: CGFloat = 0
    
    class var sharedInstance: Utils {
    
        struct Static {
            static let instance: Utils = Utils()
        }

        return Static.instance
    }
    
    func obterDocumentDirectory() -> String{
        var documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        return documentsPath
    }

    func criarArquivos(fileName: String, typeFile: String) -> String{
        var fileManager = NSFileManager.defaultManager()
        var file = "\(fileName).\(typeFile)"
        let path = obterDocumentDirectory().stringByAppendingPathComponent(file)
        if (!(fileManager.fileExistsAtPath(path)))
        {
            var bundle : NSString = NSBundle.mainBundle().pathForResource(fileName, ofType: typeFile)!
            fileManager.copyItemAtPath(bundle, toPath: path, error:nil)
        }
        return path
    }
    
    func lerRecordes() -> NSArray{
        var pathDoc = criarArquivos("Recordes", typeFile: "plist")
        println("\(pathDoc)")
        var recordes = NSArray(contentsOfFile: pathDoc)
        return recordes
    }
    
    func gravarRecordes(dados: NSArray ){
        var pathDoc = criarArquivos("Recordes", typeFile: "plist")
        println("\(pathDoc)")
        dados.writeToFile(pathDoc, atomically: false)
    }
    
    func lerConfiguracoes() -> NSDictionary{
        var pathDoc = criarArquivos("Config", typeFile: "plist")
        println("\(pathDoc)")
        var confs = NSDictionary(contentsOfFile: pathDoc)
        return confs
    }
    
    func gravarConfiguracoes(dados: NSDictionary ){
        var pathDoc = criarArquivos("Config", typeFile: "plist")
        println("\(pathDoc)")        
        dados.writeToFile(pathDoc, atomically: false)
    }
}
