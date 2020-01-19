//
//  MainScene.swift
//  ColorBallSwift
//
//  Created by Oscar Silva on 11/10/14.
//  Copyright (c) 2014 Oscar Silva. All rights reserved.
//

import SpriteKit
import CoreMotion
import AVFoundation

enum ColliderType: UInt32 {
    case SKCollisionCategoryEdge = 1
    case SKCollisionCategoryBola = 2
}

class Fase1Scene: SKScene, SKPhysicsContactDelegate, UIAccelerometerDelegate {
   
    var motionManager: CMMotionManager?
    
    var _back: SKLabelNode?
    var myLabel: SKLabelNode?
    var pointLabel: SKLabelNode?
    var cronometro: SKLabelNode?
    var blocoTemplate: SKSpriteNode?
    var bola: SKSpriteNode?
    var bola2:SKSpriteNode?
    var texturaBlocos:Array<Array<SKTexture>>?
    var texturaBolas:Array<Array<SKTexture>>?
    var parede:Dictionary<String, AnyObject>?
    var cores:Array<UIColor>?
    var pontos:Int?
    var currentMaxAccelX:CGFloat!
    var currentMaxAccelY:CGFloat!
    var changed:Bool?
    var _player:AVPlayer?
    var _videoNode:SKVideoNode?
    var fo:SKAction?
    var fi:SKAction?
    var blink:SKAction?
    var jogoAtivo: Bool?
    var config: NSDictionary?
    var colorTimer:NSTimer?
    var cronometerTimer:NSTimer?
    var regressiveCount:Double?
    var blocoOffset:CGFloat!
    var bgImageJogo:SKSpriteNode?
    
    override init(size: CGSize) {
        super.init(size: size)
        jogoAtivo = false
    }
    
    override func didMoveToView(view: SKView) {
        
        let larguraBloco:CGFloat = 40.0
        let alturaBloco:CGFloat = 40.0
        pontos = 0
        var qtColunas = 9
        var qtLinhas = 8
        
        let larguraTela = self.size.width
        
        let alturaTela = self.size.height - Utils.sharedInstance.navBarHeight - Utils.sharedInstance.tabBarHeight
        
        var qtHoriz = floor(Float((larguraTela  - larguraBloco) / larguraBloco))
        var qtVertical = floor(Float((alturaTela - alturaBloco) / alturaBloco))
        var inicioLargura = (CGFloat(qtHoriz) * larguraBloco) - (larguraTela - (CGFloat(qtHoriz) * larguraBloco))/2
        var inicioAltura = (CGFloat(qtVertical) * alturaBloco) - (alturaTela - (CGFloat(qtVertical) * alturaBloco))/2
        
        config = Utils.sharedInstance.lerConfiguracoes()
        
        var timerColor: NSTimeInterval = 0.0
        if config!.valueForKey("nivel") as NSObject == 0{
            timerColor = 15.0
        }
        
        if config!.valueForKey("nivel") as NSObject == 1{
            timerColor = 10.0
        }
        
        if config!.valueForKey("nivel") as NSObject == 2{
            timerColor = 5.0
        }
        
        colorTimer =  NSTimer.scheduledTimerWithTimeInterval(timerColor, target: self, selector:"alteraCorBloco:" , userInfo: nil, repeats: true)
        
        cronometerTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "reduzCronometro:", userInfo: nil, repeats: true)
        
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor.blackColor()
        
        var path = NSBundle.mainBundle().pathForResource("Ouroboros - Full Mix", ofType: "mp3")
        
        var fileURL = NSURL(fileURLWithPath: path!)
        _player = AVPlayer.playerWithURL(fileURL) as? AVPlayer
        _player?.seekToTime(kCMTimeZero)
        _videoNode = SKVideoNode(AVPlayer:_player)
        self.addChild(_videoNode!)
        
        regressiveCount = 60
        changed = true
        
        myLabel = SKLabelNode(fontNamed: "Chalkduster")
        myLabel?.text = "Start!!!"
        myLabel?.fontSize = 30
        myLabel?.position = CGPointMake(CGRectGetMidX(self.frame),
            CGRectGetMidY(self.frame) - 30)
        myLabel?.name = "StartLabel"
        self.addChild(myLabel!)
        
        cronometro = myLabel?.copy() as? SKLabelNode
        cronometro?.name = "cronometro"
        cronometro?.position = CGPointMake(CGRectGetMidX(self.frame),
            CGRectGetMidY(self.frame))
        cronometro?.text = "Pressione!!!"
        self.addChild(cronometro!)
        
