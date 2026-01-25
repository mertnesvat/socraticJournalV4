import OpenAI from "openai";
import { defineSecret } from "firebase-functions/params";

// Define the secret - this will be securely stored in Firebase
export const openaiApiKey = defineSecret("OPENAI_API_KEY");

/**
 * Gets an OpenAI client instance.
 * Creates a new client each time to ensure fresh API key from secrets.
 */
export function getOpenAIClient(): OpenAI {
  const apiKey = openaiApiKey.value();
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY secret is not configured");
  }
  // Trim any whitespace/newlines from the API key
  return new OpenAI({ apiKey: apiKey.trim() });
}

/**
 * System prompt for generating clarity mirror reflections.
 * The clarity mirror helps users feel seen and validated by rephrasing
 * their thoughts in an empathetic way.
 */
export const CLARITY_MIRROR_SYSTEM_PROMPT = `You are a compassionate, wise reflection guide for a Socratic journaling app. Your role is to create a "Clarity Mirror" - a brief reflection that helps the user feel truly seen and understood.

Guidelines:
1. Keep responses to 2-3 sentences maximum
2. Begin with validating language like "It sounds like..." or "What I'm hearing is..."
3. Reflect the emotional undertone, not just the content
4. End with an affirming observation about the user's self-awareness
5. Be warm but not saccharine - authentic, not performative
6. Never give advice or try to solve problems
7. Focus on the present moment and what the user has shared
8. Use "you" language to make it personal

IMPORTANT - Handling unclear or nonsensical input:
If the user's answer is gibberish, random characters, test input (like "asdf", "test", "aaaaaa"), or doesn't make coherent sense:
- Gently acknowledge that you're having trouble understanding
- Invite them to try again with what's really on their mind
- Keep it warm and non-judgmental
- Example response for gibberish: "I'm having trouble catching what you're trying to express. Take a breath, and when you're ready, share what's actually on your mind - there's no rush."

Example input: "I'm worried about my job interview tomorrow. I've prepared but still feel nervous."
Example output: "It sounds like you're holding both preparation and uncertainty right now. The nervousness you feel shows how much this opportunity means to you - that's real self-awareness."

Example input: "asdfasdf asd asd sad asd"
Example output: "I'm not quite sure what you're trying to say here. Take a moment - what's really going through your mind right now? This is your space to be honest."`;

/**
 * System prompt for generating follow-up Socratic questions.
 * These questions help deepen the user's self-reflection.
 */
export const FOLLOW_UP_QUESTION_SYSTEM_PROMPT = `You are a Socratic questioning guide for a journaling app. Your role is to generate ONE thoughtful follow-up question that deepens the user's self-reflection.

Guidelines:
1. Generate exactly ONE question
2. Make it open-ended (cannot be answered with yes/no)
3. Build on what the user has already shared
4. Gently push toward deeper understanding without being confrontational
5. Keep questions concise (under 15 words ideally)
6. Avoid "why" questions when possible (can feel accusatory) - prefer "what" or "how"
7. Focus on feelings, values, and desired outcomes

The standard Socratic flow is:
1. "What's on your mind today?"
2. "Why does this matter to you right now?"
3. "What would it feel like to resolve this?"
4. "What's one small step you could take?"
5. "What might you tell your future self about today?"

Generate a question that fits naturally as a follow-up to continue this exploration.`;

export interface ClarityMirrorRequest {
  question: string;
  answer: string;
  previousExchanges?: Array<{question: string; answer: string}>;
}

export interface FollowUpQuestionRequest {
  currentQuestion: string;
  currentAnswer: string;
  previousExchanges?: Array<{question: string; answer: string}>;
  questionIndex: number;
}

export interface SocratesReactionRequest {
  question: string;
  answer: string;
}

/**
 * System prompt for generating Socrates' emotional/physical reactions.
 * These reactions bring Socrates to life as a character responding to the user's reflections.
 */
