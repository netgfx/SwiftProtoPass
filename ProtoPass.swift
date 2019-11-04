//
//  ProtoPass.swift
//  PodcastPlatform
//
//  Created by Mixalis Dobekidis on 04/11/2019.
//  Copyright © 2019 7linternational. All rights reserved.
//

import Foundation
import SwiftyJSON

// Singleton instance
private let _singletonInstanceDS = ProtoPass()

class ProtoPass {
    class var sharedInstance: ProtoPass {
           return _singletonInstanceDS
       }
    
    private var options:JSON = JSON([
        "messages": ["Unsafe password word!", "Too short", "Very weak", "Weak", "Medium", "Strong", "Very strong"],
        "scores": [10, 15, 30, 40],
        "common": ["password", "123456", "123", "1234", "mypass", "pass", "letmein", "qwerty", "monkey", "asdfgh", "zxcvbn", "pass", "contraseña"],
        "minchar": 6
    ])
    
    private func displayPasswordStrengthFeedback(setting_index:Int) -> String{
        return (options["messages"].array?[setting_index].stringValue) ?? ""
    }
    
    public func checkUserPasswordStrength(value:String) -> String {
        let _options = options;
        let value = value;
        
        let strength = getPasswordScore(value: value, options: _options);

        if (strength == -200) {
            return displayPasswordStrengthFeedback(setting_index: 0);
        } else {
            if (strength < 0 && strength > -199) {
                return displayPasswordStrengthFeedback(setting_index: 1);
            } else {
                if (strength <= options["scores"].arrayValue[0].intValue) {
                    return displayPasswordStrengthFeedback(setting_index: 2);
                } else {
                    if (strength > options["scores"].arrayValue[0].intValue && strength <= options["scores"].arrayValue[1].intValue) {
                        return displayPasswordStrengthFeedback(setting_index: 3);
                    } else if (strength > options["scores"].arrayValue[1].intValue && strength <= options["scores"].arrayValue[2].intValue) {
                        return displayPasswordStrengthFeedback(setting_index: 4);
                    } else if (strength > options["scores"].arrayValue[2].intValue && strength <= options["scores"].arrayValue[3].intValue) {
                        return displayPasswordStrengthFeedback(setting_index: 5);
                    } else {
                        return displayPasswordStrengthFeedback(setting_index: 6);
                    }
                }
            }
        }
    }
    
    
    private func getPasswordScore (value:String, options:JSON) -> Int {
        var strength:Int = 0;
        if (value.count < options["minchar"].intValue) {
            strength = (strength - 100);
        } else {
            if (value.count >= options["minchar"].intValue && value.count <= (options["minchar"].intValue + 2)) {
                strength = (strength + 6);
            } else {
                if (value.count >= (options["minchar"].intValue + 3) && value.count <= (options["minchar"].intValue + 4)) {
                    strength = (strength + 12);
                } else {
                    if (value.count >= (options["minchar"].intValue + 5)) {
                        strength = (strength + 18);
                    }
                }
            }
        }

        
        if matches(for: "[a-z]", in: value).count > 0 { //(value.match(/[a-z]/)) {
            strength = (strength + 1);
        }
        if matches(for: "[A-Z]", in: value).count > 0 {//(value.match(/[A-Z]/)) {
            strength = (strength + 5);
        }
        if matches(for: "\\d+", in: value).count > 0 { //(value.match(/\d+/)) {
            strength = (strength + 5);
        }
        if matches(for: "/(.*[0-9].*[0-9].*[0-9])/)/", in: value).count > 0 { //(value.match(/(.*[0-9].*[0-9].*[0-9])/)) {
            strength = (strength + 7);
        }
        if  matches(for: "/.[!,@,#,$,%,^,&,*,?,_,~]/", in: value).count > 0 { //(value.match(/.[!,@,#,$,%,^,&,*,?,_,~]/)) {
            strength = (strength + 5);
        }
        if matches(for: "/(.*[!,@,#,$,%,^,&,*,?,_,~].*[!,@,#,$,%,^,&,*,?,_,~])/", in: value).count > 0 { //(value.match(/(.*[!,@,#,$,%,^,&,*,?,_,~].*[!,@,#,$,%,^,&,*,?,_,~])/)) {
            strength = (strength + 7);
        }
        if matches(for: "/([a-z].*[A-Z])|([A-Z].*[a-z])/", in: value).count > 0 {
            //(value.match(/([a-z].*[A-Z])|([A-Z].*[a-z])/)) {
            strength = (strength + 2);
        }
        if matches(for: "/([a-zA-Z])/) && value.match(/([0-9])/", in: value).count > 0 {
            //(value.match(/([a-zA-Z])/) && value.match(/([0-9])/)) {
            strength = (strength + 3);
        }
        if matches(for: "/([a-zA-Z0-9].*[!,@,#,$,%,^,&,*,?,_,~])|([!,@,#,$,%,^,&,*,?,_,~].*[a-zA-Z0-9])/", in: value).count > 0 {
            //(value.match(/([a-zA-Z0-9].*[!,@,#,$,%,^,&,*,?,_,~])|([!,@,#,$,%,^,&,*,?,_,~].*[a-zA-Z0-9])/)) {
            strength = (strength + 3);
        }
        
        for item in options["common"].arrayValue {
            if value.lowercased() == item.stringValue {
                strength -= 200
            }
        }
        
//        for (var i = 0; i < options.common.length; i++) {
//            if (value.toLowerCase() == options.common[i]) {
//                strength = -200
//            }
//        }
        
        return strength
    }
    
    private func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
}