        pointLabel = SKLabelNode(fontNamed: "Chalkduster")
        pointLabel?.text = String(format: "Pontos: %04d", pontos!)
        pointLabel?.fontSize = 30
        pointLabel?.position = CGPointMake(CGRectGetMidX(self.frame),
            CGRectGetMidY(self.frame) - 60)
        pointLabel?.name = "pointLabel"
        self.addChild(pointLabel!)
        
        cores = [UIColor.yellowColor(), UIColor.redColor(), UIColor.blueColor(), UIColor.greenColor(), UIColor.whiteColor()]
        
        var widthSprite = 1.0 / CGFloat(qtColunas)
        var heightSprite = 1.0 / CGFloat(qtLinhas)
        
        parede = [:]
        var ssBolas = SKTexture(imageNamed:"paint_sprite_sheet")
        texturaBolas = []
        var ssBlocos = SKTexture(imageNamed:"blocoBranco")
        var ssBgImage = SKTexture(imageNamed:"telafundo3")
    
        for linha in 0..<qtLinhas{
            var quadrosTexture:Array<SKTexture> = []
            for coluna in 0...qtColunas {
                var textura = SKTexture(rect: CGRectMake(CGFloat(coluna) * widthSprite,
                    CGFloat(linha) * heightSprite,
                    widthSprite,
                    heightSprite),
                    inTexture: ssBolas)
                quadrosTexture.append(textura)
            }
            texturaBolas!.append(quadrosTexture)
        }
        
        var rectBgImage = CGRectMake(0, 0, 351, 502)
        bgImageJogo = SKSpriteNode(texture: ssBgImage, size: rectBgImage.size)
        bgImageJogo!.name = "bgImageJogo"
        bgImageJogo!.position = CGPoint(x: larguraTela/2, y: (alturaTela/2)+24)
        //bgImageJogo!.physicsBody = SKPhysicsBody(rectangleOfSize:bgImageJogo!.size)
        self.addChild(bgImageJogo!)
        
        var rectBlock = CGRectMake(larguraTela/2, alturaTela/2, larguraBloco, alturaBloco)
        blocoTemplate = SKSpriteNode(texture: ssBlocos, size: rectBlock.size)
        blocoTemplate!.physicsBody = SKPhysicsBody(rectangleOfSize:blocoTemplate!.size)
        blocoTemplate!.physicsBody!.categoryBitMask = ColliderType.SKCollisionCategoryEdge.toRaw()
        blocoTemplate!.physicsBody!.restitution = 1
        blocoTemplate!.physicsBody!.affectedByGravity = false
        blocoTemplate!.physicsBody!.dynamic = false
        blocoTemplate!.colorBlendFactor = 1.0
        blocoTemplate!.name = "blocoTemplate"
        
        var labelBloco = SKLabelNode(fontNamed:"Chalkduster")
        labelBloco.text = "0";
        labelBloco.fontSize = 10;
        labelBloco.position = CGPointMake(0,0);
        labelBloco.name = String(format: "%@Label",blocoTemplate!.name!);
        labelBloco.fontColor = SKColor.whiteColor();
        blocoTemplate!.addChild(labelBloco)
        
        bola = SKSpriteNode(texture: texturaBolas![7][0], size: rectBlock.size)
        bola!.position = CGPointMake(larguraTela/2, alturaTela/2)
        bola!.physicsBody = SKPhysicsBody(circleOfRadius:bola!.size.width/4);
        bola!.name = "bola";
        bola!.physicsBody!.categoryBitMask = ColliderType.SKCollisionCategoryBola.toRaw()
        bola!.physicsBody!.collisionBitMask = ColliderType.SKCollisionCategoryEdge.toRaw()
        bola!.physicsBody!.contactTestBitMask = ColliderType.SKCollisionCategoryEdge.toRaw()
        bola!.physicsBody!.restitution = 0
        bola!.physicsBody!.linearDamping = 5
        bola!.physicsBody!.affectedByGravity = false
        bola!.physicsBody!.dynamic = false
        var i : Int = Int(arc4random_uniform(UInt32(cores!.count)))
        bola!.color = cores![i]
        bola!.colorBlendFactor = 0.5
        
        //Bloco offset
        blocoOffset = 5.5
        
        // Blocos superior
        for f in 1...Int(qtHoriz){
            var blocoP = blocoTemplate!.copy() as SKSpriteNode
            blocoP.position = CGPointMake( ((larguraBloco * CGFloat(f)) + blocoOffset), alturaTela)
            blocoP.name = "blocoS\(f)"
            var j : Int = Int(arc4random_uniform(UInt32(cores!.count)))
            blocoP.color = cores![j]
            var labelBloco : SKLabelNode = blocoP.childNodeWithName("\(blocoTemplate!.name!)Label") as SKLabelNode
            labelBloco.name = "\(blocoP.name!)Label"
            parede![blocoP.name!] = blocoP
        }
        
