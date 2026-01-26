// FictionalUniverse.swift
// SocraticJournal
// Copyright 2024 StudioNext

import Foundation

/// Represents a fictional universe containing characters for personality matching
public struct FictionalUniverse: Codable, Sendable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let icon: String  // SF Symbol name
    public let description: String
    public let characters: [FictionalCharacter]

    public init(
        id: String,
        name: String,
        icon: String,
        description: String,
        characters: [FictionalCharacter]
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.description = description
        self.characters = characters
    }

    /// Returns the number of characters in this universe
    public var characterCount: Int {
        characters.count
    }
}

// MARK: - Predefined Universes

public extension FictionalUniverse {
    /// All available fictional universes
    static let allUniverses: [FictionalUniverse] = [
        .lordOfTheRings,
        .harryPotter,
        .starWars,
        .marvel,
        .dcComics,
        .gameOfThrones,
        .narnia
    ]

    /// Lord of the Rings universe
    static let lordOfTheRings = FictionalUniverse(
        id: "lotr",
        name: "Lord of the Rings",
        icon: "book.closed.fill",
        description: "J.R.R. Tolkien's epic fantasy of hobbits, elves, and the quest to destroy the One Ring.",
        characters: [
            FictionalCharacter(
                id: "lotr-frodo",
                name: "Frodo Baggins",
                universe: "Lord of the Rings",
                description: "A humble hobbit who bears the terrible burden of the One Ring, showing extraordinary courage and resilience despite his small stature.",
                traits: ["humble", "resilient", "compassionate", "determined", "self-sacrificing"],
                imageAssetName: "frodo"
            ),
            FictionalCharacter(
                id: "lotr-aragorn",
                name: "Aragorn",
                universe: "Lord of the Rings",
                description: "The rightful heir to Gondor's throne who embraces his destiny after years of wandering, combining warrior prowess with wisdom and compassion.",
                traits: ["noble", "brave", "wise", "humble", "protective"],
                imageAssetName: "aragorn"
            ),
            FictionalCharacter(
                id: "lotr-gandalf",
                name: "Gandalf",
                universe: "Lord of the Rings",
                description: "A powerful wizard who guides the Fellowship with ancient wisdom, fierce loyalty, and a touch of humor.",
                traits: ["wise", "mysterious", "protective", "patient", "determined"],
                imageAssetName: "gandalf"
            ),
            FictionalCharacter(
                id: "lotr-legolas",
                name: "Legolas",
                universe: "Lord of the Rings",
                description: "An elven prince of the Woodland Realm, combining deadly archery skills with grace and an unexpected friendship with a dwarf.",
                traits: ["graceful", "loyal", "observant", "skilled", "calm"],
                imageAssetName: "legolas"
            ),
            FictionalCharacter(
                id: "lotr-gimli",
                name: "Gimli",
                universe: "Lord of the Rings",
                description: "A fierce dwarf warrior whose gruff exterior hides a loyal heart and surprising capacity for friendship across racial divides.",
                traits: ["fierce", "loyal", "stubborn", "honorable", "humorous"],
                imageAssetName: "gimli"
            ),
            FictionalCharacter(
                id: "lotr-boromir",
                name: "Boromir",
                universe: "Lord of the Rings",
                description: "The proud son of Gondor's steward, whose tragic fall to the Ring's temptation is redeemed by his final sacrifice.",
                traits: ["proud", "brave", "protective", "conflicted", "honorable"],
                imageAssetName: "boromir"
            ),
            FictionalCharacter(
                id: "lotr-sam",
                name: "Samwise Gamgee",
                universe: "Lord of the Rings",
                description: "Frodo's devoted gardener and companion, whose simple loyalty and unwavering hope prove essential to the quest's success.",
                traits: ["loyal", "steadfast", "optimistic", "humble", "brave"],
                imageAssetName: "sam"
            ),
            FictionalCharacter(
                id: "lotr-gollum",
                name: "Gollum",
                universe: "Lord of the Rings",
                description: "A creature corrupted by the Ring's power, torn between his obsession with 'the precious' and fleeting glimpses of his former self.",
                traits: ["obsessive", "cunning", "conflicted", "tragic", "survivor"],
                imageAssetName: "gollum"
            ),
            FictionalCharacter(
                id: "lotr-eowyn",
                name: "Eowyn",
                universe: "Lord of the Rings",
                description: "A shieldmaiden of Rohan who defies expectations to face the Witch-king, seeking glory and escape from a cage of duty.",
                traits: ["brave", "determined", "restless", "fierce", "noble"],
                imageAssetName: "eowyn"
            ),
            FictionalCharacter(
                id: "lotr-faramir",
                name: "Faramir",
                universe: "Lord of the Rings",
                description: "The scholarly younger son of Denethor, whose gentle wisdom and moral clarity contrast with his brother's martial pride.",
                traits: ["wise", "gentle", "noble", "thoughtful", "brave"],
                imageAssetName: "faramir"
            )
        ]
    )

