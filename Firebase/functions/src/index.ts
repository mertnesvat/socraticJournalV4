import { onCall, HttpsError } from "firebase-functions/v2/https";
import {
  openaiApiKey,
  generateClarityMirrorWithAI,
  generateFollowUpQuestionWithAI,
  generateSocratesReactionWithAI,
  generateWisdomQuoteWithAI,
  generateSessionSummaryWithAI,
  enhanceFutureLetterWithAI,
  ClarityMirrorRequest,
  FollowUpQuestionRequest,
  SocratesReactionRequest,
  WisdomQuoteRequest,
  SessionSummaryRequest,
  LetterEnhancementRequest,
} from "./services/openai";
import {
  analyzePersonalityWithAI,
  PersonalityAnalysisRequest,
} from "./services/personality";

/**
 * Firebase Cloud Function: Generate Clarity Mirror
 *
 * Generates an AI-powered reflection that helps users feel seen and understood.
 * Uses OpenAI GPT-4o-mini for empathetic, concise responses.
 *
 * @param request.data.question - The Socratic question being answered
 * @param request.data.answer - The user's answer
 * @param request.data.previousExchanges - Optional array of previous Q&A exchanges
 * @returns Object with 'mirror' string containing the reflection
 */
export const generateClarityMirror = onCall(
  {
    secrets: [openaiApiKey],
    cors: true,
    maxInstances: 10,
    timeoutSeconds: 30,
  },
  async (request) => {
    // Validate authentication (optional - remove if you want public access)
    // if (!request.auth) {
    //   throw new HttpsError("unauthenticated", "User must be authenticated");
    // }

    // Validate request data
    const data = request.data as ClarityMirrorRequest;

    if (!data.question || typeof data.question !== "string") {
      throw new HttpsError("invalid-argument", "Question is required");
    }

    if (!data.answer || typeof data.answer !== "string") {
      throw new HttpsError("invalid-argument", "Answer is required");
    }

    if (data.answer.trim().length === 0) {
      throw new HttpsError("invalid-argument", "Answer cannot be empty");
    }

    try {
      const mirror = await generateClarityMirrorWithAI({
        question: data.question,
        answer: data.answer,
        previousExchanges: data.previousExchanges,
      });

      return { mirror };
    } catch (error) {
      console.error("Error generating clarity mirror:", error);

      if (error instanceof Error) {
        if (error.message.includes("API key")) {
          throw new HttpsError("internal", "Service configuration error");
        }
        if (error.message.includes("rate limit")) {
          throw new HttpsError("resource-exhausted", "Service temporarily unavailable");
        }
      }

      throw new HttpsError("internal", "Failed to generate reflection");
    }
  }
);

/**
 * Firebase Cloud Function: Generate Follow-Up Question
 *
 * Generates a dynamic Socratic follow-up question based on the user's response.
 * Uses OpenAI GPT-4o-mini for contextual, deepening questions.
 *
 * @param request.data.currentQuestion - The current question being answered
 * @param request.data.currentAnswer - The user's answer
 * @param request.data.previousExchanges - Optional array of previous Q&A exchanges
 * @param request.data.questionIndex - Current question index (0-based)
 * @returns Object with 'question' string containing the follow-up
 */
export const generateFollowUpQuestion = onCall(
  {
    secrets: [openaiApiKey],
    cors: true,
    maxInstances: 10,
    timeoutSeconds: 30,
  },
  async (request) => {
    // Validate request data
    const data = request.data as FollowUpQuestionRequest;

    if (!data.currentQuestion || typeof data.currentQuestion !== "string") {
      throw new HttpsError("invalid-argument", "Current question is required");
    }

    if (!data.currentAnswer || typeof data.currentAnswer !== "string") {
      throw new HttpsError("invalid-argument", "Current answer is required");
    }

    if (typeof data.questionIndex !== "number" || data.questionIndex < 0) {
      throw new HttpsError("invalid-argument", "Valid question index is required");
    }

    try {
      const question = await generateFollowUpQuestionWithAI({
        currentQuestion: data.currentQuestion,
        currentAnswer: data.currentAnswer,
        previousExchanges: data.previousExchanges,
        questionIndex: data.questionIndex,
      });

      return { question };
    } catch (error) {
      console.error("Error generating follow-up question:", error);

      if (error instanceof Error) {
        if (error.message.includes("API key")) {
          throw new HttpsError("internal", "Service configuration error");
        }
        if (error.message.includes("rate limit")) {
          throw new HttpsError("resource-exhausted", "Service temporarily unavailable");
        }
      }

      throw new HttpsError("internal", "Failed to generate question");
    }
  }
);

/**
 * Firebase Cloud Function: Generate Socrates Reaction
 *
 * Generates a short description of Socrates' physical/emotional reaction
 * to the user's answer, bringing the character to life.
 *
 * @param request.data.question - The question being answered
 * @param request.data.answer - The user's answer
 * @returns Object with 'reaction' string containing Socrates' reaction
 */
