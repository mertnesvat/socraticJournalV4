// FictionalCharacter.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a fictional character from a franchise for personality matching
public struct FictionalCharacter: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let franchise: Franchise
    public let description: String
    public let imageAssetName: String?
    public let personalityTraits: [String]

    public init(
        id: String = UUID().uuidString,
        name: String,
        franchise: Franchise,
        description: String,
        imageAssetName: String? = nil,
        personalityTraits: [String]
    ) {
        self.id = id
        self.name = name
        self.franchise = franchise
        self.description = description
        self.imageAssetName = imageAssetName
        self.personalityTraits = personalityTraits
    }
}

// MARK: - Static Character Data

public extension FictionalCharacter {

    // MARK: - Lord of the Rings Characters

    static let aragorn = FictionalCharacter(
        id: "lotr_aragorn",
        name: "Aragorn",
        franchise: .lordOfTheRings,
        description: "The rightful heir to the throne of Gondor who spent years in exile as a Ranger, torn between his destiny and his fears of repeating his ancestors' failures.",
        imageAssetName: "character_aragorn",
        personalityTraits: ["leadership", "duty", "hidden identity", "nobility", "self-doubt", "courage"]
    )

    static let frodo = FictionalCharacter(
        id: "lotr_frodo",
        name: "Frodo",
        franchise: .lordOfTheRings,
        description: "A humble hobbit from the Shire who bears the weight of the One Ring, showing that even the smallest person can change the course of the world.",
        imageAssetName: "character_frodo",
        personalityTraits: ["burden-bearing", "resilience", "innocence", "compassion", "determination", "vulnerability"]
    )

    static let gandalf = FictionalCharacter(
        id: "lotr_gandalf",
        name: "Gandalf",
        franchise: .lordOfTheRings,
        description: "A wise wizard and guide who sees the potential in others and understands that true power lies in wisdom and sacrifice, not dominion.",
        imageAssetName: "character_gandalf",
        personalityTraits: ["wisdom", "guidance", "sacrifice", "patience", "mystery", "mentorship"]
    )

    static let sam = FictionalCharacter(
        id: "lotr_sam",
        name: "Samwise Gamgee",
        franchise: .lordOfTheRings,
        description: "Frodo's loyal gardener and friend whose simple courage and unwavering devotion prove to be the true strength that saves Middle-earth.",
        imageAssetName: "character_sam",
        personalityTraits: ["loyalty", "optimism", "humble courage", "devotion", "perseverance", "simplicity"]
    )

    static let boromir = FictionalCharacter(
        id: "lotr_boromir",
        name: "Boromir",
        franchise: .lordOfTheRings,
        description: "The proud warrior of Gondor who struggles with temptation but ultimately finds redemption through sacrifice and the protection of others.",
        imageAssetName: "character_boromir",
        personalityTraits: ["internal conflict", "redemption", "honor", "pride", "protectiveness", "vulnerability"]
    )

    static let legolas = FictionalCharacter(
        id: "lotr_legolas",
        name: "Legolas",
        franchise: .lordOfTheRings,
        description: "An elven prince whose grace and skill are matched only by his capacity for deep friendship across cultural divides.",
        imageAssetName: "character_legolas",
        personalityTraits: ["grace", "friendship", "skill", "perceptiveness", "adaptability", "loyalty"]
    )

    static let gimli = FictionalCharacter(
        id: "lotr_gimli",
        name: "Gimli",
        franchise: .lordOfTheRings,
        description: "A dwarf warrior whose stubbornness gives way to unexpected friendships, proving that bonds forged in adversity transcend old prejudices.",
        imageAssetName: "character_gimli",
        personalityTraits: ["stubbornness", "loyalty", "humor", "bravery", "pride", "openness to change"]
    )

    static let eowyn = FictionalCharacter(
        id: "lotr_eowyn",
        name: "Eowyn",
        franchise: .lordOfTheRings,
        description: "A shieldmaiden of Rohan who defies expectations, fighting against both external enemies and the cage of her prescribed role.",
        imageAssetName: "character_eowyn",
        personalityTraits: ["defiance", "hidden strength", "longing", "courage", "determination", "healing"]
    )

    static let galadriel = FictionalCharacter(
        id: "lotr_galadriel",
        name: "Galadriel",
        franchise: .lordOfTheRings,
        description: "An ancient elven queen whose power is tempered by wisdom gained through ages, understanding that true strength lies in what we refuse to take.",
        imageAssetName: "character_galadriel",
        personalityTraits: ["power", "temptation resistance", "ancient wisdom", "grace", "foresight", "restraint"]
    )

    // MARK: - Harry Potter Characters

    static let harry = FictionalCharacter(
        id: "hp_harry",
        name: "Harry Potter",
        franchise: .harryPotter,
        description: "The Boy Who Lived, marked by destiny but defined by his choices to love, sacrifice, and stand against darkness despite his fears.",
        imageAssetName: "character_harry",
        personalityTraits: ["bravery", "destiny", "sacrifice", "loyalty", "impulsiveness", "moral compass"]
    )

    static let hermione = FictionalCharacter(
        id: "hp_hermione",
        name: "Hermione Granger",
        franchise: .harryPotter,
        description: "A brilliant witch whose intellect is matched by her fierce loyalty and belief in fairness, proving that knowledge paired with heart is true power.",
        imageAssetName: "character_hermione",
        personalityTraits: ["intellect", "preparation", "loyalty", "justice", "perfectionism", "compassion"]
    )