    /// Harry Potter universe
    static let harryPotter = FictionalUniverse(
        id: "hp",
        name: "Harry Potter",
        icon: "wand.and.stars",
        description: "J.K. Rowling's magical world of witches, wizards, and the battle against dark forces at Hogwarts School.",
        characters: [
            FictionalCharacter(
                id: "hp-harry",
                name: "Harry Potter",
                universe: "Harry Potter",
                description: "The Boy Who Lived, marked by tragedy but defined by courage, loyalty to friends, and an instinct to protect others.",
                traits: ["brave", "loyal", "impulsive", "humble", "protective"],
                imageAssetName: "harry"
            ),
            FictionalCharacter(
                id: "hp-hermione",
                name: "Hermione Granger",
                universe: "Harry Potter",
                description: "The brightest witch of her age, whose intelligence and dedication to justice make her an invaluable friend and formidable opponent.",
                traits: ["intelligent", "determined", "loyal", "perfectionist", "compassionate"],
                imageAssetName: "hermione"
            ),
            FictionalCharacter(
                id: "hp-ron",
                name: "Ron Weasley",
                universe: "Harry Potter",
                description: "Harry's best friend, whose humor and heart overcome his insecurities to stand firm when it matters most.",
                traits: ["loyal", "humorous", "insecure", "brave", "kind"],
                imageAssetName: "ron"
            ),
            FictionalCharacter(
                id: "hp-dumbledore",
                name: "Albus Dumbledore",
                universe: "Harry Potter",
                description: "The wise headmaster of Hogwarts, whose brilliant mind and past mistakes inform his guidance of the next generation.",
                traits: ["wise", "mysterious", "compassionate", "strategic", "eccentric"],
                imageAssetName: "dumbledore"
            ),
            FictionalCharacter(
                id: "hp-snape",
                name: "Severus Snape",
                universe: "Harry Potter",
                description: "The complex Potions Master whose bitter exterior conceals a lifetime of sacrifice and undying love.",
                traits: ["complex", "brave", "bitter", "loyal", "misunderstood"],
                imageAssetName: "snape"
            ),
            FictionalCharacter(
                id: "hp-luna",
                name: "Luna Lovegood",
                universe: "Harry Potter",
                description: "An eccentric Ravenclaw whose unwavering authenticity and unique perspective bring comfort and wisdom to her friends.",
                traits: ["eccentric", "kind", "authentic", "perceptive", "calm"],
                imageAssetName: "luna"
            ),
            FictionalCharacter(
                id: "hp-neville",
                name: "Neville Longbottom",
                universe: "Harry Potter",
                description: "A seemingly timid student who transforms into a hero, proving that courage can grow from the most unlikely places.",
                traits: ["brave", "loyal", "humble", "determined", "kind"],
                imageAssetName: "neville"
            ),
            FictionalCharacter(
                id: "hp-draco",
                name: "Draco Malfoy",
                universe: "Harry Potter",
                description: "Harry's rival whose privileged upbringing and prejudice mask a young man struggling under impossible expectations.",
                traits: ["proud", "conflicted", "cunning", "insecure", "loyal"],
                imageAssetName: "draco"
            ),
            FictionalCharacter(
                id: "hp-hagrid",
                name: "Rubeus Hagrid",
                universe: "Harry Potter",
                description: "The gentle half-giant gamekeeper whose love for dangerous creatures matches his enormous heart and fierce loyalty.",
                traits: ["kind", "loyal", "nurturing", "enthusiastic", "protective"],
                imageAssetName: "hagrid"
            ),
            FictionalCharacter(
                id: "hp-mcgonagall",
                name: "Minerva McGonagall",
                universe: "Harry Potter",
                description: "The strict but fair Transfiguration professor whose stern exterior conceals deep care for her students.",
                traits: ["strict", "fair", "brave", "loyal", "wise"],
                imageAssetName: "mcgonagall"
            )
        ]
    )

