import { getOpenAIClient } from "./openai";

/**
 * Supported fictional universes for character matching.
 */
export const SUPPORTED_UNIVERSES = [
  "lotr",       // Lord of the Rings
  "hp",         // Harry Potter
  "sw",         // Star Wars
  "marvel",     // Marvel
  "dc",         // DC Comics
  "got",        // Game of Thrones
  "narnia",     // The Chronicles of Narnia
] as const;

export type UniverseId = typeof SUPPORTED_UNIVERSES[number];

/**
 * Universe display names for prompts.
 */
export const UNIVERSE_NAMES: Record<UniverseId, string> = {
  lotr: "Lord of the Rings",
  hp: "Harry Potter",
  sw: "Star Wars",
  marvel: "Marvel",
  dc: "DC Comics",
  got: "Game of Thrones",
  narnia: "The Chronicles of Narnia",
};

/**
 * Request interface for character matching.
 */
export interface CharacterMatchRequest {
  journalEntries: Array<{
    question: string;
    answer: string;
    clarityMirror?: string;
  }>;
  universeId: UniverseId;
}

/**
 * Journal excerpt used as evidence for the character match.
 */
export interface JournalExcerpt {
  /** The excerpt text from the user's answer */
  text: string;
  /** Brief explanation of how this excerpt supports the match */
  relevance: string;
}

/**
 * Individual character match result.
 */
export interface CharacterMatch {
  /** Character name */
  characterName: string;
  /** Character ID from the universe */
  characterId: string;
  /** Confidence as decimal (0.0-1.0) - will be displayed as percentage in UI */
  confidence: number;
  /** Reasoning explaining why this character matches */
  reasoning: string;
  /** Key traits that align with the user's journal entries */
  matchingTraits: string[];
  /** Excerpts from journal entries that support this match */
  excerpts: JournalExcerpt[];
}

/**
 * Response from character matching.
 */
export interface CharacterMatchResponse {
  /** The single best character match */
  match: CharacterMatch;
  /** The universe analyzed */
  universe: string;
  /** Summary of the analysis approach */
  analysisSummary: string;
  /** ISO timestamp of when analysis was performed */
  analyzedAt: string;
}

/**
 * Character data for each universe (used in the prompt).
 * Maps to the FictionalCharacter model in the iOS app.
 */