export const generateSocratesReaction = onCall(
  {
    secrets: [openaiApiKey],
    cors: true,
    maxInstances: 10,
    timeoutSeconds: 30,
  },
  async (request) => {
    const data = request.data as SocratesReactionRequest;

    if (!data.question || typeof data.question !== "string") {
      throw new HttpsError("invalid-argument", "Question is required");
    }

    if (!data.answer || typeof data.answer !== "string") {
      throw new HttpsError("invalid-argument", "Answer is required");
    }

    try {
      const reaction = await generateSocratesReactionWithAI({
        question: data.question,
        answer: data.answer,
      });

      return { reaction };
    } catch (error) {
      console.error("Error generating Socrates reaction:", error);

      if (error instanceof Error) {
        if (error.message.includes("API key")) {
          throw new HttpsError("internal", "Service configuration error");
        }
        if (error.message.includes("rate limit")) {
          throw new HttpsError("resource-exhausted", "Service temporarily unavailable");
        }
      }

      throw new HttpsError("internal", "Failed to generate reaction");
    }
  }
);

/**
 * Firebase Cloud Function: Analyze Personality
 *
 * Analyzes journal entries to create a Big Five personality profile.
 * Requires at least 5 journal entries for meaningful analysis.
 *
 * @param request.data.journalEntries - Array of journal entries with question/answer pairs
 * @returns BigFiveProfile with trait scores, evidence, and summary
 */
export const analyzePersonality = onCall(
  {
    secrets: [openaiApiKey],
    cors: true,
    maxInstances: 10,
    timeoutSeconds: 60, // Longer timeout for comprehensive analysis
  },
  async (request) => {
    // Validate request data
    const data = request.data as PersonalityAnalysisRequest;

    if (!data.journalEntries || !Array.isArray(data.journalEntries)) {
      throw new HttpsError(
        "invalid-argument",
        "journalEntries array is required"
      );
    }

    // Require minimum entries for meaningful analysis
    const MIN_ENTRIES = 5;
    if (data.journalEntries.length < MIN_ENTRIES) {
      throw new HttpsError(
        "invalid-argument",
        `At least ${MIN_ENTRIES} journal entries are required for personality analysis. ` +
          `Received: ${data.journalEntries.length}`
      );
    }

    // Validate each entry structure
    for (let i = 0; i < data.journalEntries.length; i++) {
      const entry = data.journalEntries[i];

      if (!entry.question || typeof entry.question !== "string") {
        throw new HttpsError(
          "invalid-argument",
          `Entry ${i + 1}: question is required and must be a string`
        );
      }

      if (!entry.answer || typeof entry.answer !== "string") {
        throw new HttpsError(
          "invalid-argument",
          `Entry ${i + 1}: answer is required and must be a string`
        );
      }

      if (entry.answer.trim().length === 0) {
        throw new HttpsError(
          "invalid-argument",
          `Entry ${i + 1}: answer cannot be empty`
        );
      }

      if (
        entry.clarityMirror !== undefined &&
        typeof entry.clarityMirror !== "string"
      ) {
        throw new HttpsError(
          "invalid-argument",
          `Entry ${i + 1}: clarityMirror must be a string if provided`
        );
      }
    }

    try {
      const profile = await analyzePersonalityWithAI({
        journalEntries: data.journalEntries,
      });

      return { profile };
    } catch (error) {
      console.error("Error analyzing personality:", error);

      if (error instanceof Error) {
        if (error.message.includes("API key")) {
          throw new HttpsError("internal", "Service configuration error");
        }
        if (error.message.includes("rate limit")) {
          throw new HttpsError(
            "resource-exhausted",
            "Service temporarily unavailable"
          );
        }
        if (error.message.includes("parse")) {
          throw new HttpsError(
            "internal",
            "Failed to process personality analysis"
          );
        }
      }

      throw new HttpsError("internal", "Failed to analyze personality");
    }
  }
);

/**
 * Firebase Cloud Function: Generate Wisdom Quote
 *
 * Generates a contextual wisdom quote based on journal themes.
 * Uses OpenAI GPT-4o-mini for relevant philosophical quotes.
 *
 * @param request.data.recentThemes - Array of recent journal themes
 * @param request.data.mood - Optional current mood
 * @returns Object with 'quote' containing text, author, source, and relevance
 */
export const generateWisdomQuoteNightprep = onCall(
  {
    secrets: [openaiApiKey],
    cors: true,
    maxInstances: 10,
    timeoutSeconds: 30,
  },
  async (request) => {
    const data = request.data as WisdomQuoteRequest;

    if (!data.recentThemes || !Array.isArray(data.recentThemes)) {
      throw new HttpsError("invalid-argument", "recentThemes array is required");
    }

    if (data.recentThemes.length === 0) {
      throw new HttpsError(
        "invalid-argument",
        "recentThemes array cannot be empty"
      );
    }

    // Validate theme strings
    for (let i = 0; i < data.recentThemes.length; i++) {
      if (typeof data.recentThemes[i] !== "string" || data.recentThemes[i].trim().length === 0) {
        throw new HttpsError(
          "invalid-argument",
          `Theme at index ${i} must be a non-empty string`
        );
      }
    }

    try {
      const quote = await generateWisdomQuoteWithAI({
        recentThemes: data.recentThemes,
        mood: data.mood,
      });

      return { quote };
    } catch (error) {
      console.error("Error generating wisdom quote:", error);

      if (error instanceof Error) {
        if (error.message.includes("API key")) {
          throw new HttpsError("internal", "Service configuration error");
        }
        if (error.message.includes("rate limit")) {
          throw new HttpsError(
            "resource-exhausted",
            "Service temporarily unavailable"
          );
        }
        if (error.message.includes("parse") || error.message.includes("JSON")) {
          throw new HttpsError("internal", "Failed to process wisdom quote");
        }
      }

      throw new HttpsError("internal", "Failed to generate wisdom quote");
    }
  }
);

