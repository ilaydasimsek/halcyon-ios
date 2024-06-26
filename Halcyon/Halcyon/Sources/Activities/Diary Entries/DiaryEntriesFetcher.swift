import Foundation
import PromiseKit
import FirebaseAuth
import SwiftyJSON

protocol DiaryEntriesFetching {
    func fetchDiaryEntries() -> Promise<DiaryEntries>
}

class DiaryEntriesFetcher: Fetcher, DiaryEntriesFetching {

    func fetchDiaryEntries() -> Promise<DiaryEntries> {
        return Promise { promiseSeal in
            self.networking.decodedRequest(FirestoreNetworkingService.diaryEntries).done({ result in
                promiseSeal.fulfill(result)
            }).catch({error in
                promiseSeal.reject(error)
            })
        }
    }
}