    /// Star Wars universe
    static let starWars = FictionalUniverse(
        id: "sw",
        name: "Star Wars",
        icon: "sparkles",
        description: "George Lucas's space opera saga of Jedi, Sith, and the eternal struggle between light and dark.",
        characters: [
            FictionalCharacter(
                id: "sw-luke",
                name: "Luke Skywalker",
                universe: "Star Wars",
                description: "A farm boy who becomes a legendary Jedi, embodying hope and the belief that anyone can be redeemed.",
                traits: ["hopeful", "brave", "idealistic", "compassionate", "determined"],
                imageAssetName: "luke"
            ),
            FictionalCharacter(
                id: "sw-leia",
                name: "Princess Leia",
                universe: "Star Wars",
                description: "A fearless leader of the Rebellion whose strength, wit, and dedication inspire those around her.",
                traits: ["brave", "determined", "witty", "compassionate", "leader"],
                imageAssetName: "leia"
            ),
            FictionalCharacter(
                id: "sw-han",
                name: "Han Solo",
                universe: "Star Wars",
                description: "A charming smuggler whose roguish exterior conceals a hero waiting to emerge.",
                traits: ["charming", "brave", "independent", "loyal", "resourceful"],
                imageAssetName: "han"
            ),
            FictionalCharacter(
                id: "sw-obiwan",
                name: "Obi-Wan Kenobi",
                universe: "Star Wars",
                description: "A wise Jedi Master whose patience and dedication to the light side guide the next generation of heroes.",
                traits: ["wise", "patient", "noble", "selfless", "mentor"],
                imageAssetName: "obiwan"
            ),
            FictionalCharacter(
                id: "sw-yoda",
                name: "Yoda",
                universe: "Star Wars",
                description: "The ancient Jedi Grand Master whose centuries of wisdom are delivered with distinctive speech and surprising humor.",
                traits: ["wise", "patient", "mysterious", "powerful", "humble"],
                imageAssetName: "yoda"
            ),
            FictionalCharacter(
                id: "sw-vader",
                name: "Darth Vader",
                universe: "Star Wars",
                description: "The fallen Jedi whose redemption proves that even the darkest path can lead back to the light.",
                traits: ["powerful", "conflicted", "tragic", "intimidating", "redeemable"],
                imageAssetName: "vader"
            ),
            FictionalCharacter(
                id: "sw-rey",
                name: "Rey",
                universe: "Star Wars",
                description: "A scavenger from Jakku who discovers her connection to the Force and chooses her own destiny.",
                traits: ["determined", "resourceful", "compassionate", "conflicted", "hopeful"],
                imageAssetName: "rey"
            ),
            FictionalCharacter(
                id: "sw-kylo",
                name: "Kylo Ren",
                universe: "Star Wars",
                description: "Ben Solo's dark alter ego, torn between family legacy and the seductive pull of the dark side.",
                traits: ["conflicted", "powerful", "emotional", "ambitious", "redeemable"],
                imageAssetName: "kylo"
            ),
            FictionalCharacter(
                id: "sw-ahsoka",
                name: "Ahsoka Tano",
                universe: "Star Wars",
                description: "Anakin's former padawan who walks her own path, embodying wisdom gained through hard experience.",
                traits: ["independent", "wise", "brave", "skilled", "compassionate"],
                imageAssetName: "ahsoka"
            ),
            FictionalCharacter(
                id: "sw-mandalorian",
                name: "The Mandalorian",
                universe: "Star Wars",
                description: "A lone bounty hunter whose adherence to 'the Way' is challenged by an unexpected bond with a mysterious child.",
                traits: ["honorable", "protective", "skilled", "stoic", "loyal"],
                imageAssetName: "mandalorian"
            )
        ]
    )

