//
//  CardView.swift
//  FlashCards
//
//  Created by Timi on 11/1/23.
//

import SwiftUI

struct CardView: View {
    let card: Card
    //Now, we don’t want CardView to call up to ContentView and manipulate its data directly, because that causes spaghetti code. Instead, a better idea is to store a closure parameter inside CardView that can be filled with whatever code we want later on – it means we have the flexibility to get a callback in ContentView without explicitly tying the two views together.So, add this new property to CardView below its existing card property.As you can see, that’s a closure that accepts no parameters and sends nothing back, defaulting to nil so we don’t need to provide it unless it’s explicitly needed.
    var removal: (() -> Void)? = nil
    
    @State private var feedback = UINotificationFeedbackGenerator()
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    @State private var isShowingAnswer = false
    @State private var offset = CGSize.zero
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    differentiateWithoutColor
                        ? .white
                        : .white
                            .opacity(1 - Double(abs(offset.width / 50))) // the color starts fading the more we go towards the edge
                )
                .background(
                    differentiateWithoutColor
                        ? nil
                        : RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(offset.width > 0 ? .green : .red) // the card colors change here
                )
                .shadow(radius: 10)
            
            VStack {
                if voiceOverEnabled { //We’re going to change that so the prompt and answer are shown in a single text view, with accessibilityEnabled deciding which layout is shown.
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                } else {
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)

                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        .rotationEffect(.degrees(Double(offset.width / 5)))
        .offset(x: offset.width * 5, y: 0) // move left and right but never up and down
        .opacity(2 - Double(abs(offset.width / 50)))
        //We’re going to take 1/50th of the drag amount, so the card doesn’t fade out too quickly.
        //We don’t care whether they have moved to the left (negative numbers) or to the right (positive numbers), so we’ll put our value through the abs() function. If this is given a positive number it returns the same number, but if it’s given a negative number it removes the negative sign and returns the same value as a positive number.
        //We then use this result to subtract from 2.The use of 2 there is intentional, because it allows the card to stay opaque while being dragged just a little. So, if the user hasn’t dragged at all the opacity is 2.0, which is identical to the opacity being 1. If they drag it 50 points left or right, we divide that by 50 to get 1, and subtract that from 2 to get 1, so the opacity is still 1 – the card is still fully opaque. But beyond 50 points we start to fade out the card, until at 100 points left or right the opacity is 0.
        .accessibilityAddTraits(.isButton) //user will be told this is a button that you can activate
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    feedback.prepare() //get ready for feedback on haptics
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 { // abs = absolute number of that value
                        if offset.width > 0 {
                            feedback.notificationOccurred(.error) //only geting haptic when you fail so that the app is less annoying
                        }
                        removal?() //attempt to call the removal closure if it's set, if it isnt just silently do nothing at all
                    } else {
                        offset = .zero
                    }
                }
        )
        .onTapGesture {
            isShowingAnswer.toggle()
        }
        .animation(.spring(), value: offset) //an animation when the card is not dragged enough and it springs back in the middle
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.example)
    }
}