    static let ron = FictionalCharacter(
        id: "hp_ron",
        name: "Ron Weasley",
        franchise: .harryPotter,
        description: "A loyal friend who struggles with feeling overshadowed but repeatedly proves his worth through humor, heart, and courage when it matters most.",
        imageAssetName: "character_ron",
        personalityTraits: ["friendship", "insecurity", "humor", "bravery", "loyalty", "authenticity"]
    )

    static let dumbledore = FictionalCharacter(
        id: "hp_dumbledore",
        name: "Albus Dumbledore",
        franchise: .harryPotter,
        description: "The wise headmaster whose past mistakes taught him that love is the greatest magic, even as he carries the burden of difficult choices.",
        imageAssetName: "character_dumbledore",
        personalityTraits: ["wisdom", "secrets", "greater good", "regret", "mentorship", "strategic thinking"]
    )

    static let snape = FictionalCharacter(
        id: "hp_snape",
        name: "Severus Snape",
        franchise: .harryPotter,
        description: "A complex figure whose bitter exterior hides a lifetime of sacrifice driven by love, proving that the bravest acts often go unseen.",
        imageAssetName: "character_snape",
        personalityTraits: ["complexity", "hidden depths", "redemption", "devotion", "bitterness", "sacrifice"]
    )

    static let luna = FictionalCharacter(
        id: "hp_luna",
        name: "Luna Lovegood",
        franchise: .harryPotter,
        description: "A uniquely perceptive witch who embraces her differences and sees truths others miss, teaching that authenticity is its own kind of magic.",
        imageAssetName: "character_luna",
        personalityTraits: ["uniqueness", "acceptance", "intuition", "kindness", "resilience", "open-mindedness"]
    )

    static let neville = FictionalCharacter(
        id: "hp_neville",
        name: "Neville Longbottom",
        franchise: .harryPotter,
        description: "A seemingly unremarkable boy who grows into a hero, proving that true courage is standing up even when you're most afraid.",
        imageAssetName: "character_neville",
        personalityTraits: ["growth", "courage", "underestimation", "determination", "loyalty", "hidden strength"]
    )

    // MARK: - Star Wars Characters

    static let luke = FictionalCharacter(
        id: "sw_luke",
        name: "Luke Skywalker",
        franchise: .starWars,
        description: "A farm boy who becomes a Jedi, embodying the belief that anyone can rise to greatness and that redemption is always possible.",
        imageAssetName: "character_luke",
        personalityTraits: ["hope", "growth", "redemption", "idealism", "determination", "compassion"]
    )

    static let leia = FictionalCharacter(
        id: "sw_leia",
        name: "Leia Organa",
        franchise: .starWars,
        description: "A princess turned general whose leadership and determination inspire a galaxy, balancing duty with compassion.",
        imageAssetName: "character_leia",
        personalityTraits: ["leadership", "determination", "compassion", "resilience", "diplomacy", "strength"]
    )

    static let hanSolo = FictionalCharacter(
        id: "sw_han",
        name: "Han Solo",
        franchise: .starWars,
        description: "A smuggler who pretends not to care but repeatedly proves that beneath the cynicism lies a heart of gold.",
        imageAssetName: "character_han",
        personalityTraits: ["charm", "independence", "hidden heart", "loyalty", "courage", "wit"]
    )

    static let obiWan = FictionalCharacter(
        id: "sw_obiwan",
        name: "Obi-Wan Kenobi",
        franchise: .starWars,
        description: "A Jedi Master whose dedication to duty and his student shapes the fate of the galaxy, carrying both wisdom and deep regret.",
        imageAssetName: "character_obiwan",
        personalityTraits: ["wisdom", "sacrifice", "duty", "patience", "regret", "mentorship"]
    )

    static let yoda = FictionalCharacter(
        id: "sw_yoda",
        name: "Yoda",
        franchise: .starWars,
        description: "An ancient Jedi Master whose centuries of experience have taught him that true wisdom lies in humility and perspective.",
        imageAssetName: "character_yoda",
        personalityTraits: ["patience", "teaching", "perspective", "humility", "wisdom", "serenity"]
    )

    static let anakin = FictionalCharacter(
        id: "sw_anakin",
        name: "Anakin Skywalker",
        franchise: .starWars,
        description: "The Chosen One whose passionate nature leads to both greatness and tragedy, ultimately finding redemption through love.",
        imageAssetName: "character_anakin",
        personalityTraits: ["passion", "conflict", "fall/redemption", "power", "love", "impulsiveness"]
    )

    static let rey = FictionalCharacter(
        id: "sw_rey",
        name: "Rey",
        franchise: .starWars,
        description: "A scavenger who discovers her connection to the Force and learns that belonging is not about lineage but about choice.",
        imageAssetName: "character_rey",
        personalityTraits: ["discovery", "belonging", "power", "resilience", "hope", "self-definition"]
    )

    // MARK: - Character Collections

    static let lordOfTheRingsCharacters: [FictionalCharacter] = [
        aragorn, frodo, gandalf, sam, boromir, legolas, gimli, eowyn, galadriel
    ]

    static let harryPotterCharacters: [FictionalCharacter] = [
        harry, hermione, ron, dumbledore, snape, luna, neville
    ]

    static let starWarsCharacters: [FictionalCharacter] = [
        luke, leia, hanSolo, obiWan, yoda, anakin, rey
    ]

    /// Returns all characters for a given franchise
    static func characters(for franchise: Franchise) -> [FictionalCharacter] {
        switch franchise {
        case .lordOfTheRings: return lordOfTheRingsCharacters
        case .harryPotter: return harryPotterCharacters
        case .starWars: return starWarsCharacters
        }
    }

    /// Returns all available characters across all franchises
    static var allCharacters: [FictionalCharacter] {
        lordOfTheRingsCharacters + harryPotterCharacters + starWarsCharacters
    }
}