const UNIVERSE_CHARACTERS: Record<UniverseId, Array<{ id: string; name: string; traits: string[] }>> = {
  lotr: [
    { id: "lotr-frodo", name: "Frodo Baggins", traits: ["humble", "resilient", "compassionate", "determined", "self-sacrificing"] },
    { id: "lotr-aragorn", name: "Aragorn", traits: ["noble", "brave", "wise", "humble", "protective"] },
    { id: "lotr-gandalf", name: "Gandalf", traits: ["wise", "mysterious", "protective", "patient", "determined"] },
    { id: "lotr-legolas", name: "Legolas", traits: ["graceful", "loyal", "observant", "skilled", "calm"] },
    { id: "lotr-gimli", name: "Gimli", traits: ["fierce", "loyal", "stubborn", "honorable", "humorous"] },
    { id: "lotr-boromir", name: "Boromir", traits: ["proud", "brave", "protective", "conflicted", "honorable"] },
    { id: "lotr-sam", name: "Samwise Gamgee", traits: ["loyal", "steadfast", "optimistic", "humble", "brave"] },
    { id: "lotr-gollum", name: "Gollum", traits: ["obsessive", "cunning", "conflicted", "tragic", "survivor"] },
    { id: "lotr-eowyn", name: "Eowyn", traits: ["brave", "determined", "restless", "fierce", "noble"] },
    { id: "lotr-faramir", name: "Faramir", traits: ["wise", "gentle", "noble", "thoughtful", "brave"] },
  ],
  hp: [
    { id: "hp-harry", name: "Harry Potter", traits: ["brave", "loyal", "impulsive", "humble", "protective"] },
    { id: "hp-hermione", name: "Hermione Granger", traits: ["intelligent", "determined", "loyal", "perfectionist", "compassionate"] },
    { id: "hp-ron", name: "Ron Weasley", traits: ["loyal", "humorous", "insecure", "brave", "kind"] },
    { id: "hp-dumbledore", name: "Albus Dumbledore", traits: ["wise", "mysterious", "compassionate", "strategic", "eccentric"] },
    { id: "hp-snape", name: "Severus Snape", traits: ["complex", "brave", "bitter", "loyal", "misunderstood"] },
    { id: "hp-luna", name: "Luna Lovegood", traits: ["eccentric", "kind", "authentic", "perceptive", "calm"] },
    { id: "hp-neville", name: "Neville Longbottom", traits: ["brave", "loyal", "humble", "determined", "kind"] },
    { id: "hp-draco", name: "Draco Malfoy", traits: ["proud", "conflicted", "cunning", "insecure", "loyal"] },
    { id: "hp-hagrid", name: "Rubeus Hagrid", traits: ["kind", "loyal", "nurturing", "enthusiastic", "protective"] },
    { id: "hp-mcgonagall", name: "Minerva McGonagall", traits: ["strict", "fair", "brave", "loyal", "wise"] },
  ],
  sw: [
    { id: "sw-luke", name: "Luke Skywalker", traits: ["hopeful", "brave", "idealistic", "compassionate", "determined"] },
    { id: "sw-leia", name: "Princess Leia", traits: ["brave", "determined", "witty", "compassionate", "leader"] },
    { id: "sw-han", name: "Han Solo", traits: ["charming", "brave", "independent", "loyal", "resourceful"] },
    { id: "sw-obiwan", name: "Obi-Wan Kenobi", traits: ["wise", "patient", "noble", "selfless", "mentor"] },
    { id: "sw-yoda", name: "Yoda", traits: ["wise", "patient", "mysterious", "powerful", "humble"] },
    { id: "sw-vader", name: "Darth Vader", traits: ["powerful", "conflicted", "tragic", "intimidating", "redeemable"] },
    { id: "sw-rey", name: "Rey", traits: ["determined", "resourceful", "compassionate", "conflicted", "hopeful"] },
    { id: "sw-kylo", name: "Kylo Ren", traits: ["conflicted", "powerful", "emotional", "ambitious", "redeemable"] },
    { id: "sw-ahsoka", name: "Ahsoka Tano", traits: ["independent", "wise", "brave", "skilled", "compassionate"] },
    { id: "sw-mandalorian", name: "The Mandalorian", traits: ["honorable", "protective", "skilled", "stoic", "loyal"] },
  ],
  marvel: [
    { id: "marvel-ironman", name: "Tony Stark / Iron Man", traits: ["genius", "witty", "arrogant", "heroic", "innovative"] },
    { id: "marvel-cap", name: "Steve Rogers / Captain America", traits: ["noble", "brave", "loyal", "stubborn", "inspiring"] },
    { id: "marvel-thor", name: "Thor", traits: ["powerful", "noble", "brave", "humorous", "evolving"] },
    { id: "marvel-widow", name: "Natasha Romanoff / Black Widow", traits: ["strategic", "loyal", "brave", "secretive", "resourceful"] },
    { id: "marvel-spiderman", name: "Peter Parker / Spider-Man", traits: ["responsible", "witty", "compassionate", "brave", "youthful"] },
    { id: "marvel-hulk", name: "Bruce Banner / Hulk", traits: ["intelligent", "conflicted", "powerful", "gentle", "protective"] },
    { id: "marvel-panther", name: "T'Challa / Black Panther", traits: ["noble", "wise", "brave", "honorable", "leader"] },
    { id: "marvel-scarlet", name: "Wanda Maximoff / Scarlet Witch", traits: ["powerful", "emotional", "protective", "tragic", "loving"] },
    { id: "marvel-strange", name: "Stephen Strange / Doctor Strange", traits: ["intelligent", "arrogant", "dedicated", "strategic", "brave"] },
    { id: "marvel-groot", name: "Groot", traits: ["gentle", "loyal", "protective", "innocent", "brave"] },
  ],
  dc: [
    { id: "dc-batman", name: "Bruce Wayne / Batman", traits: ["determined", "strategic", "brooding", "resourceful", "protective"] },
    { id: "dc-superman", name: "Clark Kent / Superman", traits: ["noble", "hopeful", "powerful", "compassionate", "inspiring"] },
    { id: "dc-wonderwoman", name: "Diana Prince / Wonder Woman", traits: ["brave", "compassionate", "wise", "powerful", "noble"] },
    { id: "dc-aquaman", name: "Arthur Curry / Aquaman", traits: ["brave", "conflicted", "powerful", "honorable", "leader"] },
    { id: "dc-flash", name: "Barry Allen / The Flash", traits: ["optimistic", "quick-witted", "compassionate", "brave", "selfless"] },
    { id: "dc-greenlantern", name: "Hal Jordan / Green Lantern", traits: ["fearless", "willful", "brave", "cocky", "heroic"] },
    { id: "dc-joker", name: "The Joker", traits: ["chaotic", "intelligent", "unpredictable", "theatrical", "obsessive"] },
    { id: "dc-harley", name: "Harley Quinn", traits: ["unpredictable", "intelligent", "loyal", "chaotic", "resilient"] },
    { id: "dc-alfred", name: "Alfred Pennyworth", traits: ["loyal", "wise", "witty", "supportive", "brave"] },
    { id: "dc-catwoman", name: "Selina Kyle / Catwoman", traits: ["cunning", "independent", "seductive", "resourceful", "complex"] },
  ],
  got: [
    { id: "got-jon", name: "Jon Snow", traits: ["honorable", "brave", "humble", "conflicted", "leader"] },
    { id: "got-daenerys", name: "Daenerys Targaryen", traits: ["determined", "powerful", "compassionate", "fierce", "ambitious"] },
    { id: "got-tyrion", name: "Tyrion Lannister", traits: ["intelligent", "witty", "compassionate", "strategic", "survivor"] },
    { id: "got-arya", name: "Arya Stark", traits: ["fierce", "determined", "independent", "brave", "vengeful"] },
    { id: "got-cersei", name: "Cersei Lannister", traits: ["ambitious", "ruthless", "cunning", "protective", "proud"] },
    { id: "got-jaime", name: "Jaime Lannister", traits: ["brave", "conflicted", "honorable", "complex", "evolving"] },
    { id: "got-sansa", name: "Sansa Stark", traits: ["resilient", "strategic", "patient", "determined", "leader"] },
    { id: "got-brienne", name: "Brienne of Tarth", traits: ["honorable", "loyal", "brave", "determined", "noble"] },
    { id: "got-hound", name: "Sandor Clegane / The Hound", traits: ["brutal", "honest", "protective", "cynical", "redeemable"] },
    { id: "got-varys", name: "Lord Varys", traits: ["intelligent", "mysterious", "strategic", "patient", "idealistic"] },
  ],
  narnia: [
    { id: "narnia-aslan", name: "Aslan", traits: ["wise", "powerful", "compassionate", "mysterious", "noble"] },
    { id: "narnia-peter", name: "Peter Pevensie", traits: ["brave", "noble", "protective", "leader", "responsible"] },
    { id: "narnia-susan", name: "Susan Pevensie", traits: ["practical", "gentle", "protective", "logical", "cautious"] },
    { id: "narnia-edmund", name: "Edmund Pevensie", traits: ["redeemed", "just", "wise", "brave", "humble"] },
    { id: "narnia-lucy", name: "Lucy Pevensie", traits: ["faithful", "brave", "joyful", "perceptive", "kind"] },
    { id: "narnia-witch", name: "The White Witch", traits: ["cruel", "powerful", "cunning", "cold", "ambitious"] },
    { id: "narnia-reepicheep", name: "Reepicheep", traits: ["brave", "honorable", "faithful", "fierce", "noble"] },
    { id: "narnia-tumnus", name: "Mr. Tumnus", traits: ["kind", "gentle", "brave", "loyal", "conflicted"] },
    { id: "narnia-caspian", name: "Prince Caspian", traits: ["noble", "brave", "humble", "curious", "leader"] },
    { id: "narnia-puddleglum", name: "Puddleglum", traits: ["pessimistic", "loyal", "brave", "faithful", "wise"] },
  ],
};

