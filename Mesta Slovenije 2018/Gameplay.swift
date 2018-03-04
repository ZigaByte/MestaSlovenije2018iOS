//
//  GameScene.swift
//  Mesta Slovenije 2018
//
//  Created by Klemen Podpadec on 03/03/2018.
//
//

import SpriteKit
import GameplayKit
import Foundation

class Gameplay: SKScene {
    
    enum State {
        case INTRO
        case QUESTION
        case ANSWER
        case STAGE_RESULT
        case GAME_RESULTS
    }
    
    struct Question {
        var x : Float // TODO: Switch to lat, lon
        var y : Float
        var name : String // Location
        var score : Float
    }
    
    struct Stage {
        var name:String
        var questions:[Question]
    }
    /*
    var questions:[Question] = [Question(x:100, y:200, name: "Test 1", score: 0),
                                 Question(x:300, y:300, name: "Test 2", score: 0),
                                 Question(x:300, y:700, name: "Test 3", score: 0)]
     */
    
    // Some constants
    let QUESTIONS_PER_STAGE: Int = 3
    let STAGE_COUNT = 2
    
    var state:State = State.INTRO
    var stages:[Stage] = []
    var questionNumber:Int = 0 // The current question index, goes from 0 ... QUESTIONS_PER_STAGE-1
    var stageNumber:Int = 0 // The current stage index, goes from 0 ... STAGE_COUNT-1
    
    var gameUI: SKNode? = nil
    var introUI: SKNode? = nil
    var greenNode: SKNode? = nil
    var redNode: SKNode? = nil
    
    // This method is called when the scene gets put into the view
    override func didMove(to view: SKView) {
        // Find all the componentes
        gameUI = self.childNode(withName: "//GameUI")
        introUI = self.childNode(withName: "//IntroUI")
        greenNode = self.childNode(withName: "//AnswerNode")
        redNode = self.childNode(withName: "//CorrectNode")


        
        // Set up the initial variables
        
        state = State.INTRO
        
        gameUI?.isHidden = true
        introUI?.isHidden = false
        
        // Fill stages
        for i in 0...(STAGE_COUNT-1) {
            stages.append(Stage(name: "Mesta \(i)", questions: []))
            for j in 0...(QUESTIONS_PER_STAGE-1){
                stages[i].questions.append(Question(x: Float(j * 100), y: Float(j * 50),
                                                    name: "Lokacija \(i) , \(j)", score: 0))
            }
        }
    }
    
    func getQuestion (sIndex: Int, qIndex: Int) -> Question{
        return stages[stageNumber].questions[questionNumber]
    }
    
    func showQuestion (sIndex: Int, qIndex: Int){
        let question: Question = getQuestion(sIndex: sIndex, qIndex: qIndex)
        let questionLabel:SKLabelNode? = self.childNode(withName: "//QuestionLabel") as! SKLabelNode?
        questionLabel!.text = question.name
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        switch state {
        case .INTRO:
            print("Intro")
            
            // Set up UI for game
            gameUI?.isHidden = false
            introUI?.isHidden = true
            
            // Show first question
            questionNumber = 0
            showQuestion(sIndex: stageNumber, qIndex: questionNumber)
            
            state = State.QUESTION
            
            
        case .QUESTION:
            print("Question")
            
            let currentQuestion: Question = getQuestion(sIndex: stageNumber, qIndex: questionNumber)
            
            // Show answer and correct answer
            greenNode!.position = pos
            greenNode!.zPosition = 10
            greenNode?.isHidden = false
            
            redNode!.position = CGPoint.init(x: CGFloat(currentQuestion.x), y: CGFloat(currentQuestion.y))
            redNode!.zPosition = 10
            redNode?.isHidden = false
            
            
            //TODO Calculate score
            
            state = State.ANSWER
            
            
        case .ANSWER:
            print("Answer")
            
            questionNumber += 1
            
            // Move to next question
            if(questionNumber < QUESTIONS_PER_STAGE){
                redNode?.isHidden = true
                greenNode?.isHidden = true
                
                showQuestion(sIndex: stageNumber, qIndex: questionNumber)
                
                state = State.QUESTION
            }
            // Or to stage results
            else{
                state = State.STAGE_RESULT
            }
            
            
            
        case .STAGE_RESULT:
            print("Stage Results")
            
            // Move to next stage
            stageNumber += 1
            
            if(stageNumber < STAGE_COUNT){
                // TODO Hide stuff maybe
                
                state = State.INTRO
            }
                // Or to game results
            else{
                state = State.GAME_RESULTS
            }
            
            
            
        case .GAME_RESULTS:
            print("Game Results")
            
            // Back to menu if back button is pressed
            if let scene = SKScene(fileNamed: "MainMenu") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                
                // Present the scene
                self.view!.presentScene(scene)
            }

            
        }
        
        
        /*
        
        let questionLabel:SKLabelNode? = self.childNode(withName: "QuestionLabel") as! SKLabelNode?
        questionLabel!.text = currentQuestion!.name
        
        // Next question
        currentQuestion = questions[questionIndex % questions.count]
        questionIndex += 1
        */
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