        // Blocos inferior
        for f in 1...Int(qtHoriz){
            var blocoP = blocoTemplate!.copy() as SKSpriteNode
            blocoP.position = CGPointMake((larguraBloco * CGFloat(f)) + blocoOffset, alturaTela - (CGFloat(qtVertical) * alturaBloco))
            blocoP.name = "blocoI\(f)"
            var j : Int = Int(arc4random_uniform(UInt32(cores!.count)))
            blocoP.color = cores![j]
            var labelBloco : SKLabelNode = blocoP.childNodeWithName("\(blocoTemplate!.name!)Label") as SKLabelNode
            labelBloco.name = "\(blocoP.name!)Label"
            parede![blocoP.name!] = blocoP
        }
        
        // Blocos Esquerda
        for f in 2...Int(qtVertical){
            var blocoP = blocoTemplate!.copy() as SKSpriteNode
            blocoP.position = CGPointMake(larguraBloco/2, alturaTela - (alturaBloco * CGFloat(f)) + alturaBloco)
            blocoP.zRotation = CGFloat(M_PI/270.0)
            blocoP.name = "blocoE\(f)"
            var j : Int = Int(arc4random_uniform(UInt32(cores!.count)))
            blocoP.color = cores![j]
            var labelBloco : SKLabelNode = blocoP.childNodeWithName("\(blocoTemplate!.name!)Label") as SKLabelNode
            labelBloco.name = "\(blocoP.name!)Label"
            parede![blocoP.name!] = blocoP
        }
        
        // Blocos Direita
        for f in 2...Int(qtVertical){
            var blocoP = blocoTemplate!.copy() as SKSpriteNode
            blocoP.position = CGPointMake(larguraTela - larguraBloco/2, alturaTela - (alturaBloco * CGFloat(f)) + alturaBloco)
            blocoP.zRotation = CGFloat(M_PI/180.0)
            blocoP.name = "blocoD\(f)"
            var j : Int = Int(arc4random_uniform(UInt32(cores!.count)))
            blocoP.color = cores![j]
            var labelBloco : SKLabelNode = blocoP.childNodeWithName("\(blocoTemplate!.name!)Label") as SKLabelNode
            labelBloco.name = "\(blocoP.name!)Label"
            parede![blocoP.name!] = blocoP
        }
        
        
        for p in parede!.values {
            self.addChild(p as SKNode)
        }
        
        fo = SKAction.fadeOutWithDuration(0.5)
        fi = SKAction.fadeInWithDuration(0.5)
        blink = SKAction.sequence([fo!,fi!,fo!,fi!,fo!,fi!,fo!])
        
        self.motionManager = CMMotionManager()
        self.motionManager!.accelerometerUpdateInterval = 0.2
        
