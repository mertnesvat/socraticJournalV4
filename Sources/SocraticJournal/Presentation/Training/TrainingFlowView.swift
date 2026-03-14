// TrainingFlowView.swift
// SocraticJournal
// Copyright 2024 StudioNext

#if os(iOS)
import SwiftUI

/// Step-by-step training exercise flow
struct TrainingFlowView: View {
    @State private var viewModel: TrainingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showExitConfirmation = false

    init(exercise: TrainingData.Exercise) {
        _viewModel = State(initialValue: TrainingViewModel(exercise: exercise))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress dots
                progressDots
                    .padding(.top, AppSpacing.md)

                Spacer()

                // Step content
                if let step = viewModel.currentStep {
                    stepContent(step)
                        .padding(.horizontal, AppSpacing.screenPadding)
                }

                Spacer()
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(viewModel.exercise.name)
                        .font(.system(size: 15, weight: .bold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if viewModel.isTimerRunning {
                            showExitConfirmation = true
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .alert("End exercise?", isPresented: $showExitConfirmation) {
                Button("End", role: .destructive) { dismiss() }
                Button("Continue", role: .cancel) {}
            }
        }
        .onAppear { viewModel.handleStepEntry() }
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<viewModel.totalSteps, id: \.self) { index in
                Circle()
                    .fill(index <= viewModel.currentStepIndex ? AppColors.accent : AppColors.border)
                    .frame(width: 6, height: 6)
            }
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private func stepContent(_ step: TrainingData.Step) -> some View {
        switch step.type {
        case .instruction(let text, _):
            instructionView(text)

        case .timerCountdown(let text, _, let showPanic):
            countdownView(text: text, showPanic: showPanic)

        case .timerCountUp(let text, _, let tapToStop):
            countUpView(text: text, tapToStop: tapToStop)

        case .tapResponse(let question, let options):
            tapResponseView(question: question, options: options, stepId: step.id)

        case .tapCounter(let text, _):
            tapCounterView(text: text)

        case .ratingScale(let question, let count, let lowLabel, let highLabel):
            ratingScaleView(question: question, count: count, lowLabel: lowLabel, highLabel: highLabel)

        case .result:
            resultView
        }
    }

    // MARK: - Instruction

    private func instructionView(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .bold, design: .serif))
            .foregroundStyle(AppColors.textPrimary)
            .multilineTextAlignment(.center)
            .lineSpacing(6)
    }

    // MARK: - Countdown Timer

