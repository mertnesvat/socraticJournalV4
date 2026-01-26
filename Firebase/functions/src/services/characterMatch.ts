import { getOpenAIClient } from "./openai";

/**
 * Supported fictional franchises for character matching.
 */
export type Franchise = "lordOfTheRings" | "harryPotter" | "starWars";

/**
 * Request interface for character matching analysis.
 */
export interface CharacterMatchRequest {
  journalEntries: Array<{
    question: string;
    answer: string;
    clarityMirror?: string;
  }>;
  franchise: Franchise;
}

/**
 * Individual character match with confidence score.
 */
export interface CharacterMatch {
  /** Name of the character */
  character: string;
  /** Confidence percentage (0-100) */
  confidence: number;
  /** Explanation of why this character matches */
  reasoning: string;
}

/**
 * Complete character match result.
 */
export interface CharacterMatchResult {
  /** Top 3 character matches ordered by confidence */
  matches: CharacterMatch[];
  /** ISO timestamp of when analysis was performed */
  analyzedAt: string;
}

/**
 * Character data for each franchise.
 */
const FRANCHISE_CHARACTERS: Record<Franchise, { name: string; traits: string }[]> = {
  lordOfTheRings: [
    { name: "Frodo", traits: "Burden-bearer, humble, resilient, compassionate, determined despite overwhelming odds" },
    { name: "Sam", traits: "Loyal, steadfast, hopeful, nurturing, finds strength in simple joys" },
    { name: "Gandalf", traits: "Wise, patient, strategic, protective, sees the big picture" },
    { name: "Aragorn", traits: "Leader, honorable, reluctant hero, brave, struggles with destiny" },
    { name: "Legolas", traits: "Graceful, observant, stoic, skilled, finds beauty in nature" },
    { name: "Gimli", traits: "Fierce, loyal, humorous, proud, values honor and friendship" },
    { name: "Boromir", traits: "Protective, ambitious, conflicted, brave, struggles with temptation" },
    { name: "Galadriel", traits: "Powerful, wise, tempted, serene, carries ancient knowledge" },
    { name: "Eowyn", traits: "Brave, frustrated by constraints, determined, caring, seeks meaning" },
    { name: "Faramir", traits: "Thoughtful, honorable, overlooked, wise, values wisdom over glory" },
    { name: "Merry", traits: "Curious, brave, loyal, grows into unexpected courage" },
    { name: "Pippin", traits: "Joyful, impulsive, loyal, finds depth through adversity" },
  ],
  harryPotter: [
    { name: "Harry", traits: "Brave, loyal, impulsive, survivor, feels responsibility for others" },
    { name: "Hermione", traits: "Intelligent, dedicated, anxious, compassionate, values knowledge and justice" },
    { name: "Ron", traits: "Loyal, insecure, humorous, brave, struggles with feeling overshadowed" },
    { name: "Dumbledore", traits: "Strategic, caring, secretive, wise, carries heavy burdens alone" },
    { name: "Snape", traits: "Complex, protective, bitter, loyal, hidden depths of love" },
    { name: "Luna", traits: "Unique, accepting, intuitive, resilient, comfortable being different" },
    { name: "Neville", traits: "Underestimated, brave, loyal, growth-oriented, finds inner strength" },
    { name: "Sirius", traits: "Rebellious, loyal, impulsive, loving, values freedom and family" },
    { name: "Hagrid", traits: "Kind, nurturing, protective, sometimes naive, finds beauty in misunderstood creatures" },
    { name: "McGonagall", traits: "Strict but fair, protective, principled, quietly caring" },
    { name: "Ginny", traits: "Strong-willed, independent, brave, passionate, overcomes trauma" },
    { name: "Draco", traits: "Conflicted, pressured by family, capable of change, struggles with identity" },
  ],
  starWars: [
    { name: "Luke", traits: "Hopeful, idealistic, brave, conflicted, believes in redemption" },
    { name: "Leia", traits: "Leader, determined, compassionate, strong, balances duty and heart" },
    { name: "Han", traits: "Rogue, loyal, skeptical, brave, hides caring beneath cynicism" },
    { name: "Obi-Wan", traits: "Patient, wise, mentor, peaceful, carries regret gracefully" },
    { name: "Yoda", traits: "Wise, patient, mysterious, powerful, teaches through challenge" },
    { name: "Anakin", traits: "Passionate, conflicted, powerful, loving, fears loss deeply" },
    { name: "Padme", traits: "Diplomatic, brave, caring, principled, fights for what's right" },
    { name: "Rey", traits: "Resilient, searching, powerful, compassionate, seeks belonging" },
    { name: "Finn", traits: "Courageous, loyal, moral, struggles with past, finds purpose in friendship" },
    { name: "Ahsoka", traits: "Independent, wise, skilled, principled, forges own path" },
    { name: "Mando", traits: "Protective, honorable, stoic, loyal, follows strict code" },
    { name: "Grogu", traits: "Innocent, powerful, curious, forms deep attachments" },
  ],
};