    /// Marvel universe
    static let marvel = FictionalUniverse(
        id: "marvel",
        name: "Marvel",
        icon: "bolt.fill",
        description: "Marvel's universe of extraordinary heroes facing cosmic threats while dealing with very human struggles.",
        characters: [
            FictionalCharacter(
                id: "marvel-ironman",
                name: "Tony Stark / Iron Man",
                universe: "Marvel",
                description: "A genius billionaire whose ego and wit mask deep insecurities, ultimately sacrificing everything to save the universe.",
                traits: ["genius", "witty", "arrogant", "heroic", "innovative"],
                imageAssetName: "ironman"
            ),
            FictionalCharacter(
                id: "marvel-cap",
                name: "Steve Rogers / Captain America",
                universe: "Marvel",
                description: "The super-soldier from another era whose unwavering moral compass inspires others to be their best selves.",
                traits: ["noble", "brave", "loyal", "stubborn", "inspiring"],
                imageAssetName: "captainamerica"
            ),
            FictionalCharacter(
                id: "marvel-thor",
                name: "Thor",
                universe: "Marvel",
                description: "The God of Thunder whose journey from arrogant prince to worthy hero teaches him that power comes from within.",
                traits: ["powerful", "noble", "brave", "humorous", "evolving"],
                imageAssetName: "thor"
            ),
            FictionalCharacter(
                id: "marvel-widow",
                name: "Natasha Romanoff / Black Widow",
                universe: "Marvel",
                description: "A former assassin seeking redemption, whose tactical genius and fierce loyalty make her the Avengers' secret weapon.",
                traits: ["strategic", "loyal", "brave", "secretive", "resourceful"],
                imageAssetName: "blackwidow"
            ),
            FictionalCharacter(
                id: "marvel-spiderman",
                name: "Peter Parker / Spider-Man",
                universe: "Marvel",
                description: "A young hero learning that with great power comes great responsibility, balancing superheroics with everyday life.",
                traits: ["responsible", "witty", "compassionate", "brave", "youthful"],
                imageAssetName: "spiderman"
            ),
            FictionalCharacter(
                id: "marvel-hulk",
                name: "Bruce Banner / Hulk",
                universe: "Marvel",
                description: "A brilliant scientist whose inner rage transforms him into an unstoppable force, struggling to find balance.",
                traits: ["intelligent", "conflicted", "powerful", "gentle", "protective"],
                imageAssetName: "hulk"
            ),
            FictionalCharacter(
                id: "marvel-panther",
                name: "T'Challa / Black Panther",
                universe: "Marvel",
                description: "Wakanda's king and protector, balancing tradition with progress while carrying the weight of his nation.",
                traits: ["noble", "wise", "brave", "honorable", "leader"],
                imageAssetName: "blackpanther"
            ),
            FictionalCharacter(
                id: "marvel-scarlet",
                name: "Wanda Maximoff / Scarlet Witch",
                universe: "Marvel",
                description: "One of the most powerful beings alive, whose grief and trauma shape reality itself.",
                traits: ["powerful", "emotional", "protective", "tragic", "loving"],
                imageAssetName: "scarletwitch"
            ),
            FictionalCharacter(
                id: "marvel-strange",
                name: "Stephen Strange / Doctor Strange",
                universe: "Marvel",
                description: "A former surgeon turned Sorcerer Supreme, whose arrogance is tempered by his duty to protect reality.",
                traits: ["intelligent", "arrogant", "dedicated", "strategic", "brave"],
                imageAssetName: "doctorstrange"
            ),
            FictionalCharacter(
                id: "marvel-groot",
                name: "Groot",
                universe: "Marvel",
                description: "A sentient tree whose limited vocabulary belies a gentle soul and fierce protectiveness of his friends.",
                traits: ["gentle", "loyal", "protective", "innocent", "brave"],
                imageAssetName: "groot"
            )
        ]
    )