/**
 * System prompt for fictional character matching.
 */
export const CHARACTER_MATCH_SYSTEM_PROMPT = `You are a personality analysis expert specializing in matching real people to fictional characters based on journal entries from a Socratic journaling app.

## Your Task

Analyze the user's journal entries to identify personality patterns, values, emotional themes, and behavioral tendencies. Then match them to the SINGLE most fitting fictional character from the specified universe.

## Analysis Approach

1. **Identify Core Themes**: Look for recurring topics, concerns, and interests in the journal entries
2. **Detect Emotional Patterns**: Note how the person processes emotions, handles challenges, and relates to others
3. **Find Value Indicators**: What matters most to them? What do they prioritize?
4. **Behavioral Tendencies**: How do they approach problems? Are they impulsive or thoughtful? Leaders or supporters?
5. **Compare to Characters**: Match these patterns to character traits, considering character growth arcs and core motivations

## Matching Guidelines

1. **Be specific**: You MUST cite actual quotes from the journal entries as excerpts
2. **Consider nuance**: Characters have multiple dimensions - match the whole person, not just one trait
3. **Assign realistic confidence**: Use decimal format (0.0 to 1.0). Only use 0.90+ if there's overwhelming evidence
4. **Make it meaningful**: The reasoning should help the user understand themselves better
5. **Provide evidence**: Include 2-3 specific excerpts from their journal that support your match

## Confidence Guidelines (decimal format 0.0-1.0)

- 0.85-1.0: Strong, clear alignment with multiple journal themes
- 0.70-0.84: Good alignment with several key traits
- 0.55-0.69: Moderate alignment, some traits match well
- 0.40-0.54: Partial alignment, few matching traits

## Response Format

You MUST respond with valid JSON matching this exact structure:
{
  "match": {
    "characterName": "<full character name>",
    "characterId": "<character id from the list>",
    "confidence": <decimal number 0.0-1.0, e.g., 0.85>,
    "reasoning": "<3-4 sentences explaining WHY this character matches, describing the personality alignment>",
    "matchingTraits": ["<trait1>", "<trait2>", "<trait3>"],
    "excerpts": [
      {
        "text": "<exact quote from their journal answer>",
        "relevance": "<brief explanation of how this excerpt shows the character trait>"
      },
      {
        "text": "<another exact quote>",
        "relevance": "<explanation>"
      }
    ]
  },
  "analysisSummary": "<1-2 sentences describing what personality patterns you found>"
}

Return EXACTLY ONE match - the single best character match. Include 2-3 excerpts as evidence.`;

