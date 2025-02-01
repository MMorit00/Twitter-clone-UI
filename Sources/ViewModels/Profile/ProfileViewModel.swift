import SwiftUI 


class ProfileViewModel: ObservableObject {
    
    @Published var tweets = [Tweet]()
    @Published var user: User
    
    init(user: User) {
        self.user = user
//        let defaults = UserDefaults.standard
//        let token = defaults.object(forKey: "jsonwebtoken")
//        
//        if token != nil {
//            if let userId = defaults.object(forKey: "userid") {
//                fetchUser(userId: userId as! String)
//            }
//        }
        // fetchTweets()
        // checkIfIsCurrentUser()
        // checkIfUserIsFollowed()
    }
}