    /// DC Comics universe
    static let dcComics = FictionalUniverse(
        id: "dc",
        name: "DC Comics",
        icon: "shield.fill",
        description: "DC's universe of iconic heroes and villains, exploring the nature of justice, power, and humanity.",
        characters: [
            FictionalCharacter(
                id: "dc-batman",
                name: "Bruce Wayne / Batman",
                universe: "DC Comics",
                description: "The Dark Knight who channels childhood trauma into an obsessive war on crime, proving that humanity can stand among gods.",
                traits: ["determined", "strategic", "brooding", "resourceful", "protective"],
                imageAssetName: "batman"
            ),
            FictionalCharacter(
                id: "dc-superman",
                name: "Clark Kent / Superman",
                universe: "DC Comics",
                description: "The Last Son of Krypton whose godlike powers are matched only by his humanity and moral clarity.",
                traits: ["noble", "hopeful", "powerful", "compassionate", "inspiring"],
                imageAssetName: "superman"
            ),
            FictionalCharacter(
                id: "dc-wonderwoman",
                name: "Diana Prince / Wonder Woman",
                universe: "DC Comics",
                description: "An Amazonian warrior princess whose strength is matched by her compassion and unwavering belief in humanity's potential.",
                traits: ["brave", "compassionate", "wise", "powerful", "noble"],
                imageAssetName: "wonderwoman"
            ),
            FictionalCharacter(
                id: "dc-aquaman",
                name: "Arthur Curry / Aquaman",
                universe: "DC Comics",
                description: "The King of Atlantis, bridging two worlds while embracing his identity as both human and Atlantean.",
                traits: ["brave", "conflicted", "powerful", "honorable", "leader"],
                imageAssetName: "aquaman"
            ),
            FictionalCharacter(
                id: "dc-flash",
                name: "Barry Allen / The Flash",
                universe: "DC Comics",
                description: "The Fastest Man Alive, whose optimism and desire to help everyone make him the heart of the Justice League.",
                traits: ["optimistic", "quick-witted", "compassionate", "brave", "selfless"],
                imageAssetName: "flash"
            ),
            FictionalCharacter(
                id: "dc-greenlantern",
                name: "Hal Jordan / Green Lantern",
                universe: "DC Comics",
                description: "A fearless test pilot chosen to wield the universe's most powerful weapon, limited only by imagination and willpower.",
                traits: ["fearless", "willful", "brave", "cocky", "heroic"],
                imageAssetName: "greenlantern"
            ),
            FictionalCharacter(
                id: "dc-joker",
                name: "The Joker",
                universe: "DC Comics",
                description: "Batman's chaotic nemesis whose unpredictable madness challenges everything the Dark Knight stands for.",
                traits: ["chaotic", "intelligent", "unpredictable", "theatrical", "obsessive"],
                imageAssetName: "joker"
            ),
            FictionalCharacter(
                id: "dc-harley",
                name: "Harley Quinn",
                universe: "DC Comics",
                description: "A former psychiatrist turned chaotic antihero, finding her own identity beyond toxic relationships.",
                traits: ["unpredictable", "intelligent", "loyal", "chaotic", "resilient"],
                imageAssetName: "harleyquinn"
            ),
            FictionalCharacter(
                id: "dc-alfred",
                name: "Alfred Pennyworth",
                universe: "DC Comics",
                description: "Bruce Wayne's butler, father figure, and moral compass, keeping the Dark Knight grounded in his humanity.",
                traits: ["loyal", "wise", "witty", "supportive", "brave"],
                imageAssetName: "alfred"
            ),
            FictionalCharacter(
                id: "dc-catwoman",
                name: "Selina Kyle / Catwoman",
                universe: "DC Comics",
                description: "A skilled thief whose moral flexibility and complex relationship with Batman blur the line between hero and villain.",
                traits: ["cunning", "independent", "seductive", "resourceful", "complex"],
                imageAssetName: "catwoman"
            )
        ]
    )