/**
 * Franchise display names for prompts.
 */
const FRANCHISE_NAMES: Record<Franchise, string> = {
  lordOfTheRings: "The Lord of the Rings",
  harryPotter: "Harry Potter",
  starWars: "Star Wars",
};

/**
 * System prompt for character matching analysis.
 */
function getCharacterMatchSystemPrompt(franchise: Franchise): string {
  const franchiseName = FRANCHISE_NAMES[franchise];
  const characters = FRANCHISE_CHARACTERS[franchise];

  const characterList = characters
    .map(c => `- **${c.name}**: ${c.traits}`)
    .join("\n");

  return `You are a character analysis expert who matches real people's personality traits to fictional characters from ${franchiseName}.

## Available Characters

${characterList}

## Analysis Guidelines

1. **Read holistically**: Analyze patterns across ALL journal entries, not individual responses
2. **Look for personality patterns**: Consider how they express emotions, handle challenges, relate to others
3. **Match character essence**: Focus on core personality traits, values, and emotional patterns
4. **Consider growth arcs**: Characters evolve; match to the overall character essence
5. **Be specific**: Reference actual journal content when explaining matches
6. **Distribute confidence**: The top 3 matches should sum to approximately 100%

## Matching Criteria

- Writing style and emotional expression
- How they describe relationships and social situations
- Their approach to challenges and obstacles
- Values and priorities revealed in reflections
- Fears, hopes, and aspirations mentioned
- Decision-making patterns and reasoning

## Response Format

You MUST respond with valid JSON matching this exact structure:
{
  "matches": [
    {
      "character": "<character name>",
      "confidence": <number 1-100>,
      "reasoning": "<2-3 sentences explaining why, referencing journal content>"
    },
    {
      "character": "<character name>",
      "confidence": <number 1-100>,
      "reasoning": "<2-3 sentences explaining why>"
    },
    {
      "character": "<character name>",
      "confidence": <number 1-100>,
      "reasoning": "<2-3 sentences explaining why>"
    }
  ]
}

Return exactly 3 matches ordered by confidence (highest first). Confidence values should reflect genuine likelihood of match.`;
}

/**
 * Analyzes journal entries to find character matches.
 *
 * @param request - The character match request with journal entries and franchise
 * @returns Top 3 character matches with confidence scores
 * @throws Error if OpenAI request fails or response is invalid
 */
export async function analyzeCharacterMatchWithAI(
  request: CharacterMatchRequest
): Promise<CharacterMatchResult> {
  const client = getOpenAIClient();

  // Format journal entries for analysis
  const entriesText = request.journalEntries
    .map((entry, index) => {
      let formatted = `Entry ${index + 1}:\n`;
      formatted += `Question: "${entry.question}"\n`;
      formatted += `Answer: "${entry.answer}"`;
      if (entry.clarityMirror) {
        formatted += `\nClarity Mirror: "${entry.clarityMirror}"`;
      }
      return formatted;
    })
    .join("\n\n---\n\n");

  const franchiseName = FRANCHISE_NAMES[request.franchise];

  const userMessage = `Analyze these ${request.journalEntries.length} journal entries and determine which ${franchiseName} character this person is most like:

${entriesText}

Based on the personality patterns, writing style, and themes in these entries, identify the top 3 character matches with confidence percentages.`;

  const response = await client.chat.completions.create({
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: getCharacterMatchSystemPrompt(request.franchise) },
      { role: "user", content: userMessage },
    ],
    max_tokens: 800,
    temperature: 0.7, // Slightly higher for more creative matching
    response_format: { type: "json_object" },
  });

  const content = response.choices[0]?.message?.content;
  if (!content) {
    throw new Error("No response from OpenAI");
  }

  // Parse the JSON response
  let parsedResponse: { matches: CharacterMatch[] };
  try {
    parsedResponse = JSON.parse(content);
  } catch {
    throw new Error("Failed to parse character match response as JSON");
  }

  // Validate response structure
  if (!Array.isArray(parsedResponse.matches) || parsedResponse.matches.length !== 3) {
    throw new Error("Invalid character match response: expected exactly 3 matches");
  }

  for (let i = 0; i < parsedResponse.matches.length; i++) {
    const match = parsedResponse.matches[i];
    if (
      typeof match.character !== "string" ||
      typeof match.confidence !== "number" ||
      typeof match.reasoning !== "string"
    ) {
      throw new Error(`Invalid match data structure at index ${i}`);
    }
  }

  const result: CharacterMatchResult = {
    matches: parsedResponse.matches,
    analyzedAt: new Date().toISOString(),
  };

  console.log("Character match result:", JSON.stringify(result, null, 2));

  return result;
}
