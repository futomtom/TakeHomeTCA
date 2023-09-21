import ComposableArchitecture
import Foundation

struct MarvelClient {
    var fetch: @Sendable (Marvel.EndPoint, Int) async throws -> MarvelResponse
}

extension MarvelClient: DependencyKey {
    static let liveValue = Self(
            fetch: { endpoint, offset in
                let marvel = Marvel(endPoint: endpoint)
                guard let url = marvel.makeURL(offset) else {
                    throw NetworkError.invalidURL
                }

                let result: MarvelResponse = try await MarvelClient.get(from: url)
                return result
            }
        )


    static func get<T: Decodable>(from url: URL) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NetworkError.invalidServerResponse
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let result: T = try decoder.decode(T.self, from: data)
                return result
            } catch {
                throw error
            }
        } catch {
            throw error
        }
    }
}

extension DependencyValues {
    var marvelClient: MarvelClient {
        get { self[MarvelClient.self] }
        set { self[MarvelClient.self] = newValue }
    }
}
