//
//  Message+Preview.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

#if DEBUG
import CoreData

extension Message {
    static func getSampleMessage(for viewContext: NSManagedObjectContext, id: Int = Int.random(in: 0...10000), with text: String? = nil, withReply: Bool = false) -> Message {
        let message = Message(context: viewContext)
        
        message.id = Int64(id)
        if let text = text {
            message.text = text
        } else {
            message.text = """
            "Сидят в ветеринарке пудель, доберман и дог. Разговаривают, мол что и как.
            Пудель говорит:
            — Машину охранял, тут сука с течкой пробегает, у меня перемкнуло и я за
            ней, а в этот момент машину угнали, вот хозяин и привёз кастрировать.
            Доберман говорит:
            — Та же фигня: дом охранял и тоже сука с течкой, я за ней, а дом воры
            обнесли. Вот, тоже хозяева привезли яйца отрезать.
            — Ну, а у тебя что? — спрашивают они дога.
            — Лежу я дома, — говорит дог, — тут хозяйка из душа выходит в коротком
            халатике, сиськи торчат, нагибается, а под халатиком ничего, вот я и на
            неё и запрыгнул.
            — Бляяяя, тебе видать вообще пиздец! — говорят собаки.
            — Это вам пиздец, а меня привезли когти постричь!
            """
        }
        message.sent = Date()
        message.deadline = Date()
        message.isAnswered = false
        message.isOvertime = false
        message.isWarning = false
        message.isDoctorMessage = false
        message.author = "data.author"
        message.authorRole = "data.author_role"
        //        if let isAuto = data.is_auto {
        //            message.isAuto = isAuto
        //        }
        message.state = ""
        //        if let isAgent = data.is_agent {
        //            message.isAgent = isAgent
        //        }
        message.actionType = "data.action_type"
        //        if let actionLink = data.action_link, let urlEncoded = actionLink.urlEncoded {
        //            message.actionLink = URL(string: urlEncoded)
        //        }
        //        if let apiActionLink = data.api_action_link, let urlEncoded = apiActionLink.urlEncoded {
        //            message.apiActionLink = URL(string: urlEncoded)
        //        }
        message.actionName = "data.action_name"
        message.actionDeadline = Date()
        message.actionOnetime = false
        //        if let actionUsed = data.action_used {
        //            message.actionUsed = actionUsed
        //        }
        message.actionBig = false
        message.forwardToDoctor = false
        message.onlyDoctor = false
        message.onlyPatient = false
        message.isUrgent = false
        message.isWarning = false
        //        if let isFiltered = data.is_filtered {
        //            message.isFiltered = isFiltered
        //        }
        //
        //        if let replyToId = data.reply_to_id {
        //             = Int64(replyToId)
        //        }
        //
        if withReply {
            message.replyToMessage = Message.getSampleMessage(for: viewContext, with: """
                                                                Едет скорый поезд на полной скорости. Вдруг он съезжает с рельс, проскакивает лесополосу, кукурузное поле и вновь возвращается на рельсы. Обалдевшие пассажиры приходят в себя и отправляют делегацию в голову состава,спрашивают у машиниста:
                                                                - Что это было?
                                                                - Едем, смотрю мужик на рельсах срет.
                                                                - Так давить надо было!
                                                                - Так вот только в кукурузе и догнали..
                                                                """)
        }
        return message
    }
}

extension Message {
    static func getSampleVoiceMessage(for viewContext: NSManagedObjectContext, id: Int = Int.random(in: 0...10000), withReply: Bool = false) -> Message {
        let message = Message(context: viewContext)
        
        message.id = Int64(id)
        message.text = Constants.voiceMessageText
        message.sent = Date()
        message.deadline = Date()
        message.isAnswered = false
        message.isOvertime = false
        message.isWarning = false
        message.isDoctorMessage = false
        message.author = "data.author"
        message.authorRole = "data.author_role"
        //        if let isAuto = data.is_auto {
        //            message.isAuto = isAuto
        //        }
        message.state = ""
        //        if let isAgent = data.is_agent {
        //            message.isAgent = isAgent
        //        }
        message.actionType = "data.action_type"
        //        if let actionLink = data.action_link, let urlEncoded = actionLink.urlEncoded {
        //            message.actionLink = URL(string: urlEncoded)
        //        }
        //        if let apiActionLink = data.api_action_link, let urlEncoded = apiActionLink.urlEncoded {
        //            message.apiActionLink = URL(string: urlEncoded)
        //        }
        message.actionName = "data.action_name"
        message.actionDeadline = Date()
        message.actionOnetime = false
        //        if let actionUsed = data.action_used {
        //            message.actionUsed = actionUsed
        //        }
        message.actionBig = false
        message.forwardToDoctor = false
        message.onlyDoctor = false
        message.onlyPatient = false
        message.isUrgent = false
        message.isWarning = false
        //        if let isFiltered = data.is_filtered {
        //            message.isFiltered = isFiltered
        //        }
        //
        //        if let replyToId = data.reply_to_id {
        //             = Int64(replyToId)
        //        }
        //
        if withReply {
            message.replyToMessage = Message.getSampleMessage(for: viewContext, with: """
                                                                Едет скорый поезд на полной скорости. Вдруг он съезжает с рельс, проскакивает лесополосу, кукурузное поле и вновь возвращается на рельсы. Обалдевшие пассажиры приходят в себя и отправляют делегацию в голову состава,спрашивают у машиниста:
                                                                - Что это было?
                                                                - Едем, смотрю мужик на рельсах срет.
                                                                - Так давить надо было!
                                                                - Так вот только в кукурузе и догнали..
                                                                """)
        }
        
        let attachment = Attachment(context: viewContext)
        
        attachment.id = 1231212
        attachment.name = "kek lol"
        attachment.icon = ""
        attachment.mime = "audio/mp4"
        attachment.size = 1234543
        
        if let fileURL = Bundle.main.url(forResource: "VoiceMessagePreview", withExtension: "m4a") {
            if let data = try? Data(contentsOf: fileURL) {
                attachment.saveFile(data)
            }
        }
        
        message.addToAttachments(attachment)
        return message
    }
}
#endif