    private func countdownView(text: String, showPanic: Bool) -> some View {
        VStack(spacing: AppSpacing.lg) {
            Text(text)
                .font(.system(size: 15, design: .serif))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text(String(format: "%.0f", viewModel.timerValue))
                .font(.system(size: 48, weight: .bold, design: .serif))
                .monospacedDigit()
                .foregroundStyle(AppColors.textPrimary)

            if showPanic {
                Button {
                    viewModel.panicStop()
                } label: {
                    Text("I need to stop")
                        .font(.system(size: 12, weight: .regular, design: .serif))
                        .foregroundStyle(AppColors.accent2)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(AppColors.accent2, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Count-Up Timer

    private func countUpView(text: String, tapToStop: Bool) -> some View {
        VStack(spacing: AppSpacing.lg) {
            Text(text)
                .font(.system(size: 15, design: .serif))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text(String(format: "%.1f", viewModel.timerValue))
                .font(.system(size: 48, weight: .bold, design: .serif))
                .monospacedDigit()
                .foregroundStyle(AppColors.textPrimary)

            Text("seconds")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textTertiary)

            if tapToStop {
                Button {
                    viewModel.tapStop()
                } label: {
                    Text("TAP")
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .tracking(1.0)
                        .foregroundStyle(.white)
                        .frame(width: 80, height: 80)
                        .background(AppColors.accent)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Tap Response

    private func tapResponseView(question: String, options: [String], stepId: Int) -> some View {
        VStack(spacing: AppSpacing.lg) {
            Text(question)
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            VStack(spacing: AppSpacing.sm) {
                ForEach(options, id: \.self) { option in
                    Button {
                        viewModel.selectResponse(option, forStep: stepId)
                    } label: {
                        Text(option)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColors.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(AppColors.accent, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Tap Counter

    private func tapCounterView(text: String) -> some View {
        VStack(spacing: AppSpacing.lg) {
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // Tap circle
            Button {
                viewModel.tapBreathCount()
            } label: {
                ZStack {
                    Circle()
                        .stroke(AppColors.accent, lineWidth: 2)
                        .frame(width: 80, height: 80)

                    Text("\(viewModel.tapCount)")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(AppColors.textPrimary)
                }
            }
            .buttonStyle(.plain)

            // Countdown
            Text(String(format: "%.0f", viewModel.timerValue))
                .font(.system(size: 15))
                .monospacedDigit()
                .foregroundStyle(AppColors.textTertiary)
        }
    }

    // MARK: - Rating Scale

    private func ratingScaleView(question: String, count: Int, lowLabel: String, highLabel: String) -> some View {
        VStack(spacing: AppSpacing.lg) {
            Text(question)
                .font(.system(size: 15, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                ForEach(1...count, id: \.self) { value in
                    Button {
                        viewModel.selectRating(value)
                    } label: {
                        ZStack {
                            Circle()
                                .fill(viewModel.ratingValue == value ? AppColors.accent : Color.clear)
                                .frame(width: 36, height: 36)
                            Circle()
                                .stroke(viewModel.ratingValue == value ? AppColors.accent : AppColors.border, lineWidth: 1.5)
                                .frame(width: 36, height: 36)
                            Text("\(value)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(viewModel.ratingValue == value ? .white : AppColors.textPrimary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                Text(lowLabel)
                    .font(.system(size: 9))
                    .foregroundStyle(AppColors.textTertiary)
                Spacer()
                Text(highLabel)
                    .font(.system(size: 9))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(.horizontal, AppSpacing.md)

            if viewModel.ratingValue > 0 {
                Button {
                    viewModel.submitRating()
                } label: {
                    Text("NEXT")
                        .font(.system(size: 12, weight: .bold, design: .serif))
                        .tracking(1.0)
                        .foregroundStyle(AppColors.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }

            Text("Repeat if needed. The effect often improves with each round.")
                .font(.system(size: 11))
                .foregroundStyle(AppColors.textTertiary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Result

    @ViewBuilder
    private var resultView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                if viewModel.exercise.id == "breath_awareness" {
                    breathAwarenessResult
                } else if viewModel.exercise.id == "mouth_tape" {
                    mouthTapeResult
                } else if viewModel.exercise.id == "co2_builder" {
                    co2BuilderResult
                } else if viewModel.exercise.id == "altitude_hold" {
                    altitudeHoldResult
                } else if viewModel.exercise.id == "co2_table" {
                    co2TableResult
                } else if viewModel.exercise.id == "breathhold_walk" {
                    breathHoldWalkResult
                } else if viewModel.exercise.id == "apnea_pyramid" {
                    apneaPyramidResult
                } else {
                    noseUnblockingResult
                }

                // Done button
                Button {
                    dismiss()
                } label: {
                    Text("DONE")
                        .font(.system(size: 12, weight: .bold, design: .serif))
                        .tracking(1.0)
                        .foregroundStyle(AppColors.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .padding(.top, AppSpacing.md)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    // MARK: - Exercise-Specific Results

    private var noseUnblockingResult: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Exercise Complete")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            if viewModel.ratingValue >= 4 {
                resultCard("Your nasal passages responded well. Practice daily for best results.", colorHex: "2D5F5D")
            } else if viewModel.ratingValue >= 2 {
                resultCard("Some improvement. Repeat 2-3 times for a stronger effect. The CO\u{2082} build-up needs time to dilate the blood vessels.", colorHex: "7A6030")
            } else {
                resultCard("The congestion is persistent. Try repeating the exercise, or consult an ENT if nasal obstruction is chronic.", colorHex: "C4502A")
            }
        }
    }

    private var breathAwarenessResult: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Your Assessment")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            // Tongue position
            let tongue = viewModel.responses[0] ?? "No"
            if tongue == "Yes" {
                resultCard("Tongue: Correct \u{2014} tongue on the palate is the natural resting position. This supports nasal breathing.", colorHex: "2D5F5D")
            } else {
                resultCard("Tongue: Try gently pressing your tongue to the roof of your mouth. This is called \u{2018}mewing\u{2019} and helps maintain nasal breathing.", colorHex: "C4502A")
            }

            // Breathing type
            let breathing = viewModel.responses[1] ?? "Chest"
            if breathing == "Belly" {
                resultCard("Breathing: Good \u{2014} diaphragmatic breathing is correct. The belly moves because the diaphragm pushes down.", colorHex: "2D5F5D")
            } else {
                resultCard("Breathing: Chest breathing is shallow and activates the stress response. Practice directing breath into the belly.", colorHex: "C4502A")
            }

            // Breath rate
            let bpm = viewModel.breathBPM
            if bpm > 14 {
                resultCard("Rate: You\u{2019}re over-breathing at \(bpm) BPM. The optimal resting rate is 5-8 breaths per minute.", colorHex: "C4502A")
            } else if bpm >= 8 {
                resultCard("Rate: Average range at \(bpm) BPM. Practice will lower this.", colorHex: "7A6030")
            } else {
                resultCard("Rate: Excellent \u{2014} \(bpm) BPM indicates strong breathing efficiency.", colorHex: "2D5F5D")
            }
        }
    }

    private var mouthTapeResult: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Your Result")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            let response = viewModel.responses[2] ?? "Easy"
            switch response {
            case "Easy":
                resultCard("You\u{2019}re ready for mouth taping during sleep. Start with a small piece of micropore tape vertically over your lips. If you can breathe around it, that\u{2019}s fine \u{2014} it\u{2019}s a gentle reminder, not a seal. Nestor taped his mouth every night during his research and calls it the single most impactful change he made.", colorHex: "2D5F5D")
            case "Some difficulty":
                resultCard("Your nasal passages may need more time. Practice the Nose Unblocking exercise daily for a week, then try this test again. Many people find dramatic improvement within days.", colorHex: "7A6030")
            default:
                resultCard("Don\u{2019}t tape yet. Focus on the Nose Unblocking exercise and Buteyko Reduced pattern daily. If you have a deviated septum or chronic congestion, consider seeing an ENT specialist. The goal is comfort, not force.", colorHex: "C4502A")
            }
        }
    }

    private var co2BuilderResult: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Your 5 Holds")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            ForEach(Array(viewModel.holdTimes.enumerated()), id: \.offset) { index, time in
                HStack {
                    Text("Round \(index + 1)")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textTertiary)
                    Spacer()
                    Text(String(format: "%.1fs", time))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                }
            }

            HairlineDivider()

            HStack {
                Text("Average")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textTertiary)
                Spacer()
                Text(String(format: "%.1fs", viewModel.averageHoldTime))
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.accent)
            }

            resultCard(viewModel.co2Trend, colorHex: viewModel.co2TrendColorHex)

            let tier = BOLTTier.from(score: viewModel.averageHoldTime)
            Text("Your average (\(String(format: "%.1f", viewModel.averageHoldTime))s) suggests a BOLT score in the \(tier.label) range")
                .font(.system(size: 11))
                .foregroundStyle(AppColors.textTertiary)
        }
    }

    private var altitudeHoldResult: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Your 5 Holds")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            ForEach(Array(viewModel.holdTimes.enumerated()), id: \.offset) { index, time in
                HStack {
                    Text("Round \(index + 1)")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textTertiary)
                    Spacer()
                    Text(String(format: "%.1fs", time))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                }
            }

            HairlineDivider()

            HStack {
                Text("Average")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textTertiary)
                Spacer()
                Text(String(format: "%.1fs", viewModel.averageHoldTime))
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.accent)
            }

            resultCard("High-altitude holds train both CO\u{2082} and O\u{2082} tolerance simultaneously. Consistent practice builds the dual stimulus that pure CO\u{2082} exercises miss.", colorHex: "2D5F5D")
        }
    }

    private var co2TableResult: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("CO\u{2082} Table Complete")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            if viewModel.ratingValue >= 4 {
                resultCard("You handled the shrinking rest periods well. Your chemoreceptors are adapting to higher CO\u{2082} levels. Try this 2\u{2013}3 times per week.", colorHex: "2D5F5D")
            } else if viewModel.ratingValue >= 2 {
                resultCard("Moderate difficulty is expected \u{2014} the last few rounds are designed to push your CO\u{2082} threshold. This gets easier with regular practice.", colorHex: "7A6030")
            } else {
                resultCard("The final rounds were very challenging. This is normal for beginners. Your chemoreceptors will adapt over 2\u{2013}3 weeks of regular practice.", colorHex: "C4502A")
            }
        }
    }

    private var breathHoldWalkResult: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Your 6 Walks")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            // tapCount for each round is not tracked per-round in the current ViewModel,
            // so we show overall completion
            resultCard("Walking during breath holds increases metabolic CO\u{2082} production, making each hold more effective than a static equivalent. Patrick McKeown considers this the single best exercise for improving your BOLT score.", colorHex: "2D5F5D")
        }
    }

    private var apneaPyramidResult: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Pyramid Complete")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            resultCard("The pyramid structure builds confidence on the way up and provides relief on the way down. The peak round (30s) is your current challenge threshold. As this gets easier, you can extend all durations.", colorHex: "2D5F5D")
        }
    }

    // MARK: - Result Card Helper

    private func resultCard(_ text: String, colorHex: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundStyle(AppColors.textPrimary)
            .lineSpacing(6)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: colorHex).opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: colorHex).opacity(0.12), lineWidth: 1)
            )
    }
}
#endif
