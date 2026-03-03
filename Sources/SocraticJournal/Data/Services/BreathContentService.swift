// BreathContentService.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

final class BreathContentService: BreathContentServiceProtocol, @unchecked Sendable {

    private let learningBits: [LearningBit] = [
        LearningBit(
            id: "1",
            title: "The Perfect Breath is 5.5 Seconds",
            body: "Researchers found that breathing at 5.5 breaths per minute creates 'coherence' — when heart, lungs, and circulation synchronize for peak efficiency. James Nestor calls this the perfect breath.",
            category: .science,
            sourceNote: "James Nestor, Breath"
        ),
        LearningBit(
            id: "2",
            title: "Prayers From Opposite Sides of the World",
            body: "Buddhist monks chanting Om Mani Padme Hum and Catholics reciting the rosary in Latin both breathe at exactly 5.5 breaths per minute. These traditions developed independently, yet converged on the same optimal rhythm.",
            category: .ancient,
            sourceNote: nil
        ),
        LearningBit(
            id: "3",
            title: "Your Nose Makes Medicine",
            body: "Your nasal sinuses produce nitric oxide — a gas that opens blood vessels, kills bacteria, and helps your lungs absorb oxygen. Mouth breathing bypasses this entirely. Humming increases nasal nitric oxide by 15x.",
            category: .nasal,
            sourceNote: nil
        ),
        LearningBit(
            id: "4",
            title: "We Are the Worst Breathers on Earth",
            body: "No other species suffers from chronic snoring, sleep apnea, or breathing dysfunction at the rates humans do. The shift to soft processed foods shrank our jaws and narrowed our airways over millennia.",
            category: .facts,
            sourceNote: nil
        ),
        LearningBit(
            id: "5",
            title: "10 Days of Mouth Breathing",
            body: "When James Nestor plugged his nose for 10 days, his blood pressure hit 142 (stage 2 hypertension), snoring increased 4,800%, and he averaged 25 sleep apnea events per night. Switching back to nasal breathing reversed it all.",
            category: .nasal,
            sourceNote: "James Nestor, Breath"
        ),
        LearningBit(
            id: "6",
            title: "The Navy SEAL Reset",
            body: "Box breathing has a 'neutral energetic effect' — it calms without sedating and focuses without winding you up. That's precisely why Navy SEALs chose it: in combat, you need to be calm AND sharp.",
            category: .techniques,
            sourceNote: nil
        ),
        LearningBit(
            id: "7",
            title: "Your Body Already Knows",
            body: "You perform 'physiological sighs' — double inhales — roughly every 5 minutes. Your body does this automatically to reinflate collapsed air sacs in your lungs. Stanford researchers turned this reflex into the cyclic sighing technique.",
            category: .science,
            sourceNote: "Stanford Medicine"
        ),
        LearningBit(
            id: "8",
            title: "Breath Changes Your Genes",
            body: "Controlled breathing can alter gene expression — activating genes for energy and insulin regulation while suppressing those linked to inflammation and stress.",
            category: .science,
            sourceNote: nil
        ),
        LearningBit(
            id: "9",
            title: "A Natural Tranquilizer",
            body: "Dr. Andrew Weil calls the 4-7-8 technique 'a natural tranquilizer for the nervous system.' The key: the exhale is twice the length of the inhale, maximally activating the vagus nerve.",
            category: .techniques,
            sourceNote: "Dr. Andrew Weil"
        ),
        LearningBit(
            id: "10",
            title: "25,000 Breaths a Day",
            body: "You breathe roughly 25,000 times daily — about 10,000 liters of air. Even small improvements to each breath compound into dramatic health changes over time.",
            category: .facts,
            sourceNote: nil
        ),
        LearningBit(
            id: "11",
            title: "Spirit, Prana, Pneuma",
            body: "The word 'spirit' comes from Latin 'spirare' — to breathe. In Sanskrit, 'prana' means both breath and life force. In Greek, 'pneuma' means both breath and soul. Every ancient culture saw breath as life itself.",
            category: .ancient,
            sourceNote: nil
        ),
        LearningBit(
            id: "12",
            title: "5 Minutes Beats Meditation",
            body: "A 2023 Stanford study found that 5 minutes of daily cyclic sighing produced greater mood improvements and anxiety reduction than 5 minutes of mindfulness meditation.",
            category: .science,
            sourceNote: "Stanford University, 2023"
        ),
        LearningBit(
            id: "13",
            title: "The Nasal Cycle",
            body: "Your nostrils alternate dominance every 2-4 hours — one opens while the other partially closes. This natural cycle is controlled by your autonomic nervous system and helps optimize air conditioning and immune defense.",
            category: .nasal,
            sourceNote: nil
        ),
        LearningBit(
            id: "14",
            title: "4,000 Years of Breathwork",
            body: "Breath practices appear across Taoism, Buddhism, Hinduism, Christianity, Yoga, Qigong, Shamanism, Sufism, and Native American traditions — spanning four millennia and every inhabited continent.",
            category: .ancient,
            sourceNote: nil
        ),
        LearningBit(
            id: "15",
            title: "The Oxygen Advantage",
            body: "Studies show blood oxygen levels are about 10% higher during nasal breathing compared to mouth breathing. Your nose warms, humidifies, and filters air — your mouth does none of these.",
            category: .nasal,
            sourceNote: nil
        )
    ]

    func getAllLearningBits() -> [LearningBit] {
        learningBits
    }

    func getLearningBitsForCategory(_ category: LearningCategory) -> [LearningBit] {
        learningBits.filter { $0.category == category }
    }
}
