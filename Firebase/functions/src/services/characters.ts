import { getOpenAIClient } from "./openai";

/**
 * Character data for personality matching.
 * Each character has a name, franchise, and detailed personality description.
 */
export interface Character {
  name: string;
  franchise: string;
  personalityDescription: string;
}

/**
 * Request interface for character matching analysis.
 */
export interface CharacterMatchRequest {
  entries: Array<{
    question: string;
    answer: string;
  }>;
  franchise: string;
}

/**
 * Individual character match with confidence and explanation.
 */
export interface CharacterMatch {
  character: string;
  confidencePercentage: number;
  explanation: string;
}

/**
 * Response from character match analysis.
 */
export interface CharacterMatchResponse {
  matches: CharacterMatch[];
  analyzedAt: string;
}

/**
 * Character definitions for Lord of the Rings franchise.
 */
export const LORD_OF_THE_RINGS_CHARACTERS: Character[] = [
  {
    name: "Aragorn",
    franchise: "Lord of the Rings",
    personalityDescription:
      "A natural leader who often hides their true potential. Values duty and honor above personal desires. Struggles with destiny but ultimately accepts responsibility.",
  },
  {
    name: "Frodo",
    franchise: "Lord of the Rings",
    personalityDescription:
      "Bears heavy burdens without complaint. Shows resilience in the face of overwhelming odds. Maintains innocence and hope despite darkness.",
  },
  {
    name: "Gandalf",
    franchise: "Lord of the Rings",
    personalityDescription:
      "A wise guide who helps others find their own strength. Sees the big picture. Makes sacrifices for the greater good.",
  },
  {
    name: "Sam",
    franchise: "Lord of the Rings",
    personalityDescription:
      "Unwavering loyalty is their defining trait. Finds joy in simple things. Possesses quiet courage that emerges when needed most.",
  },
  {
    name: "Boromir",
    franchise: "Lord of the Rings",
    personalityDescription:
      "Struggles with inner conflict between ambition and honor. Seeks redemption. Deeply cares about protecting loved ones.",
  },
];

/**
 * Character definitions for Harry Potter franchise.
 */
export const HARRY_POTTER_CHARACTERS: Character[] = [
  {
    name: "Harry",
    franchise: "Harry Potter",
    personalityDescription:
      "Brave to the point of recklessness. Driven by justice and protecting others. Struggles with fame but stays humble.",
  },
  {
    name: "Hermione",
    franchise: "Harry Potter",
    personalityDescription:
      "Values knowledge and preparation above all. Fiercely loyal to friends. Stands up for what's right even when unpopular.",
  },
  {
    name: "Ron",
    franchise: "Harry Potter",
    personalityDescription:
      "Values friendship deeply despite insecurities. Uses humor as a coping mechanism. Capable of surprising courage.",
  },
  {
    name: "Dumbledore",
    franchise: "Harry Potter",
    personalityDescription:
      "Sees the bigger picture at the cost of personal relationships. Carries secrets and burdens. Believes in second chances.",
  },
  {
    name: "Luna",
    franchise: "Harry Potter",
    personalityDescription:
      "Embraces uniqueness without apology. Has deep intuition. Accepts others without judgment.",
  },
];

/**
 * Character definitions for Star Wars franchise.
 */
export const STAR_WARS_CHARACTERS: Character[] = [
  {
    name: "Luke",
    franchise: "Star Wars",
    personalityDescription:
      "Believes in the good in others. Shows growth from impatience to wisdom. Driven by hope even in dark times.",
  },
  {
    name: "Leia",
    franchise: "Star Wars",
    personalityDescription:
      "Natural leader who inspires others. Determined to the point of stubbornness. Shows compassion alongside strength.",
  },
  {
    name: "Han Solo",
    franchise: "Star Wars",
    personalityDescription:
      "Projects cynicism to hide a caring heart. Values independence. Ultimately chooses connection over isolation.",
  },
  {
    name: "Obi-Wan",
    franchise: "Star Wars",
    personalityDescription:
      "Wise and patient teacher. Makes difficult sacrifices. Maintains hope and duty even in defeat.",
  },
  {
    name: "Yoda",
    franchise: "Star Wars",
    personalityDescription:
      "Embodies patience and perspective. Teaches through questions. Sees potential in the overlooked.",
  },
];

/**
 * Maps franchise names to their character lists.
 */
export const FRANCHISE_CHARACTERS: Record<string, Character[]> = {
  "Lord of the Rings": LORD_OF_THE_RINGS_CHARACTERS,
  "Harry Potter": HARRY_POTTER_CHARACTERS,
  "Star Wars": STAR_WARS_CHARACTERS,
};

/**
 * Supported franchise names for validation.
 */
export const SUPPORTED_FRANCHISES = Object.keys(FRANCHISE_CHARACTERS);

/**
 * System prompt for character matching analysis.
 * Instructs the AI to analyze journal entries and match to characters.
 */