    /// Game of Thrones universe
    static let gameOfThrones = FictionalUniverse(
        id: "got",
        name: "Game of Thrones",
        icon: "crown.fill",
        description: "George R.R. Martin's brutal fantasy world where noble houses vie for power and winter is always coming.",
        characters: [
            FictionalCharacter(
                id: "got-jon",
                name: "Jon Snow",
                universe: "Game of Thrones",
                description: "A bastard who rises to become King in the North, embodying honor even when it costs him everything.",
                traits: ["honorable", "brave", "humble", "conflicted", "leader"],
                imageAssetName: "jonsnow"
            ),
            FictionalCharacter(
                id: "got-daenerys",
                name: "Daenerys Targaryen",
                universe: "Game of Thrones",
                description: "The Mother of Dragons whose journey from exile to conqueror explores the corrupting nature of power.",
                traits: ["determined", "powerful", "compassionate", "fierce", "ambitious"],
                imageAssetName: "daenerys"
            ),
            FictionalCharacter(
                id: "got-tyrion",
                name: "Tyrion Lannister",
                universe: "Game of Thrones",
                description: "The clever dwarf whose wit and political acumen help him survive in a family that despises him.",
                traits: ["intelligent", "witty", "compassionate", "strategic", "survivor"],
                imageAssetName: "tyrion"
            ),
            FictionalCharacter(
                id: "got-arya",
                name: "Arya Stark",
                universe: "Game of Thrones",
                description: "A young girl transformed into a deadly assassin by trauma, seeking vengeance while losing herself.",
                traits: ["fierce", "determined", "independent", "brave", "vengeful"],
                imageAssetName: "arya"
            ),
            FictionalCharacter(
                id: "got-cersei",
                name: "Cersei Lannister",
                universe: "Game of Thrones",
                description: "A ruthless queen whose love for her children drives her to increasingly desperate and cruel acts.",
                traits: ["ambitious", "ruthless", "cunning", "protective", "proud"],
                imageAssetName: "cersei"
            ),
            FictionalCharacter(
                id: "got-jaime",
                name: "Jaime Lannister",
                universe: "Game of Thrones",
                description: "The Kingslayer whose journey from reviled oath-breaker to reluctant hero redefines redemption.",
                traits: ["brave", "conflicted", "honorable", "complex", "evolving"],
                imageAssetName: "jaime"
            ),
            FictionalCharacter(
                id: "got-sansa",
                name: "Sansa Stark",
                universe: "Game of Thrones",
                description: "A naive girl hardened by suffering into a shrewd political player and eventual Queen in the North.",
                traits: ["resilient", "strategic", "patient", "determined", "leader"],
                imageAssetName: "sansa"
            ),
            FictionalCharacter(
                id: "got-brienne",
                name: "Brienne of Tarth",
                universe: "Game of Thrones",
                description: "A warrior woman whose unwavering honor and loyalty make her one of the realm's truest knights.",
                traits: ["honorable", "loyal", "brave", "determined", "noble"],
                imageAssetName: "brienne"
            ),
            FictionalCharacter(
                id: "got-hound",
                name: "Sandor Clegane / The Hound",
                universe: "Game of Thrones",
                description: "A scarred warrior whose brutal exterior conceals unexpected depths of honor and reluctant heroism.",
                traits: ["brutal", "honest", "protective", "cynical", "redeemable"],
                imageAssetName: "thehound"
            ),
            FictionalCharacter(
                id: "got-varys",
                name: "Lord Varys",
                universe: "Game of Thrones",
                description: "The Spider whose network of spies serves his genuine desire for a peaceful realm, regardless of who rules.",
                traits: ["intelligent", "mysterious", "strategic", "patient", "idealistic"],
                imageAssetName: "varys"
            )
        ]
    )

