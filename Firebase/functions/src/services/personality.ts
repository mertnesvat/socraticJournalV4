import { getOpenAIClient } from "./openai";

/**
 * Request interface for personality analysis.
 * Requires journal entries with question-answer pairs.
 */
export interface PersonalityAnalysisRequest {
  journalEntries: Array<{
    question: string;
    answer: string;
    clarityMirror?: string;
  }>;
}

/**
 * Individual trait score with supporting evidence.
 */
export interface TraitScore {
  /** Score from 0-100 indicating trait expression level */
  score: number;
  /** Human-readable label: "High", "Moderate-High", "Moderate", "Moderate-Low", "Low" */
  label: string;
  /** Brief explanation of what this score means for the user */
  description: string;
  /** Direct quotes from journal entries that support this assessment */
  evidence: string[];
}

/**
 * Complete Big Five personality profile.
 */
export interface BigFiveProfile {
  /** Openness to Experience: creativity, curiosity, intellectual interests */
  openness: TraitScore;
  /** Conscientiousness: organization, dependability, self-discipline */
  conscientiousness: TraitScore;
  /** Extraversion: sociability, assertiveness, positive emotionality */
  extraversion: TraitScore;
  /** Agreeableness: cooperation, trust, empathy toward others */
  agreeableness: TraitScore;
  /** Neuroticism: emotional instability, anxiety, moodiness */
  neuroticism: TraitScore;
  /** Holistic summary paragraph of the personality profile */
  summary: string;
  /** ISO timestamp of when analysis was performed */
  analyzedAt: string;
}

/**
 * System prompt for Big Five personality analysis.
 * Instructs the AI to analyze journal entries for personality indicators.
 */
export const PERSONALITY_ANALYSIS_SYSTEM_PROMPT = `You are a personality psychology expert specializing in the Big Five (OCEAN) personality model. Your task is to analyze journal entries from a Socratic journaling app to create a personality profile.

## The Big Five Traits

1. **Openness to Experience**: Creativity, curiosity, appreciation for art and ideas, willingness to try new things, intellectual curiosity
   - HIGH indicators: diverse interests, abstract thinking, creative expression, philosophical musings, openness to change
   - LOW indicators: preference for routine, practical focus, conventional thinking, discomfort with ambiguity

2. **Conscientiousness**: Organization, dependability, self-discipline, goal-orientation, planning
   - HIGH indicators: mentions of goals, planning, responsibility, attention to detail, persistence
   - LOW indicators: spontaneity preference, flexibility over structure, procrastination mentions, impulsive decisions

3. **Extraversion**: Sociability, assertiveness, talkativeness, positive emotions, excitement-seeking
   - HIGH indicators: mentions of social activities, energy from others, enthusiasm, assertive language
   - LOW indicators: preference for solitude, introspection, energy drain from socializing, reserved expression

4. **Agreeableness**: Cooperation, trust, empathy, altruism, conflict avoidance
   - HIGH indicators: concern for others, cooperative language, trust, forgiveness, helping behaviors
   - LOW indicators: competitive focus, skepticism, direct confrontation, prioritizing self-interest

5. **Neuroticism**: Emotional instability, anxiety, moodiness, irritability, sadness
   - HIGH indicators: worry, self-doubt, emotional volatility, stress sensitivity, negative self-talk
   - LOW indicators: emotional stability, calm under pressure, resilience, steady mood

## Analysis Guidelines

1. **Analyze holistically**: Look at patterns across ALL entries, not just individual responses
2. **Consider context**: Journaling often captures vulnerable moments, so adjust for self-reflection bias
3. **Find evidence**: Extract direct quotes that demonstrate each trait
4. **Be balanced**: Most people are moderate on most traits - avoid extreme scores without clear evidence
5. **Language patterns matter**: Word choice, sentence structure, and emotional expression reveal personality
6. **Look for themes**: Recurring topics and concerns indicate trait expression

## Scoring Guidelines

- 0-20: Very Low (rare expression of this trait)
- 21-40: Low (infrequent expression)
- 41-60: Moderate (balanced expression)
- 61-80: High (frequent expression)
- 81-100: Very High (dominant trait expression)

Assign labels based on scores:
- 0-20: "Low"
- 21-40: "Moderate-Low"
- 41-60: "Moderate"
- 61-80: "Moderate-High"
- 81-100: "High"

## Response Format

You MUST respond with valid JSON matching this exact structure:
{
  "openness": {
    "score": <number 0-100>,
    "label": "<string>",
    "description": "<1-2 sentence explanation>",
    "evidence": ["<quote 1>", "<quote 2>"]
  },
  "conscientiousness": { ... },
  "extraversion": { ... },
  "agreeableness": { ... },
  "neuroticism": { ... },
  "summary": "<2-3 sentence holistic summary of the person's personality>"
}

Provide 1-3 evidence quotes per trait. If a trait has limited evidence, note this in the description.`;

/**
 * Analyzes journal entries to create a Big Five personality profile.
 *
 * @param request - The personality analysis request with journal entries
 * @returns A complete BigFiveProfile with trait scores and evidence
 * @throws Error if OpenAI request fails or response is invalid
 */
export async function analyzePersonalityWithAI(
  request: PersonalityAnalysisRequest
): Promise<BigFiveProfile> {
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

  const userMessage = `Please analyze the following ${request.journalEntries.length} journal entries and create a Big Five personality profile:

${entriesText}

Analyze these entries for personality indicators and respond with the JSON profile.`;

  const response = await client.chat.completions.create({
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: PERSONALITY_ANALYSIS_SYSTEM_PROMPT },
      { role: "user", content: userMessage },
    ],
    max_tokens: 1500,
    temperature: 0.5, // Lower temperature for more consistent analysis
    response_format: { type: "json_object" },
  });

  const content = response.choices[0]?.message?.content;
  if (!content) {
    throw new Error("No response from OpenAI");
  }

  // Parse the JSON response
  let parsedResponse: Omit<BigFiveProfile, "analyzedAt">;
  try {
    parsedResponse = JSON.parse(content);
  } catch {
    throw new Error("Failed to parse personality analysis response as JSON");
  }

  // Validate required fields exist
  const requiredTraits = [
    "openness",
    "conscientiousness",
    "extraversion",
    "agreeableness",
    "neuroticism",
  ] as const;

  for (const trait of requiredTraits) {
    if (!parsedResponse[trait]) {
      throw new Error(`Missing required trait in response: ${trait}`);
    }
    const traitData = parsedResponse[trait];
    if (
      typeof traitData.score !== "number" ||
      typeof traitData.label !== "string" ||
      typeof traitData.description !== "string" ||
      !Array.isArray(traitData.evidence)
    ) {
      throw new Error(`Invalid trait data structure for: ${trait}`);
    }
  }

  if (typeof parsedResponse.summary !== "string") {
    throw new Error("Missing or invalid summary in response");
  }

  // Return the complete profile with timestamp
  const result = {
    openness: parsedResponse.openness,
    conscientiousness: parsedResponse.conscientiousness,
    extraversion: parsedResponse.extraversion,
    agreeableness: parsedResponse.agreeableness,
    neuroticism: parsedResponse.neuroticism,
    summary: parsedResponse.summary,
    analyzedAt: new Date().toISOString(),
  };

  // Log the result for debugging
  console.log("Personality analysis result:", JSON.stringify(result, null, 2));

  return result;
}
