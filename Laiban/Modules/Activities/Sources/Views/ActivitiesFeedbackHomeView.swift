import SwiftUI
import Combine
import Assistant

public struct ActivitiesFeedbackHomeView : View {
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale

    public var body: some View {
        Button {
            viewState.navigate(to: .rateActivities)
        } label: {
            HStack(spacing: 20) {
                //LBImageBadgeView(image: Image("HandTap", bundle: .module), rimColor: Color("RimColorActivities"))
                Text("home_feedback_acitivity_title", bundle: .module)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth:.infinity,alignment: .leading)
                ActivitiesHomeViewIcon()
                    .frame(width: 80, height: 80, alignment: .center)
            }
            .frame(maxWidth:.infinity)
            .padding(properties.spacing[.m])
            .primaryContainerBackground()
            .font(properties.font, ofSize: .n)
        }.buttonStyle(LBScaleEffectButtonStyle())
    }
}
struct ActivitiesFeedbackHomeView_Previews: PreviewProvider {
    static var items:[Activity] = {
        let a1 = Activity(date: Date(), content: "En kortare text", emoji: "🧑‍🎓", activityParticipants: ["Tomas", "Tessan"])
        let a2 = Activity(date: Date(), content: "Ee lite längre test som ska bryta rader?", emoji: "🧑‍🎓", activityParticipants: ["Simon", "Lisa"])
        return [a1,a2]
    }()
    static var previews: some View {
        LBFullscreenContainer { _ in
            ActivitiesFeedbackHomeView()
        }.attachPreviewEnvironmentObjects()
    }
}
