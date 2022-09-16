import Foundation
import Combine

public struct UDPipe {
    public struct Component: Codable {
        public let id:String
        public let form:String
        public let lemma:String
        public let uPosTag:String
        public let xPosTag:String
        public let feats:String
        public let head:String
        public let deprel:String
        public let deps:String
        public let misc:String
        init(strings:[String]) {
            self.id = strings[0]
            self.form = strings[1]
            self.lemma = strings[2]
            self.uPosTag = strings[3]
            self.xPosTag = strings[4]
            self.feats = strings[5]
            self.head = strings[6]
            self.deprel = strings[7]
            self.deps = strings[8]
            self.misc = strings[9]
        }
    }
    public struct Result {
        public let original:String
        public let response:ServiceResponse?
        public let error:Error?
    }
    public struct ServiceResponse : Codable {
        public let model:String
        public let acknowledgements:[String]
        public let result:String
        public let components:[Component]
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.model = try values.decode(String.self, forKey: .model)
            self.acknowledgements = try values.decode([String].self, forKey: .acknowledgements)
            let res = try values.decode(String.self, forKey: .result)
            self.result = res
            self.components = Self.parseResult(res)
        }
        static func parseResult(_ string:String) -> [Component] {
            var res = [Component]()
            let arr = string.split(separator: "\n").map { s in String(s) }
            for a in arr {
                if a.first == "#" {
                    continue
                }
                let columns = a.split(separator: "\t").map { s in String(s) }
                if columns.count != 10 {
                    continue
                }
                res.append(Component(strings: columns))
            }
            return res
        }
    }
    public struct Model: Codable {
        public let language:String
        public let name:String
        public let pipeModel:String
        public let version:String
        public let build:String
        public let features:[String]
        public let description:String

        init(description:String, features:[String]) {
            let components = description.split(separator: "-")
            self.language = components.prefix(1).joined(separator: "")
            self.version = components.suffix(2).dropLast().joined(separator: "-")
            self.build = components.suffix(1).joined(separator: "")
            self.name = components.dropFirst(1).prefix(1).joined(separator: "")
            self.pipeModel = components.suffix(3).prefix(1).joined(separator: "")
            self.description = description
            self.features = features
        }
        public func analyze(_ text:String) -> AnyPublisher<ServiceResponse,Error> {
            let headers:[String:String] = ["Content-Type":"application/x-www-form-urlencoded"]
            var body = URLComponents()
            var items = [URLQueryItem]()
            items.append(URLQueryItem(name: "model", value: description))
            items.append(URLQueryItem(name: "tokenizer", value: "ranges"))
            items.append(URLQueryItem(name: "tagger", value: ""))
            items.append(URLQueryItem(name: "parser", value: ""))
            items.append(URLQueryItem(name: "data", value: text))
            body.queryItems = items
            
            var req = URLRequest(url: URL(string: "https://lindat.mff.cuni.cz/services/udpipe/api/process")!)
            req.httpMethod = "POST"
            req.allHTTPHeaderFields = headers
            req.httpBody = body.query?.data(using: .utf8)
            return URLSession.shared.dataTaskPublisher(for: req)
                .map { $0.data }
                .decode(type: ServiceResponse.self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
        }
        public func analyze(_ text:[String]) -> AnyPublisher<[Result],Never> {
            var cancellables = Set<AnyCancellable>()
            let subject = PassthroughSubject<[Result],Never>()
            var result = [Result]()
            var texts = text
            func next() {
                if let t = texts.first {
                    texts.removeFirst()
                    recur(text: t)
                } else {
                    subject.send(result)
                }
            }
            func recur(text:String) {
                analyze(text).sink { completion in
                    switch completion {
                    case .failure(let error):
                        result.append(.init(original: text, response: nil, error: error))
                        next()
                    case .finished: break
                    }
                    
                } receiveValue: { r in
                    result.append(.init(original: text, response: r, error: nil))
                    next()
                }.store(in: &cancellables)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                next()
            }
            return subject.eraseToAnyPublisher()
        }
    }
    public static func latest(language:String, modelName:String? = nil) -> AnyPublisher<Model?,Never> {
        fetchModels().replaceError(with: []).compactMap { models in
            models.filter { $0.language == language && (modelName == nil || $0.name == modelName) }.sorted { $0.version + "." + $0.build > $1.version + "." + $1.build }.first
        }.eraseToAnyPublisher()
    }
    public static func fetchModels() -> AnyPublisher<[Model],Error> {
        return URLSession.shared.dataTaskPublisher(for: URL(string: "https://lindat.mff.cuni.cz/services/udpipe/api/models")!)
            .map {
                $0.data
            }
            .tryMap { data in
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [String : Any]()
                guard let models = json["models"] as? [String:Any] else {
                    throw URLError(.badServerResponse)
                }
                var arr = [Model]()
                for (key,value) in models {
                    guard let features = value as? [String] else {
                        continue
                    }
                    arr.append(.init(description: key, features: features))
                }
                return arr.sorted { $0.description < $1.description }
            }
            .eraseToAnyPublisher()
    }
}
