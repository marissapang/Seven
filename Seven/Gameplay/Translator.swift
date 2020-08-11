//
//  Translator.swift
//  Seven
//
//  Created by apple on 8/8/20.
//  Copyright © 2020 KnowledgeIsBacon. All rights reserved.
//

import UIKit

class Translator {
    /* General */
    func getLanguageFont(_ language: String) -> String {
        switch language {
        case "zh":
            return "PingFangSC-Medium"
        default:
            return "TallBasic30-Regular"
        }
    }
    
    func getLanguageTextPaddingTop(_ language: String) -> CGFloat {
        switch language {
        case "zh":
            return 0.0
        default:
            return 3.0
        }
    }
    
    
    //MARK: Tutorial
    
    func translateTutorialIntroComments(_ language: String) -> [String] {
        print("translate intro comments is caleld")
        switch language {
        case "zh":
            return ["欢迎来到七天大胜！", "7是一个和特别的数字 -- 试试把两个7拼一起好吗？"]
        default:
            return ["Welcome to SEVEN!", "7s are the building blocks of the game - swipe until you make 14!"]
        }
    }
    
    func translateTutorialComments(_ language: String) -> [Int : String] {
        switch language {
        case "zh":
            return [0: "不错呀！继续划就会有新的数字出现～", 1: "来，拼个28！", 2: "很好！", 3: "注意哦，难度要提高了", 4: "注意哦，难度要提高了", 5: "3只能和4合并", 6: "3只能和4合并", 7: "来～试试把3和4合并成7", 8: "拼成7了！✌️✌️✌️", 9: "拼成7了！✌️✌️✌️",10: "2也只能和5合并", 11: "2也只能和5合并", 12: "2也只能和5合并", 13: "2也只能和5合并", 14: "2也只能和5合并", 15: "玩的不错哟！", 16: "玩的不错哟！", 19: "别忘了通过底下的提示了解下一个数字哦～", 24: "祝你“七”开得胜!"]
        default:
            return [0: "Nice! Keep swipin'", 1: "Can you make 28?", 2: "Awesome!", 3: "Ready for a challenge?", 4: "Ready for a challenge?", 5: "3s only combine with 4s..", 6: "3s only combine with 4s..", 7: "Try combining 3 and 4 to make 7!", 8: "Woo - you now have a 7!", 9: "Woo - you now have a 7!",10: "Similarly, 2s only combine with 5s", 11: "Similarly, 2s only combine with 5s", 12: "Similarly, 2s only combine with 5s", 13: "Similarly, 2s only combine with 5s", 14: "Similarly, 2s only combine with 5s", 15: "You're doing great!", 16: "You're doing great!", 19: "Use the Next Tile hints at the bottom to help you!", 24: "Have fun playing!"]
        }
    }
    
    func translateExitTutorialButton(_ language: String) -> String {
        switch language {
        case "zh":
            return "退出"
        default:
            return "Exit Tutorial"
        }
    }
    
    func getExitTutorialButtonFontSize(_ language: String) -> CGFloat {
        switch language {
        case "zh":
            return 20
        default:
            return 24
        }
    }
    
    func translateTutorialButton(_ language: String) -> String {
        switch language {
        case "zh":
            return "教我玩"
        default:
            return "Tutorial"
        }
    }
    
    func translateTutorialWarning(_ language: String) -> String {
        switch language {
        case "zh":
            return "确定想要开始一个新的教程游戏吗？"
        default:
            return "Are you sure you want to switch to a new tutorial game?"
        }
    }
    
    func translateTutorialConfirm(_ language: String) -> String {
        switch language {
        case "zh":
            return "是"
        default:
            return "YES"
        }
    }
    
    //MARK: Main page
    
    func translateResetButton(_ language: String, value: Int) -> String {
        switch language {
        case "zh":
            return "重玩(\(value))"
        default:
            return "RESET(\(value))"
        }
    }
    
    func translateResetButtonFont(_ language: String) -> CGFloat {
        switch language {
        case "zh":
            return 19.0
        default:
            return 24.0
        }
    }
    
    func translateNextTileLabel(_ language: String) -> String {
        switch language {
        case "zh":
            return "下个数字"
        default:
            return "Next Tile"
        }
    }
    