export const SOCRATES_REACTION_SYSTEM_PROMPT = `You generate short, evocative descriptions of Socrates' physical reactions and emotional responses during a philosophical dialogue. These should be 5-10 words describing his body language, facial expressions, or contemplative gestures.

Guidelines:
1. Keep responses to 5-10 words maximum
2. Focus on physical/emotional reactions, not speech
3. Use present tense, third person ("Socrates...")
4. Vary between: thoughtful stroking of beard, nodding, leaning forward with interest, raising an eyebrow, smiling gently, looking contemplative, eyes brightening, etc.
5. Match the reaction to the emotional depth/content of the user's answer
6. Never include dialogue or suggestions - only describe his reaction

IMPORTANT - Handling unclear or nonsensical input:
If the user's answer is gibberish, random characters, or doesn't make sense, return a puzzled but kind reaction like "Socrates tilts his head, curious but patient."

Examples:
- Deep emotional answer → "Socrates nods slowly, eyes soft with understanding."
- Uncertain answer → "Socrates strokes his beard thoughtfully."
- Excited/energetic answer → "Socrates leans forward, eyes brightening."
- Sad/heavy answer → "Socrates pauses, a gentle compassion crossing his face."
- Insightful answer → "Socrates' eyes crinkle with quiet admiration."`;

/**
 * Generates a Socrates reaction description using OpenAI.
 */
export async function generateSocratesReactionWithAI(
  request: SocratesReactionRequest
): Promise<string> {
  const client = getOpenAIClient();

  const userMessage = `Question asked: "${request.question}"
User's answer: "${request.answer}"

Generate a short description of Socrates' physical/emotional reaction to this answer.`;

  const response = await client.chat.completions.create({
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: SOCRATES_REACTION_SYSTEM_PROMPT },
      { role: "user", content: userMessage },
    ],
    max_tokens: 30,
    temperature: 0.8,
  });

  const content = response.choices[0]?.message?.content;
  if (!content) {
    throw new Error("No response from OpenAI");
  }

  return content.trim();
}

/**
 * Generates a clarity mirror reflection using OpenAI.
 */
export async function generateClarityMirrorWithAI(
  request: ClarityMirrorRequest
): Promise<string> {
  const client = getOpenAIClient();

  // Build context from previous exchanges if available
  let contextMessage = "";
  if (request.previousExchanges && request.previousExchanges.length > 0) {
    contextMessage = "Previous exchanges in this session:\n";
    for (const exchange of request.previousExchanges) {
      contextMessage += `Q: ${exchange.question}\nA: ${exchange.answer}\n\n`;
    }
    contextMessage += "---\n";
  }

  const userMessage = `${contextMessage}Current question: "${request.question}"
User's answer: "${request.answer}"

Generate a clarity mirror reflection for this answer.`;

  const response = await client.chat.completions.create({
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: CLARITY_MIRROR_SYSTEM_PROMPT },
      { role: "user", content: userMessage },
    ],
    max_tokens: 150,
    temperature: 0.7,
  });

  const content = response.choices[0]?.message?.content;
  if (!content) {
    throw new Error("No response from OpenAI");
  }

  return content.trim();
}

/**
 * Generates a follow-up Socratic question using OpenAI.
 */
export async function generateFollowUpQuestionWithAI(
  request: FollowUpQuestionRequest
): Promise<string> {
  const client = getOpenAIClient();

  // Build context from session
  let contextMessage = "";
  if (request.previousExchanges && request.previousExchanges.length > 0) {
    contextMessage = "Previous exchanges in this session:\n";
    for (const exchange of request.previousExchanges) {
      contextMessage += `Q: ${exchange.question}\nA: ${exchange.answer}\n\n`;
    }
  }

  const userMessage = `${contextMessage}Current question (#${request.questionIndex + 1}): "${request.currentQuestion}"
User's answer: "${request.currentAnswer}"

Generate ONE follow-up question to deepen their reflection. Return only the question, nothing else.`;

  const response = await client.chat.completions.create({
    model: "gpt-4o-mini",
    messages: [
      { role: "system", content: FOLLOW_UP_QUESTION_SYSTEM_PROMPT },
      { role: "user", content: userMessage },
    ],
    max_tokens: 50,
    temperature: 0.8,
  });

  const content = response.choices[0]?.message?.content;
  if (!content) {
    throw new Error("No response from OpenAI");
  }

  return content.trim();
}
