import Foundation
import Combine

public struct SharedActivity : Codable, Identifiable, Equatable {
    public enum NumberOfParticipants : String, Codable  {
        case twoToFive
        case fiveToTen
        case tenToFifteen
        case entireGroup
        public var range:ClosedRange<Int> {
            switch self {
            case .twoToFive: return 2...5
            case .fiveToTen: return 5...10
            case .tenToFifteen: return 10...15
            case .entireGroup: return 0...Int.max
            }
        }
        public var description:String {
            switch self {
            case .twoToFive: return "2-5 barn"
            case .fiveToTen: return "5-10 barn"
            case .tenToFifteen: return "10-15 barn"
            case .entireGroup: return "Hela gruppen"
            }
        }
    }
    public enum Environment : String, Codable  {
        case any
        case indoors
        case outdoors
        case outdoorsSurroundingArea
        public var description:String {
            switch self {
            case .any: return "Var som helst"
            case .indoors: return "Inomhus"
            case .outdoors: return "Utomhus"
            case .outdoorsSurroundingArea: return "Utomhus i närområdet"
            }
        }
    }
    public enum TimeToComplete : String, Codable  {
        case lessThanOneHour
        case oneToTwoHours
        case moreThanOneOccation
        public var description:String {
            switch self {
            case .lessThanOneHour: return "Under en timma"
            case .oneToTwoHours: return "1-2 timmar"
            case .moreThanOneOccation: return "Flera tillfällen"
            }
        }
    }
    public struct Media: Codable, Equatable {
        public let url:URL
        public let title:String?
        public let mime:String?
        public var isImage:Bool  {
            return mime?.contains("image/") == true
        }
        public var isVideo:Bool  {
            return mime?.contains("video/") == true
        }
        public init(url:URL, title:String?, mime:String?) {
            self.url = url
            self.title = title
            self.mime = mime
        }
    }
    public struct Link : Codable,Equatable {
        public let url:URL
        public let title:String?
        public init(url:URL, title:String?) {
            self.url = url
            if title == nil {
                self.title = url.host
            } else {
                self.title = title
            }
        }
        public init?(_ string:String?, title:String? = nil) {
            guard let string = string, let url = URL(string: string) else {
                return nil
            }
            self.url = url
            if title == nil {
                self.title = url.host
            } else {
                self.title = title
            }
        }
    }
    /// missing attributes? searchWords?
    public let id:String
    public let title:String
    public let created:Date
    public let purpose:String
    public let description:String
    public let coverImage:URL
    public let link:Link?
    public let otherMedia:[Media]
    public let tags:[String]
    public let author:String
    public let enviroment:Environment
    public let timeToComplete:TimeToComplete
    public let participants:NumberOfParticipants
    
    public static func fetch(url:URL) -> AnyPublisher<[SharedActivity],Error> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [SharedActivity].self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    public init(
        id:String,
        title:String,
        created:Date,
        purpose:String,
        description:String,
        coverImage:URL,
        link:Link?,
        otherMedia:[Media],
        tags:[String],
        author:String,
        enviroment:Environment,
        timeToComplete:TimeToComplete,
        participants:NumberOfParticipants
    ) {
        self.id = id
        self.title = title
        self.created = created
        self.purpose = purpose
        self.description = description
        self.coverImage = coverImage
        self.link = link
        self.otherMedia = otherMedia
        self.tags = tags
        self.author = author
        self.enviroment = enviroment
        self.timeToComplete = timeToComplete
        self.participants = participants
    }
    public static var previewData:[SharedActivity] = [
        .init(
            id: "SharedActivity-dummy-item-1",
            title: "Sed sagittis",
            created: Date(),
            purpose: "Praesent semper tellus urna, in hendrerit tellus tristique sit amet. Aenean gravida elit in feugiat aliquet. Sed justo tellus, faucibus vel posuere lacinia, lobortis non metus. Ut pretium ac velit at pretium. Nullam eget lectus dolor.",
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas justo mi, laoreet eget mattis ac, commodo id neque. Integer consequat velit vitae elementum pellentesque. Quisque tempus eu ligula sed pulvinar. Proin rutrum congue diam a porta. Nulla massa odio, fermentum et lobortis congue, ultrices ultricies libero. Suspendisse purus ligula, dapibus lacinia pretium id, tristique in dui. Cras consectetur bibendum dolor eu ultricies. Sed finibus aliquet porta.",
            coverImage: URL(string: "https://images.unsplash.com/photo-1630353958868-3d666d94800c?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1834&q=80")!,
            link: .init(url: URL(string: "https://www.globalamalen.se/om-globala-malen/mal-6-rent-vatten-och-sanitet/")!, title: "globalamålen.se"),
            otherMedia: [],
            tags: ["undpGoal6"],
            author: "Tomas Green",
            enviroment: .indoors,
            timeToComplete: .oneToTwoHours,
            participants: .fiveToTen
        ),
        .init(
            id: "SharedActivity-dummy-item-2",
            title: "Donec quis nunc vel lectus tempus imperdiet",
            created: Date(),
            purpose: "Donec pulvinar facilisis erat, eget tempor nisi vehicula in.",
            description: "Morbi ac sagittis enim. Mauris varius dui ante, ac laoreet nisl interdum ut. Vivamus vel maximus neque. Sed blandit fringilla risus vel consectetur. Curabitur id risus vel metus egestas finibus a sit amet justo.",
            coverImage: URL(string: "https://images.unsplash.com/photo-1630344788865-6927d680b2d4?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=3334&q=80")!,
            link: .init(url: URL(string: "https://www.globalamalen.se/om-globala-malen/mal-3-halsa-och-valbefinnande/")!, title: "globalamålen.se"),
            otherMedia: [.init(url: URL(string: "https://images.unsplash.com/photo-1630403248103-728dbbbe15e5?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1523&q=80")!, title: "Bild", mime: "image/jpeg")],
            tags: ["undpGoal3","undpGoal1","undpGoal2","undpGoal7","undpGoal17","undpGoal9"],
            author: "Laiban",
            enviroment: .outdoors,
            timeToComplete: .moreThanOneOccation,
            participants: .entireGroup
        )
    ]
}

public class ActivityDatabase : ObservableObject {
    @Published public var latest:[SharedActivity] = []
    public var publishers = Set<AnyCancellable>()
    public func fetch() {
        SharedActivity.fetch(url: Bundle.module.url(forResource: "TestActivities", withExtension:"json")!).sink { completion in
            
        } receiveValue: { [weak self] activities in
            self?.latest = activities
        }.store(in: &publishers)
    }
    public init(previewData:Bool) {
        if previewData {
            self.latest = SharedActivity.previewData
        } else {
            fetch()
        }
    }
}