/**
 * Firebase Cloud Function: Generate Session Summary
 *
 * Generates a brief summary of a completed journal session.
 * Captures key themes, emotions, and insights explored.
 *
 * @param request.data.exchanges - Array of session exchanges with question/answer/clarityMirror
 * @returns Object with 'summary' string containing 2-3 sentence summary
 */
export const generateSessionSummaryNightprep = onCall(
  {
    secrets: [openaiApiKey],
    cors: true,
    maxInstances: 10,
    timeoutSeconds: 30,
  },
  async (request) => {
    const data = request.data as SessionSummaryRequest;

    if (!data.exchanges || !Array.isArray(data.exchanges) || data.exchanges.length === 0) {
      throw new HttpsError("invalid-argument", "exchanges array is required and cannot be empty");
    }

    // Validate each exchange structure
    for (let i = 0; i < data.exchanges.length; i++) {
      const exchange = data.exchanges[i];

      if (!exchange.question || typeof exchange.question !== "string") {
        throw new HttpsError(
          "invalid-argument",
          `Exchange ${i + 1}: question is required and must be a string`
        );
      }

      if (!exchange.answer || typeof exchange.answer !== "string") {
        throw new HttpsError(
          "invalid-argument",
          `Exchange ${i + 1}: answer is required and must be a string`
        );
      }

      if (exchange.answer.trim().length === 0) {
        throw new HttpsError(
          "invalid-argument",
          `Exchange ${i + 1}: answer cannot be empty`
        );
      }

      if (
        exchange.clarityMirror !== undefined &&
        typeof exchange.clarityMirror !== "string"
      ) {
        throw new HttpsError(
          "invalid-argument",
          `Exchange ${i + 1}: clarityMirror must be a string if provided`
        );
      }
    }

    try {
      const summary = await generateSessionSummaryWithAI(data);
      return { summary };
    } catch (error) {
      console.error("Error generating session summary:", error);

      if (error instanceof Error) {
        if (error.message.includes("API key")) {
          throw new HttpsError("internal", "Service configuration error");
        }
        if (error.message.includes("rate limit")) {
          throw new HttpsError(
            "resource-exhausted",
            "Service temporarily unavailable"
          );
        }
      }

      throw new HttpsError("internal", "Failed to generate session summary");
    }
  }
);

/**
 * Firebase Cloud Function: Enhance Future Letter
 *
 * Generates AI-powered reflection prompts to help users write more meaningful
 * letters to their future selves.
 *
 * @param request.data.letterContent - The current letter content
 * @param request.data.letterTheme - Optional theme for the letter
 * @param request.data.deliveryDate - Optional delivery date string
 * @returns Object with 'prompts' array and 'encouragement' string
 */
export const enhanceFutureLetterNightprep = onCall(
  {
    secrets: [openaiApiKey],
    cors: true,
    maxInstances: 10,
    timeoutSeconds: 30,
  },
  async (request) => {
    const data = request.data as LetterEnhancementRequest;

    if (!data.letterContent || typeof data.letterContent !== "string") {
      throw new HttpsError("invalid-argument", "letterContent is required");
    }

    if (data.letterContent.trim().length === 0) {
      throw new HttpsError("invalid-argument", "letterContent cannot be empty");
    }

    try {
      const enhancement = await enhanceFutureLetterWithAI({
        letterContent: data.letterContent,
        letterTheme: data.letterTheme,
        deliveryDate: data.deliveryDate,
      });

      return enhancement;
    } catch (error) {
      console.error("Error enhancing future letter:", error);

      if (error instanceof Error) {
        if (error.message.includes("API key")) {
          throw new HttpsError("internal", "Service configuration error");
        }
        if (error.message.includes("rate limit")) {
          throw new HttpsError(
            "resource-exhausted",
            "Service temporarily unavailable"
          );
        }
        if (error.message.includes("parse") || error.message.includes("JSON")) {
          throw new HttpsError("internal", "Failed to process letter enhancement");
        }
      }

      throw new HttpsError("internal", "Failed to enhance letter");
    }
  }
);

/**
 * Health check endpoint for monitoring
 */
export const healthCheck = onCall(
  {
    cors: true,
  },
  async () => {
    return {
      status: "ok",
      timestamp: new Date().toISOString(),
      version: "1.0.0",
    };
  }
);
