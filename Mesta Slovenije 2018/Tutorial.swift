//
//  GameScene.swift
//  Mesta Slovenije 2018
//
//  Created by Klemen Podpadec on 03/03/2018.
//
//

import SpriteKit
import GameplayKit

class Tutorial: SKScene {
    
    enum State {
        case STATE1
        case STATE2
        case STATE3
    }
    
    struct Question {
        var lat : Double
        var lon : Double
        var xAnswer: Double
        var yAnswer: Double
        var name : String // Location
        var score : Double
    }
    
    var state:State = State.STATE1
    
    var score: Double = 0
    var goal: Double = 0
    
    var greenNode: SKNode? = nil
    var redNode: SKNode? = nil
    var distanceLabel: SKLabelNode? = nil
    var scoreUI: SKNode? = nil
    var goalUI: SKNode? = nil
    var stage2: SKNode? = nil
    var stage3: SKNode? = nil
    var scoreLabel: SKLabelNode? = nil
    var goalLabel: SKLabelNode? = nil
    var questionLabel: SKLabelNode? = nil
    
    var linesNode: SKNode? = nil
    
    // This method is called when the scene gets put into the view
    override func didMove(to view: SKView) {
        // Find all the componentes
        redNode = self.childNode(withName: "//AnswerNode")
        greenNode = self.childNode(withName: "//CorrectNode")
        scoreUI = self.childNode(withName: "//Score")
        goalUI = self.childNode(withName: "//Goal")
        stage2 = self.childNode(withName: "//Stage2")
        stage3 = self.childNode(withName: "//Stage3")
        distanceLabel = self.childNode(withName: "//DistanceLabel") as? SKLabelNode
        scoreLabel = self.childNode(withName: "//ScoreLabel") as? SKLabelNode
        goalLabel = self.childNode(withName: "//GoalLabel") as? SKLabelNode
        questionLabel = self.childNode(withName: "//QuestionLabel") as! SKLabelNode?

        linesNode = self.childNode(withName: "LinesNode")
        
        stage2?.isHidden = true
        stage3?.isHidden = true
    }
    
    func setMarkerPositions(question: Question, red: SKNode, green: SKNode){
        let correctPos:(Double, Double) = coordinateToPixels(coordinate: Coordinate(lat: question.lat, lon: question.lon))
        
        // Show all results
        let line_path:CGMutablePath = CGMutablePath()
        line_path.move(to: CGPoint.init(x: CGFloat(correctPos.0), y: CGFloat(correctPos.1)))
        line_path.addLine(to: CGPoint.init(x: question.xAnswer, y: question.yAnswer))
        
        let shape = SKShapeNode()
        shape.name = "Line"
        shape.path = line_path
        shape.lineWidth = 2
        shape.zPosition = 8
        linesNode!.addChild(shape)
        
        let answerY = correctPos.1 + 25
        let correctY = question.yAnswer + 25
        
        green.position = CGPoint.init(x: CGFloat(correctPos.0) - 3, y: CGFloat(correctPos.1 + 30))
        green.zPosition = answerY > correctY ? 10 : 11
        green.isHidden = false
        
        (red.childNode(withName: "DistanceLabel") as! SKLabelNode).text = "\(Int(question.score)) km"
        
        // Get clicked position
        red.position = CGPoint.init(x: question.xAnswer - 3, y: question.yAnswer + 30)
        red.zPosition = answerY > correctY ? 11 : 10
        red.isHidden = false
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
        switch state {
        case State.STATE1:
            
            var question: Question = Question(lat: 46.55465, lon: 15.645882, xAnswer: 0, yAnswer: 0, name: "Maribor", score:0)
            
            let answer:Coordinate = pixelsToCoordinate(x: Double(pos.x), y: Double(pos.y))
            let correct:Coordinate = Coordinate(lat: question.lat, lon: question.lon)
            let score:Double = distanceInKilometers(answer, correct)
            self.score += Double(Int(score))
            
            question.xAnswer = Double(pos.x)
            question.yAnswer = Double(pos.y)
            question.score = score
            
            scoreLabel?.text = "\(Int(score)) km"
            
            setMarkerPositions(question: question, red: redNode!, green: greenNode!)
            
            stage2?.isHidden = false
            state = State.STATE2
        case State.STATE2:
            stage3?.isHidden = false
            state = State.STATE3
        case State.STATE3:
            // Back to menu if back button is pressed
            if let scene = SKScene(fileNamed: "MainMenu") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                
                // Present the scene
                self.view!.presentScene(scene)
            }

        }
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
