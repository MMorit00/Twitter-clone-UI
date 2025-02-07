
import SwiftUI
import Kingfisher

struct NotificationCell: View {
    
    @State var width = UIScreen.main.bounds.width
    
    let notification: Notification
    
    var body: some View {
        VStack {
            Rectangle()
                .frame(width: width, height: 1, alignment: .center)
                .foregroundColor(.gray)
                .opacity(0.3)
            
            HStack(alignment: .top) {
                Image(systemName: "person.fill")
                    .resizable()
                    .foregroundColor(.blue)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                VStack(alignment: .leading, spacing: 5, content: {
                    KFImage(URL(string: "http://localhost:3000/users/\(notification.notificationSenderId)/avatar"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .cornerRadius(18)
                    
                    
                    Text(notification.senderUsername ?? "")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    + Text(" ")
                    + Text(notification.notificationType.message)
                        .foregroundColor(.black)
                    
                })
                
                Spacer(minLength: 0)
                
            }
            .padding(.leading, 30)
        }
    }
}

