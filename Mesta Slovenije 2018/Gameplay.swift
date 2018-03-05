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
        var lat : Double
        var lon : Double // TODO: Switch to lat, lon
        var name : String // Location
        var score : Double
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
    var distanceLabel: SKLabelNode? = nil
    
    // This method is called when the scene gets put into the view
    override func didMove(to view: SKView) {

        let path:String = Bundle.main.path(forResource: "testFile", ofType: "txt")!
        let text = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
        let lines: [String] = (text?.components(separatedBy: "\n"))!
        var allQuestions:[Question] = []
        for l in lines{
            print(l)
            let components: [String] = l.components(separatedBy: ",")
            if(components.count >= 5){
                allQuestions.append(Question(lat: Double(components[3].trimmingCharacters(in: .whitespacesAndNewlines))!,
                                             lon: Double(components[4].trimmingCharacters(in: .whitespacesAndNewlines))!,
                                             name: components[1], score:0))
            }
        }
        
        // Find all the componentes
        gameUI = self.childNode(withName: "//GameUI")
        introUI = self.childNode(withName: "//IntroUI")
        redNode = self.childNode(withName: "//AnswerNode")
        greenNode = self.childNode(withName: "//CorrectNode")
        distanceLabel = self.childNode(withName: "//DistanceLabel") as! SKLabelNode

        // Set up the initial variables
        
        state = State.INTRO
        
        gameUI?.isHidden = true
        introUI?.isHidden = false
        
        // Fill stages
        for i in 0...(STAGE_COUNT-1) {
            stages.append(Stage(name: "Mesta \(i)", questions: []))
            for j in 0...(QUESTIONS_PER_STAGE-1){
                //stages[i].questions.append(Question(x: Double(j * 100), y: Double(j * 50),name: "Lokacija \(i) , \(j)", score: 0))
                stages[i].questions.append(allQuestions[j])
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
        
        greenNode?.isHidden = true
        redNode?.isHidden = true
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
            
            var currentQuestion: Question = getQuestion(sIndex: stageNumber, qIndex: questionNumber)
            
            //TODO Calculate score
            let answer:Coordinate = pixelsToCoordinate(x: Double(pos.x), y: Double(pos.y))
            let correct:Coordinate = Coordinate(lat: currentQuestion.lat, lon: currentQuestion.lon)
            let score:Double = distanceInKilometers(answer, correct) // TODO x any y might be changed to lat and lon, then don't convert to Coordinate
            
            distanceLabel?.text = String(score).substring(to :String(score).index(String(score).startIndex, offsetBy: 5)) + " km"
            
            currentQuestion.score = score
            
            // Show answer and correct answer
            let correctPos:(Double, Double) = coordinateToPixels(coordinate: Coordinate(lat: currentQuestion.lat, lon: currentQuestion.lon))
            print("x \(correctPos.0)")
            print("y \(correctPos.1)")
            greenNode!.position = CGPoint.init(x: CGFloat(correctPos.0), y: CGFloat(correctPos.1))
            greenNode!.zPosition = 10
            greenNode?.isHidden = false
            
            // Get clicked position
            redNode!.position = pos
            redNode!.zPosition = 10
            redNode?.isHidden = false
            
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
    
    
    // Functions for score calculation
    
    struct Coordinate {
        var lat: Double
        var lon: Double
    }
    
    static let fixed1: Coordinate = Coordinate(lat: 45.6643299, lon: 14.5737826)
    static let fixed2: Coordinate = Coordinate(lat: 46.6561378, lon: 16.0379563)

    func pixelsToCoordinate(x: Double, y: Double) -> Coordinate{
        let sX:Double = (Gameplay.fixed2.lon - Gameplay.fixed1.lon) / Double(1245.0 - 685.7);
        let sY:Double = (Gameplay.fixed2.lat - Gameplay.fixed1.lat) / Double(724.6 - 170.9);
        
        let n:Double = (Gameplay.fixed1.lat + sY * (y - 170.9))
        let e:Double = (Gameplay.fixed1.lon + sX * (x - 685.7))
        //@45.3950057
        
        return Coordinate(lat: n, lon: e)
    }
    
    func coordinateToPixels(coordinate: Coordinate) -> (x:Double, y:Double){
        print(coordinate.lat)
        print(coordinate.lon)
        let sX:Double = (1245.0 - 685.7) / (Gameplay.fixed2.lon - Gameplay.fixed1.lon);
        let x:Double = (685.7 + sX * (coordinate.lon - Gameplay.fixed1.lon));
        
        let sY:Double = (724.6 - 170.9) / (Gameplay.fixed2.lat - Gameplay.fixed1.lat);
        let y:Double = (170.9 + sY * (coordinate.lat - Gameplay.fixed1.lat));
        
        return (x, y)
    }
    
    /**
     * Calculates the real world distance in kilometres between two coordinate
     * points in the usual GPS style
     */
    func distanceInKilometers(_ point1: Coordinate, _ point2: Coordinate) -> Double{
        let lat1: Double = point1.lat * 3.1415926 / 180;
        let lon1: Double = point1.lon * 3.1415926 / 180;
    
        let lat2: Double = point2.lat * 3.1415926 / 180;
        let lon2: Double = point2.lon * 3.1415926 / 180;
        
        let deltaLat: Double = (lat2 - lat1) ;
        let deltaLon: Double = (lon2 - lon1);
    
        let R: Int = 6371000; // metres
    
        let a: Double = sin(deltaLat / 2) * sin(deltaLat / 2) + cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2)
        let c: Double = 2 * atan2(sqrt(a), sqrt(1 - a))
    
        let d: Double = Double(R) * c
    
        return d / 1000.0
    }
}
