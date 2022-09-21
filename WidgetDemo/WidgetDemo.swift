import ActivityKit
import WidgetKit
import SwiftUI

@main
struct Widgets: WidgetBundle {
    var body: some Widget {
        if #available(iOS 16.1, *) {
            PizzaDeliveryActivityWidget()
        }
    }
}

struct PizzaDeliveryActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PizzaDeliveryAttributes.self) { context in
            LockScreenWidget(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "bag")
                        Text("\(context.attributes.numberOfPizzas) Pizzas")
                            .font(.title2)
                    }
                    
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("\(context.state.driverName) is on his way!")
                        .lineLimit(1)
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 10) {
                        Image(systemName: "timer")
                        Text(timerInterval: context.state.estimatedDeliveryTime, countsDown: true)
                            .multilineTextAlignment(.trailing)
                            .monospacedDigit()
                            .font(.caption2)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Button {
                        // Deep link into the app.
                    } label: {
                        Label("Contact driver", systemImage: "phone")
                    }
                }
            } compactLeading: {
                Label {
                    Text("\(context.attributes.numberOfPizzas) Pizzas")
                } icon: {
                    Image(systemName: "bag")
                }
                .font(.caption2)
            } compactTrailing: {
                Text(timerInterval: context.state.estimatedDeliveryTime, countsDown: true)
                    .multilineTextAlignment(.center)
                    .frame(width: 40)
                    .font(.caption2)
            } minimal: {
                VStack(alignment: .center) {
                    Image(systemName: "timer")
                    Text(timerInterval: context.state.estimatedDeliveryTime, countsDown: true)
                        .multilineTextAlignment(.center)
                        .monospacedDigit()
                        .font(.caption2)
                }
            }
            .keylineTint(.accentColor)
        }
    }
}

private struct LockScreenWidget: View {
    
    let context: ActivityViewContext<PizzaDeliveryAttributes>
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(context.state.driverName) is on the way!").font(.headline)
                    HStack {
                        VStack {
                            Divider().frame(height: 6).overlay(.blue).cornerRadius(5)
                        }
                        Image(systemName: "box.truck.badge.clock.fill").foregroundColor(.blue)
                        VStack {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.secondary, style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .frame(height: 6)
                        }
                        Text(timerInterval: context.state.estimatedDeliveryTime, countsDown: true)
                        VStack {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.secondary, style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .frame(height: 6)
                        }
                        Image(systemName: "house.fill").foregroundColor(.green)
                    }
                }.padding(.trailing, 25)
                Text("\(context.attributes.numberOfPizzas) 🍕").font(.title).bold()
            }.padding(5)
            Text("You've already paid: \(context.attributes.totalAmount) + $9.9 Delivery Fee 💸").font(.caption).foregroundColor(.secondary)
        }.padding(15)
    }
}