    func translateNextTileLabelFont(_ language: String) -> CGFloat {
        switch language {
        case "zh":
            return 20.0
        default:
            return 24.0
        }
    }
    
    
    //MARK: Stats page
    func translateClearHistory(_ language: String) -> String {
        switch language {
        case "zh":
            return "清除数据"
        default:
            return "Clear History"
        }
    }
    
    func translateContactUs(_ language: String) -> String {
        switch language {
        case "zh":
            return "联系"
        default:
            return "About Us"
        }
    }
    
    func translateContactUsPopup(_ language: String) -> String {
        switch language {
        case "zh":
            return "seventhegame@outlook.com"
        default:
            return "   URL: marissapang.com/seven \n \n   Game: Marissa Pang \n \n   Logo + font: Angelina Yu"
        }
    }

    
    func translateHighScore(_ language: String) -> String {
        switch language {
        case "zh":
            return "最高分"
        default:
            return "YOUR HIGH SCORE"
        }
    }
    
    func translateHighScoreFont(_ language: String) -> CGFloat {
        switch language {
        case "zh":
            return 40.0
        default:
            return 46.0
        }
    }
    
    func translateHighTileAchievements(_ language: String) -> String {
        switch language {
        case "zh":
            return "最高数统计:"
        default:
            return "HIGH-TILE ACHIEVEMENTS:"
        }
    }
    
    func translateGameCountLabel(_ language: String, numGames: Int) -> String {
        switch language {
        case "zh":
            return "您到目前为止已玩过\(numGames)局七天大胜"
        default:
            return "(You've played \(numGames) games of Seven)"
        }
    }
    
    func translateLeaderboard(_ language: String) -> String {
        switch language {
        case "zh":
            return "排行榜"
        default:
            return "Leaderboard"
        }
    }
    
    func translateLeaderboardFont(_ language: String) -> CGFloat {
        switch language {
        case "zh":
            return 19.0
        default:
            return 22.0
        }
    }
    
    func translateHighTileCount(_ language: String, num: Int) -> String {
        switch language {
        case "zh":
            if num == 0 {
                return "无"
            } else {
                return "\(num)次"
            }
        default:
            if num == 0 {
                return "None"
            } else {
                return "\(num) games"
            }
        }
    }
    
    func translateHighTileCountFont(_ language: String) -> CGFloat {
        switch language {
        case "zh":
            return 30
        default:
            return 34
        }
    }
    

    
    //MARK: Alert Views
    
    func translatePlayAgain(_ language: String, value: Int) -> String {
        switch language {
        case "zh":
            return "再玩一次（\(value)）"
        default:
            return "Play Again! (\(value))"
        }
    }
    
    func translateWatchAnAd(_ language: String) -> String {
        switch language {
        case "zh":
            return "看个广告，再玩七次！"
        default:
            return "Watch an ad for 7 more games!"
        }
    }
    
    func translateNewHighScoreEndGame(_ language: String) -> String {
        switch language {
        case "zh":
            return "恭喜恭喜 🎉🎉 刚刚打破了您的高分记录了哦～"
        default:
            return "Nice! 🎉🎉 You just got a new high score! "
        }
    }
    
    func translateOutOfMoves(_ language: String) -> String {
        switch language {
        case "zh":
            return "游戏结束喽 T_T"
        default:
            return "Nooo - you're out of moves :'("
        }
    }
    
    func translateNo(_ language: String) -> String {
        switch language {
        case "zh":
            return "返回"
        default:
            return "NO"
        }
    }
    
    func translateYesDelete(_ language: String) -> String {
        switch language {
        case "zh":
            return "清除"
        default:
            return "YES, DELETE"
        }
    }
    
    func translateClearHistoryWarning(_ language: String) -> String {
        switch language {
        case "zh":
            return "确定要清除所有游戏数据吗？"
        default:
            return "Whoa, you sure you want to delete all your game history?"
        }
    }
    
    func translateAdWontLoadTitle(_ langauge: String) -> String {
        switch langauge {
        case "zh":
            return "广告加载失败了"
        default:
            return "Watch an Ad for 7 more games!"
        }
    }
    
    func translateAdWontLoadMessage(_ langauge: String) -> String {
        switch langauge {
        case "zh":
            return "请检查一下您的网络链接与流量设置 -- 加载广告后可以再玩7局哦～"
        default:
            return "Please check your internet connectivity & data permissions for Seven in Settings so we can load an Ad for you!"
        }
    }
    
    
}
