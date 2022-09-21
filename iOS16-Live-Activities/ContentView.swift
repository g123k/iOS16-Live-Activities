import SwiftUI
import ActivityKit

struct Constants {
     static let deliveryDuration: Double = 10 // in seconds
 }

struct ContentView: View {
    
    @State var text: String? = nil
    @State var timer: Timer? = nil
    
    // MARK: - Layout
    var body: some View {
        NavigationView {
            ZStack {
                bgImage
                content
            }
            .onTapGesture {
                showAllDeliveries()
            }
            .navigationTitle("La pizzeria 🍕")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Text("Dev Café").bold()
                }
            }
            .preferredColorScheme(.dark)
        }.onAppear {
            refreshTasksCounter()
        }
    }
    var bgImage: some View {
        AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1513104890138-7c749659a591?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=3540&q=80"))
        { image in
            image.resizable().scaledToFill()
        } placeholder: {
            ProgressView()
        }.ignoresSafeArea(.all)
    }
    
    var content: some View {
        VStack {
            Text(text ?? "Etat initial").padding(.top, 50)
            Spacer()
            actionButtons
        }
    }
    
    var actionButtons: some View {
        VStack(spacing:0) {
            HStack(spacing:0) {
                Button(action: { startDeliveryPizza() }) {
                    HStack {
                        Spacer()
                        Text("Ajouter 👨🏻‍🍳").font(.headline)
                        Spacer()
                    }.frame(height: 60)
                }.tint(.blue)
                Button(action: { updateDeliveryPizza() }) {
                    HStack {
                        Spacer()
                        Text("Mettre à jour 🫠").font(.headline)
                        Spacer()
                    }.frame(height: 60)
                }.tint(.purple)
            }.frame(maxWidth: UIScreen.main.bounds.size.width)
            
            Button(action: { stopDeliveryPizza() }) {
                HStack {
                    Spacer()
                    Text("Annuler 😞").font(.headline)
                    Spacer()
                }.frame(height: 60)
                    .padding(.bottom)
            }.tint(.pink)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 0))
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: - Functions
    func startDeliveryPizza() {
        let pizzaDeliveryAttributes = PizzaDeliveryAttributes(numberOfPizzas: 1, totalAmount:"$99")
        
        let initialContentState = PizzaDeliveryAttributes.PizzaDeliveryStatus(driverName: "TIM 👨🏻‍🍳", estimatedDeliveryTime: Date()...Date().addingTimeInterval(Constants.deliveryDuration))
        
        do {
            let deliveryActivity = try Activity<PizzaDeliveryAttributes>.request(
                attributes: pizzaDeliveryAttributes,
                contentState: initialContentState,
                pushType: nil)
            
            rescheduleTimer()
            refreshTasksCounter()
            
            print("Requested a pizza delivery Live Activity \(deliveryActivity.id)")
        } catch (let error) {
            print("Error requesting pizza delivery Live Activity \(error.localizedDescription)")
        }
    }
    
    func updateDeliveryPizza() {
        Task {
            let date = Date()...Date().addingTimeInterval(Constants.deliveryDuration)
            let updatedDeliveryStatus = PizzaDeliveryAttributes.PizzaDeliveryStatus(driverName: "TIM 👨🏻‍🍳", estimatedDeliveryTime: date)
            
            for activity in Activity<PizzaDeliveryAttributes>.activities{
                await activity.update(using: updatedDeliveryStatus)
            }
            
            rescheduleTimer()
            refreshTasksCounter()
        }
    }
    
    func stopDeliveryPizza() {
        Task {
            cancelTimer()
            
            for activity in Activity<PizzaDeliveryAttributes>.activities{
                await activity.end(dismissalPolicy: .immediate)
            }
             
             refreshTasksCounter()
        }
    }
    
    func showAllDeliveries() {
        Task {
            for activity in Activity<PizzaDeliveryAttributes>.activities {
                print("Pizza delivery details: \(activity.id) -> \(activity.attributes)")
            }
            
            refreshTasksCounter()
        }
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func rescheduleTimer() {
        cancelTimer()
        
        let activity = Activity<PizzaDeliveryAttributes>.activities[0]
        let date = activity.contentState.estimatedDeliveryTime.upperBound
        
        timer = Timer.scheduledTimer(withTimeInterval: date.timeIntervalSinceNow, repeats: false) { _ in
            stopDeliveryPizza()
       }
    }
 
    private func refreshTasksCounter() {
        let activities = Activity<PizzaDeliveryAttributes>.activities.count
        
        if (activities == 0) {
            text = "Aucune tâche"
        } else if (activities == 1) {
            text = "1 tâche"
        } else {
            text = "\(Activity<PizzaDeliveryAttributes>.activities.count) tâches"}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