    /// Narnia universe
    static let narnia = FictionalUniverse(
        id: "narnia",
        name: "The Chronicles of Narnia",
        icon: "door.left.hand.open",
        description: "C.S. Lewis's magical land beyond the wardrobe, where talking animals and ancient magic shape destiny.",
        characters: [
            FictionalCharacter(
                id: "narnia-aslan",
                name: "Aslan",
                universe: "The Chronicles of Narnia",
                description: "The great lion and true king of Narnia, whose wild nature embodies wisdom, sacrifice, and resurrection.",
                traits: ["wise", "powerful", "compassionate", "mysterious", "noble"],
                imageAssetName: "aslan"
            ),
            FictionalCharacter(
                id: "narnia-peter",
                name: "Peter Pevensie",
                universe: "The Chronicles of Narnia",
                description: "The eldest Pevensie who becomes High King, learning to balance leadership with humility.",
                traits: ["brave", "noble", "protective", "leader", "responsible"],
                imageAssetName: "peter"
            ),
            FictionalCharacter(
                id: "narnia-susan",
                name: "Susan Pevensie",
                universe: "The Chronicles of Narnia",
                description: "The gentle queen whose practicality sometimes conflicts with Narnia's magic, eventually losing her way.",
                traits: ["practical", "gentle", "protective", "logical", "cautious"],
                imageAssetName: "susan"
            ),
            FictionalCharacter(
                id: "narnia-edmund",
                name: "Edmund Pevensie",
                universe: "The Chronicles of Narnia",
                description: "A boy whose early betrayal leads to profound redemption, becoming the just king who understands mercy.",
                traits: ["redeemed", "just", "wise", "brave", "humble"],
                imageAssetName: "edmund"
            ),
            FictionalCharacter(
                id: "narnia-lucy",
                name: "Lucy Pevensie",
                universe: "The Chronicles of Narnia",
                description: "The youngest Pevensie whose pure faith and courage first discover Narnia and maintain the strongest connection to Aslan.",
                traits: ["faithful", "brave", "joyful", "perceptive", "kind"],
                imageAssetName: "lucy"
            ),
            FictionalCharacter(
                id: "narnia-witch",
                name: "The White Witch",
                universe: "The Chronicles of Narnia",
                description: "The false queen whose eternal winter symbolizes the cold grip of evil over a land awaiting its true king.",
                traits: ["cruel", "powerful", "cunning", "cold", "ambitious"],
                imageAssetName: "whitewitch"
            ),
            FictionalCharacter(
                id: "narnia-reepicheep",
                name: "Reepicheep",
                universe: "The Chronicles of Narnia",
                description: "A valiant mouse knight whose courage far exceeds his size, seeking Aslan's country with unwavering faith.",
                traits: ["brave", "honorable", "faithful", "fierce", "noble"],
                imageAssetName: "reepicheep"
            ),
            FictionalCharacter(
                id: "narnia-tumnus",
                name: "Mr. Tumnus",
                universe: "The Chronicles of Narnia",
                description: "A faun whose kindness overcomes his fear, becoming Lucy's first friend and Narnia's symbol of resistance.",
                traits: ["kind", "gentle", "brave", "loyal", "conflicted"],
                imageAssetName: "tumnus"
            ),
            FictionalCharacter(
                id: "narnia-caspian",
                name: "Prince Caspian",
                universe: "The Chronicles of Narnia",
                description: "A young prince who restores Old Narnia, learning that true kingship requires wisdom and humility.",
                traits: ["noble", "brave", "humble", "curious", "leader"],
                imageAssetName: "caspian"
            ),
            FictionalCharacter(
                id: "narnia-puddleglum",
                name: "Puddleglum",
                universe: "The Chronicles of Narnia",
                description: "A pessimistic Marsh-wiggle whose gloomy outlook conceals deep courage and unwavering faith when it matters most.",
                traits: ["pessimistic", "loyal", "brave", "faithful", "wise"],
                imageAssetName: "puddleglum"
            )
        ]
    )
}
