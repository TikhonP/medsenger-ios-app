//
//  HtmlMessageParser.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 12.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct HtmlParser {
    struct MessageTextComponent: Identifiable {
        enum ComponentType {
            case text, link
        }
        
        let id = UUID()
        let type: ComponentType
        let text: String
        let url: URL?
    }
    
    private static func cleanHtml(for text: String) -> String {
        text
            .replacingOccurrences(of: #"</?ul>"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"<li>"#, with: "- ")
            .replacingOccurrences(of: #"</li>"#, with: "\n")
            .replacingOccurrences(of: #"<br\s*/?>"#, with: "\n", options: .regularExpression)
            .replacingOccurrences(of: #"</?strong>"#, with: "", options: .regularExpression)
    }
    
    private static func matches(for regex: String, in text: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        return results.map {
            String(text[Range($0.range, in: text)!])
        }
    }
    
    private static func getUrlAndCaptionFromA(for regex: String, in text: String) -> (url: String?, caption: String?) {
        let textRange = NSRange(
            text.startIndex..<text.endIndex,
            in: text
        )
        
        let capturePattern = regex
        let captureRegex = try! NSRegularExpression(
            pattern: capturePattern,
            options: []
        )
        
        let matches = captureRegex.matches(
            in: text,
            options: [],
            range: textRange
        )
        
        for match in matches {
            var result = [String]()
            for rangeIndex in 0..<match.numberOfRanges {
                let matchRange = match.range(at: rangeIndex)
                
                // Ignore matching the entire username string
                if matchRange == textRange { continue }
                
                // Extract the substring matching the capture group
                if let substringRange = Range(matchRange, in: text) {
                    let capture = String(text[substringRange])
                    result.append(capture)
                }
            }
            return (result[safe: 0], result[safe: 1])
        }
        return (nil, nil)
    }
    
    public static func parseHtml(from text: String) -> [MessageTextComponent] {
        var parsedComponents = [MessageTextComponent]()
        
        var cleanedText = cleanHtml(for: text)
        let aTagStrings = matches(for: #"<a.*?/a>"#, in: cleanedText)
        
        for aTagString in aTagStrings {
            let components = cleanedText.components(separatedBy: aTagString)
            let result = getUrlAndCaptionFromA(for: #"<a.*?href="(.*?)".*?>(.*?)</a>"#, in: aTagString)
            if let text = components[safe: 0] {
                parsedComponents.append(MessageTextComponent(type: .text, text: text, url: nil))
            }
            if  let urlString = result.url, let url = URL(string: urlString), let caption = result.caption {
                parsedComponents.append(MessageTextComponent(type: .link, text: caption, url: url))
            }
            if let text = components[safe: 1] {
                cleanedText = text
            } else {
                cleanedText = ""
            }
        }
        if !cleanedText.isEmpty {
            parsedComponents.append(MessageTextComponent(type: .text, text: cleanedText, url: nil))
        }
        
        return parsedComponents
    }
    
    public static func getMarkdownString(from text: String) -> String {
        var output = ""
        for component in parseHtml(from: text) {
            if component.type == .text {
                output += component.text
            } else if component.type == .link, let url = component.url {
                output += "[\(component.text)](\(url.absoluteString))"
            }
        }
        return output
    }
}