        self.motionManager?.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {(data: CMAccelerometerData!, error: NSError!) in
            self.outputAccelertionData(data.acceleration);
            if(error != nil)
            {
                println("Acceleration Error: \(error!)");
            }
        })
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func outputAccelertionData(acceleration: CMAcceleration)
    {
        currentMaxAccelX = 0;
        currentMaxAccelY = 0;
    
        if(fabs(acceleration.x) > fabs(Double(currentMaxAccelX)))
        {
            currentMaxAccelX = CGFloat(acceleration.x);
        }
        if(fabs(acceleration.y) > fabs(Double(currentMaxAccelY)))
        {
            currentMaxAccelY = CGFloat(acceleration.y);
        }
    }

    func iniciaFases(location: CGPoint){
        if jogoAtivo == nil || jogoAtivo == false{
            myLabel!.runAction(blink)
            cronometro!.text = "\(regressiveCount!)"
            bola!.physicsBody!.dynamic = true;
            self.addChild(bola!)
            
            if (config!.valueForKey("musica") != nil) {
                _player!.volume = config!.valueForKey("musica") as Float
                _videoNode!.play()
            }
            jogoAtivo = true;
        }
        
        //Temporario para empurrar a bolinha pro touch
        if(jogoAtivo == true){
            var _posForce = CGPointMake(bola!.position.x, bola!.position.y)
            let deltaX = (bola!.position.x - location.x)
            let deltaY = (bola!.position.y - location.y)
            
            //Distancia
            let trajetoria = sqrt( pow(deltaX, 2.0) + pow(deltaY, 2.0) )
            
            
            println("\(trajetoria)")
            
            bola!.physicsBody!.applyImpulse(CGVectorMake(deltaX, deltaY), atPoint: _posForce)
            
            
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if (jogoAtivo == nil || jogoAtivo == false) && myLabel!.text != "Start!!!" {
            return
        }
        for touch in touches{
            var location = touch.locationInNode(self)
            
            self.iniciaFases( location )
        }
    }
    
    func fimFase(){
        if jogoAtivo == nil || jogoAtivo == false {
            return
        }
        _player?.pause()
        _videoNode?.removeFromParent()
        var recordes:NSMutableArray = NSMutableArray(array: Utils.sharedInstance.lerRecordes())
        var recorde : NSMutableDictionary = NSMutableDictionary()
        var bAchou = false
        var medalhas = pontos > 0 ? pontos! / 50 : 0
        if medalhas > 5 {
            medalhas = 5
        } else if medalhas < 0 {
            medalhas = 0
        }
        for i in 0..<recordes.count{
            if !bAchou{
                if(recordes.objectAtIndex(i).valueForKey("jogador") as String == config!.valueForKey("nome") as String){
                    recorde.setValue(config!.valueForKey("nome"), forKey: "jogador")
                    recorde.setValue(pontos, forKey: "pontos")
                    recorde.setValue(1, forKey: "fase")
                    recorde.setValue(medalhas, forKey: "medalhas")
                    recordes.setObject(recorde, atIndexedSubscript: i)
                    bAchou = true
                }
            } else {
                break
            }
        }
        if !bAchou {
            recorde.setValue(config!.valueForKey("nome") , forKey: "jogador")
            recorde.setValue(pontos, forKey: "pontos")
            recorde.setValue(1, forKey: "fase")
            recorde.setValue(medalhas, forKey: "medalhas")
            recordes.addObject(recorde)
        }
        jogoAtivo = false
        Utils.sharedInstance.gravarRecordes(recordes)
    }
    
    override func update(currentTime: NSTimeInterval) {
        var _posForce = CGPointMake(bola!.position.x, bola!.position.y)
        if currentMaxAccelX == nil {
            currentMaxAccelX = 0
        }
        if currentMaxAccelY == nil {
            currentMaxAccelY = 0
        }

        bola!.physicsBody!.applyImpulse(CGVectorMake(currentMaxAccelX, currentMaxAccelY), atPoint: _posForce)
        if jogoAtivo != nil && jogoAtivo == true {
            pointLabel?.text = String(format: "Pontos: %04d", pontos!)
        }
        
        if regressiveCount <= 0.0 {
            _player?.pause()
            _videoNode?.removeFromParent()
            colorTimer?.invalidate()
            cronometerTimer?.invalidate()
            
            //inicio - pode ser substituido por chamar fase 2
            myLabel!.text = "Fim de jogo"
            myLabel?.runAction(fi)
            fimFase()
            //fim - pode ser substituido por chamar fase 2
        }
        /*
        else
            chamar cena de perdeu
        */
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody?
        var secondBody: SKPhysicsBody?
        
        if jogoAtivo == nil {
            return
        } else if jogoAtivo == false{
            return
        }
    
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        var bloco: SKSpriteNode = parede![firstBody!.node!.name!] as SKSpriteNode
        if bola!.color == bloco.color{
            pontos = 0;
            if config!.valueForKey("som") as Int > 0 {
                var somColisao = SKAction.playSoundFileNamed("singlehandclap.wav", waitForCompletion: false)
                bloco.runAction(somColisao)
            }
            for nameBloco in parede!.keys{
                var b : SKSpriteNode = parede![nameBloco] as SKSpriteNode
                var label : SKLabelNode = b.childNodeWithName("\(b.name!)Label") as SKLabelNode
                if b.color == bloco.color {
                    label.text = "\(label.text.toInt()! + 1)"
                }
                pontos = pontos! + label.text.toInt()!
            }
            
            var i : Int = Int(arc4random_uniform(UInt32(cores!.count)))
            bola!.color = cores![i]
        }
    }
    
    func alteraCorBloco(sender: NSObject){
        if jogoAtivo == nil {
            return
        } else if jogoAtivo == false{
            return
        }
        for nameBloco in parede!.keys{
            var i : Int = Int(arc4random_uniform(UInt32(cores!.count)))
            var changeColor = SKAction.colorizeWithColor(cores![i], colorBlendFactor: 0.5, duration: 0.01)
            var b = parede![nameBloco] as SKSpriteNode
            b.runAction(changeColor)
        }
    }
    
    func reduzCronometro(sender: NSObject){
        if jogoAtivo == nil {
            return
        } else if jogoAtivo == false{
            return
        }
        if jogoAtivo != nil {
            regressiveCount = regressiveCount! - 1
            cronometro?.text = "\(regressiveCount!)"
        }
    }
}
