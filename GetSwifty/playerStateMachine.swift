//
//  playerStateMachine.swift
//  GetSwifty
//
//  Created by David Wang on 2020-11-12.
//  Copyright © 2020 GetSwifty. All rights reserved.
//

import Foundation
import GameplayKit 

fileprivate let characterAnimationKey = "Sprite Animation"

class PlayerState: GKState {
    unowned var playerNode: SKNode
    
    init(playerNode: SKNode) {
        self.playerNode = playerNode
        super.init()
    }
}

class JumpingState: PlayerState {
    var hasFinishedJumping: Bool = false
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        if stateClass is StunnedState.Type {return true}
        
        
        if hasFinishedJumping && stateClass is LandingState.Type {
            return true
        }
        return false
    }
    
    let textures: Array<SKTexture> = (0..<2).map({ return "rick_Jump/rick_jump_\($0)"}).map(SKTexture.init)
    lazy var action = { SKAction.animate(with: textures, timePerFrame: 0.1)}()
    
    override func didEnter(from previousState: GKState?) {
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)
        
        hasFinishedJumping = false
        playerNode.run(.applyForce(CGVector(dx: 0, dy: 100), duration: 0.1))
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (timer) in self.hasFinishedJumping = true
        }
    }
}

class LandingState: PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        switch stateClass {
        case is LandingState.Type, is JumpingState.Type:
            return false
        default:
            return true
        }
    }
    override func didEnter(from previousState: GKState?) {
    
        stateMachine?.enter(IdleState.self)
    }
}

class IdleState: PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        switch stateClass {
        case is LandingState.Type, is IdleState.Type:
            return false
        default:
            return true
        }
    }
    
    let textures: Array<SKTexture> = (0..<5).map({ return "rick_Idle/rick_idle_\($0)"}).map(SKTexture.init)
    lazy var action = { SKAction.repeatForever(.animate(with: textures, timePerFrame: 0.1))}()
    override func didEnter(from previousState: GKState?) {
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)
    }
}

class WalkingState: PlayerState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        
        switch stateClass {
        case is LandingState.Type, is WalkingState.Type:
            return false
        default:
            return true
        }
    }
    
    let textures: Array<SKTexture> = (0..<9).map({ return "rick_Run/rick_run_\($0)"}).map(SKTexture.init)
    lazy var action = { SKAction.repeatForever(.animate(with: textures, timePerFrame: 0.1))}()
    override func didEnter(from previousState: GKState?) {
        playerNode.removeAction(forKey: characterAnimationKey)
        playerNode.run(action, withKey: characterAnimationKey)
    }
}

class StunnedState: PlayerState {
    var isStunned : Bool = false
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if isStunned { return false }
        
        switch stateClass {
            
        case is IdleState.Type:
            return true
        default:
            return false
        }
    }
    
    let action = SKAction.repeat(.sequence([
        .fadeAlpha(to: 0.5, duration: 0.01),
        .wait(forDuration: 0.25),
        .fadeAlpha(to: 1.0, duration: 0.01),
        .wait(forDuration: 0.25),
    ]), count: 5)
    
    override func didEnter(from previousState: GKState?) {
        isStunned = true
        playerNode.run(action)
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false){(timer) in
            self.isStunned = false
            self.stateMachine?.enter(IdleState.self)
        }
    }
    
}

class ShootingState: PlayerState {    
    var isShooting : Bool = false
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if isShooting { return false }
        
        switch stateClass {
            
        case is IdleState.Type:
            return true
        default:
            return false
        }
    }
    
    let textures: Array<SKTexture> = (0..<4).map({ return "rick_Shoot/rick_shoot_\($0)"}).map(SKTexture.init)
    lazy var action = { SKAction.animate(with: textures, timePerFrame: 0.1)}()
    
    override func didEnter(from previousState: GKState?) {
        isShooting = true
        playerNode.run(action)
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false){(timer) in
            self.isShooting = false
            self.stateMachine?.enter(IdleState.self)
        }
    }
    
    
}
