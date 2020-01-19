//
//  GameViewController.swift
//  ColorBallSwift
//
//  Created by Oscar Silva on 11/10/14.
//  Copyright (c) 2014 Oscar Silva. All rights reserved.
//

import SpriteKit

class GameViewController: UIViewController {

    var scene : Fase1Scene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let view = self.view as SKView
        view.showsFPS = true
       
        
        scene = Fase1Scene(size: self.view.bounds.size)
        if self.navigationController != nil {
            Utils.sharedInstance.navBarHeight = self.navigationController!.navigationBar.bounds.height
            Utils.sharedInstance.navBarWidth = self.navigationController!.navigationBar.bounds.width
        } else {
            Utils.sharedInstance.navBarHeight = 0
            Utils.sharedInstance.navBarWidth = 0
        }
        
        if self.tabBarController != nil {
            Utils.sharedInstance.tabBarHeight = self.tabBarController!.tabBar.bounds.height
            Utils.sharedInstance.tabBarWidth = self.tabBarController!.tabBar.bounds.width
        } else {
            Utils.sharedInstance.tabBarHeight = 0
            Utils.sharedInstance.tabBarWidth = 0
        }
        view.presentScene(scene)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func viewDidDisappear(animated: Bool) {
        scene.fimFase()
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