/**
 * Validates that the universe ID is supported.
 */
export function isValidUniverseId(id: string): id is UniverseId {
  return SUPPORTED_UNIVERSES.includes(id as UniverseId);
}

/**
 * Matches user's journal entries to fictional characters using AI.
 *
 * @param request - The character match request with journal entries and universe ID
 * @returns Character match response with top 3 matches
 * @throws Error if OpenAI request fails, response is invalid, or insufficient content
 */
export async function matchFictionalCharacterWithAI(
  request: CharacterMatchRequest
): Promise<CharacterMatchResponse> {
  const client = getOpenAIClient();

  const universeId = request.universeId;
  const universeName = UNIVERSE_NAMES[universeId];
  const characters = UNIVERSE_CHARACTERS[universeId];

  // Format journal entries for analysis
  const entriesText = request.journalEntries
    .map((entry, index) => {
      let formatted = `Entry ${index + 1}:\n`;
      formatted += `Question: "${entry.question}"\n`;
      formatted += `Answer: "${entry.answer}"`;
      if (entry.clarityMirror) {
        formatted += `\nReflection: "${entry.clarityMirror}"`;
      }
      return formatted;
    })
    .join("\n\n---\n\n");

  // Format character list for the prompt
  const charactersText = characters
    .map((char) => `- ${char.name} (id: ${char.id}): ${char.traits.join(", ")}`)
    .join("\n");

  const userMessage = `## Universe: ${universeName}

## Available Characters:
${charactersText}

## Journal Entries to Analyze:

${entriesText}

---

Analyze these ${request.journalEntries.length} journal entries and find the SINGLE best character match from ${universeName}. Include 2-3 direct quotes from their journal as excerpts to prove your analysis. Return valid JSON.`;

  const response = await client.chat.completions.create({
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: CHARACTER_MATCH_SYSTEM_PROMPT },
      { role: "user", content: userMessage },
    ],
    max_tokens: 1500,
    temperature: 0.6, // Slightly lower for more consistent matching
    response_format: { type: "json_object" },
  });

  const content = response.choices[0]?.message?.content;
  if (!content) {
    throw new Error("No response from OpenAI");
  }

  // Parse the JSON response
  let parsedResponse: { match: CharacterMatch; analysisSummary: string };
  try {
    parsedResponse = JSON.parse(content);
  } catch {
    throw new Error("Failed to parse character match response as JSON");
  }

  // Validate response structure
  if (!parsedResponse.match || typeof parsedResponse.match !== "object") {
    throw new Error("Invalid response: missing match object");
  }

  const match = parsedResponse.match;

  // Validate the match
  if (!match.characterName || typeof match.characterName !== "string") {
    throw new Error("Match: missing or invalid characterName");
  }
  if (!match.characterId || typeof match.characterId !== "string") {
    throw new Error("Match: missing or invalid characterId");
  }
  if (typeof match.confidence !== "number" || match.confidence < 0 || match.confidence > 1) {
    // If confidence is in 0-100 range, convert to 0-1
    if (match.confidence > 1 && match.confidence <= 100) {
      match.confidence = match.confidence / 100;
    } else {
      throw new Error("Match: confidence must be a decimal between 0 and 1");
    }
  }
  if (!match.reasoning || typeof match.reasoning !== "string") {
    throw new Error("Match: missing or invalid reasoning");
  }
  if (!match.matchingTraits || !Array.isArray(match.matchingTraits)) {
    throw new Error("Match: missing or invalid matchingTraits array");
  }
  if (!match.excerpts || !Array.isArray(match.excerpts)) {
    // Provide empty excerpts if not returned
    match.excerpts = [];
  }

  // Validate excerpts
  for (let i = 0; i < match.excerpts.length; i++) {
    const excerpt = match.excerpts[i];
    if (!excerpt.text || typeof excerpt.text !== "string") {
      throw new Error(`Excerpt ${i + 1}: missing or invalid text`);
    }
    if (!excerpt.relevance || typeof excerpt.relevance !== "string") {
      excerpt.relevance = "This excerpt reflects your personality.";
    }
  }

  if (!parsedResponse.analysisSummary || typeof parsedResponse.analysisSummary !== "string") {
    throw new Error("Invalid response: missing or invalid analysisSummary");
  }

  // Return the complete response with single match
  const result: CharacterMatchResponse = {
    match: match,
    universe: universeName,
    analysisSummary: parsedResponse.analysisSummary,
    analyzedAt: new Date().toISOString(),
  };

  console.log("Character match result:", JSON.stringify(result, null, 2));

  return result;
}
