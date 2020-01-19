//
//  ConfiguracoesViewController.swift
//  ColorBallSwift
//
//  Created by Oscar Silva on 04/10/14.
//  Copyright (c) 2014 Oscar Silva. All rights reserved.
//

import UIKit

class ConfiguracoesViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var tfNome: UITextField?
    @IBOutlet weak var slMusica: UISlider?
    @IBOutlet weak var slSons: UISlider?
    @IBOutlet weak var sgSegmented: UISegmentedControl?
    
    var configuracoes:NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slMusica?.maximumValue = 100
        slSons?.maximumValue = 100
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        configuracoes = Utils.sharedInstance.lerConfiguracoes()
        tfNome?.text = configuracoes.valueForKey("nome") as String
        slMusica?.value = configuracoes.valueForKey("musica") as Float
        slSons?.value = configuracoes.valueForKey("som") as Float
        sgSegmented?.selectedSegmentIndex = configuracoes.valueForKey("nivel") as Int
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(animated: Bool) {
        var dados :Dictionary<String, AnyObject> = [:]
        
        dados["nome"] = tfNome?.text
        dados["som"] = slSons?.value
        dados["musica"] = slMusica?.value
        dados["nivel"] = sgSegmented?.selectedSegmentIndex

        Utils.sharedInstance.gravarConfiguracoes(dados)        
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        var touch : UITouch = event.allTouches()?.anyObject() as UITouch
        if tfNome!.isFirstResponder() && touch.view != tfNome{
                tfNome?.resignFirstResponder()
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
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