export const CHARACTER_MATCH_SYSTEM_PROMPT = `You are a personality matching expert who analyzes journal entries to find character matches from fictional franchises. Your task is to identify which characters best represent the personality patterns revealed in the user's journal entries.

## Analysis Guidelines

1. **Analyze holistically**: Look at patterns across ALL entries, not just individual responses
2. **Focus on themes**: Identify recurring themes like responsibility, loyalty, growth, wisdom, courage, creativity, etc.
3. **Consider emotional patterns**: How does the person handle challenges, relationships, decisions?
4. **Match to character essence**: Focus on the core personality traits, not surface behaviors
5. **Privacy first**: Base explanations on THEMES you observed, NEVER quote the journal entries directly

## Confidence Scoring

Confidence percentages represent how strongly the journal entries align with each character's traits:
- 70-100%: Strong alignment - multiple clear indicators across entries
- 50-69%: Moderate alignment - some clear indicators present
- 30-49%: Partial alignment - limited but notable indicators
- Below 30%: Weak alignment - only minor connections

NOTE: Percentages do NOT need to sum to 100%. Each percentage represents independent confidence for that match.

## Response Format

You MUST respond with valid JSON matching this exact structure:
{
  "matches": [
    {
      "character": "<character name>",
      "confidencePercentage": <number 0-100>,
      "explanation": "<2-3 sentences explaining why this character matches, referencing journal THEMES not quotes>"
    }
  ]
}

Return exactly 3 matches, ordered from highest to lowest confidence.

IMPORTANT:
- Explanations must reference patterns/themes from the entries WITHOUT quoting them directly
- Use phrases like "Your entries reveal...", "Your reflections show...", "A pattern in your journaling suggests..."
- Never include actual text from their journal entries to protect privacy`;

/**
 * Generates the user prompt with journal entries and franchise characters.
 */
function buildUserPrompt(
  entries: CharacterMatchRequest["entries"],
  characters: Character[]
): string {
  // Format journal entries for analysis
  const entriesText = entries
    .map((entry, index) => {
      return `Entry ${index + 1}:\nQuestion: "${entry.question}"\nAnswer: "${entry.answer}"`;
    })
    .join("\n\n---\n\n");

  // Format character options
  const charactersText = characters
    .map((char) => {
      return `**${char.name}**: ${char.personalityDescription}`;
    })
    .join("\n\n");

  return `Analyze the following journal entries and match the person's personality to the provided characters.

## Available Characters (${characters[0]?.franchise || "Unknown"})

${charactersText}

## Journal Entries to Analyze

${entriesText}

Based on these journal entries, identify the top 3 character matches. Remember:
1. Order results from highest to lowest confidence
2. Base explanations on themes you observed, not direct quotes
3. Consider how the person reflects, their values, and their patterns of thinking
4. Return valid JSON only`;
}

/**
 * Analyzes journal entries to find character matches in a franchise.
 *
 * @param request - The character match request with entries and franchise
 * @returns Character matches with confidence scores and explanations
 * @throws Error if OpenAI request fails or response is invalid
 */
export async function analyzeCharacterMatchWithAI(
  request: CharacterMatchRequest
): Promise<CharacterMatchResponse> {
  const client = getOpenAIClient();

  // Get characters for the requested franchise
  const characters = FRANCHISE_CHARACTERS[request.franchise];
  if (!characters) {
    throw new Error(
      `Unsupported franchise: ${request.franchise}. Supported franchises: ${SUPPORTED_FRANCHISES.join(", ")}`
    );
  }

  const userMessage = buildUserPrompt(request.entries, characters);

  const response = await client.chat.completions.create({
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: CHARACTER_MATCH_SYSTEM_PROMPT },
      { role: "user", content: userMessage },
    ],
    max_tokens: 1000,
    temperature: 0.6, // Balanced temperature for consistent but varied analysis
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
  if (!parsedResponse.matches || !Array.isArray(parsedResponse.matches)) {
    throw new Error("Invalid response: missing matches array");
  }

  if (parsedResponse.matches.length !== 3) {
    throw new Error(
      `Invalid response: expected 3 matches, got ${parsedResponse.matches.length}`
    );
  }

  // Validate each match
  for (let i = 0; i < parsedResponse.matches.length; i++) {
    const match = parsedResponse.matches[i];

    if (!match.character || typeof match.character !== "string") {
      throw new Error(`Match ${i + 1}: missing or invalid character name`);
    }

    if (
      typeof match.confidencePercentage !== "number" ||
      match.confidencePercentage < 0 ||
      match.confidencePercentage > 100
    ) {
      throw new Error(`Match ${i + 1}: invalid confidence percentage`);
    }

    if (!match.explanation || typeof match.explanation !== "string") {
      throw new Error(`Match ${i + 1}: missing or invalid explanation`);
    }

    // Validate character exists in the franchise
    const validCharacterNames = characters.map((c) => c.name);
    if (!validCharacterNames.includes(match.character)) {
      throw new Error(
        `Match ${i + 1}: "${match.character}" is not a valid character in ${request.franchise}`
      );
    }
  }

  // Return the complete response with timestamp
  return {
    matches: parsedResponse.matches,
    analyzedAt: new Date().toISOString(),
  };
}
