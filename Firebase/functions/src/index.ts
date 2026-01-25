import { onCall, HttpsError } from "firebase-functions/v2/https";
import {
  openaiApiKey,
  generateClarityMirrorWithAI,
  generateFollowUpQuestionWithAI,
  generateSocratesReactionWithAI,
  ClarityMirrorRequest,
  FollowUpQuestionRequest,
  SocratesReactionRequest,
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
