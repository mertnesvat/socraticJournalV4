import {
  CLARITY_MIRROR_SYSTEM_PROMPT,
  FOLLOW_UP_QUESTION_SYSTEM_PROMPT,
  ClarityMirrorRequest,
  FollowUpQuestionRequest,
} from "./openai";

describe("OpenAI Service", () => {
  describe("CLARITY_MIRROR_SYSTEM_PROMPT", () => {
    it("should include guidelines for response format", () => {
      expect(CLARITY_MIRROR_SYSTEM_PROMPT).toContain("2-3 sentences");
      expect(CLARITY_MIRROR_SYSTEM_PROMPT).toContain("It sounds like");
    });

    it("should include instructions for handling gibberish", () => {
      expect(CLARITY_MIRROR_SYSTEM_PROMPT).toContain("gibberish");
      expect(CLARITY_MIRROR_SYSTEM_PROMPT).toContain("nonsensical");
      expect(CLARITY_MIRROR_SYSTEM_PROMPT).toContain("trouble understanding");
    });

    it("should include example for normal input", () => {
      expect(CLARITY_MIRROR_SYSTEM_PROMPT).toContain("job interview");
      expect(CLARITY_MIRROR_SYSTEM_PROMPT).toContain("nervousness");
    });

    it("should include example for gibberish input", () => {
      expect(CLARITY_MIRROR_SYSTEM_PROMPT).toContain("asdfasdf");
      expect(CLARITY_MIRROR_SYSTEM_PROMPT).toContain("not quite sure");
    });

    it("should instruct not to give advice", () => {
      expect(CLARITY_MIRROR_SYSTEM_PROMPT).toContain("Never give advice");
    });
  });

  describe("FOLLOW_UP_QUESTION_SYSTEM_PROMPT", () => {
    it("should require exactly one question", () => {
      expect(FOLLOW_UP_QUESTION_SYSTEM_PROMPT).toContain("exactly ONE question");
    });

    it("should require open-ended questions", () => {
      expect(FOLLOW_UP_QUESTION_SYSTEM_PROMPT).toContain("open-ended");
      expect(FOLLOW_UP_QUESTION_SYSTEM_PROMPT).toContain("yes/no");
    });

    it("should discourage why questions", () => {
      expect(FOLLOW_UP_QUESTION_SYSTEM_PROMPT).toContain('Avoid "why"');
    });

    it("should include the standard Socratic flow", () => {
      expect(FOLLOW_UP_QUESTION_SYSTEM_PROMPT).toContain("What's on your mind");
      expect(FOLLOW_UP_QUESTION_SYSTEM_PROMPT).toContain("Why does this matter");
      expect(FOLLOW_UP_QUESTION_SYSTEM_PROMPT).toContain("feel like to resolve");
      expect(FOLLOW_UP_QUESTION_SYSTEM_PROMPT).toContain("small step");
      expect(FOLLOW_UP_QUESTION_SYSTEM_PROMPT).toContain("future self");
    });
  });

  describe("ClarityMirrorRequest interface", () => {
    it("should accept valid request object", () => {
      const request: ClarityMirrorRequest = {
        question: "What's on your mind?",
        answer: "I am feeling anxious",
      };
      expect(request.question).toBeDefined();
      expect(request.answer).toBeDefined();
    });

    it("should accept optional previousExchanges", () => {
      const request: ClarityMirrorRequest = {
        question: "Test question",
        answer: "Test answer",
        previousExchanges: [
          { question: "Q1", answer: "A1" },
          { question: "Q2", answer: "A2" },
        ],
      };
      expect(request.previousExchanges).toHaveLength(2);
    });
  });

  describe("FollowUpQuestionRequest interface", () => {
    it("should accept valid request object", () => {
      const request: FollowUpQuestionRequest = {
        currentQuestion: "What's on your mind?",
        currentAnswer: "Work stress",
        questionIndex: 0,
      };
      expect(request.currentQuestion).toBeDefined();
      expect(request.currentAnswer).toBeDefined();
      expect(request.questionIndex).toBe(0);
    });

    it("should accept optional previousExchanges", () => {
      const request: FollowUpQuestionRequest = {
        currentQuestion: "Test",
        currentAnswer: "Test",
        questionIndex: 2,
        previousExchanges: [{ question: "Q", answer: "A" }],
      };
      expect(request.previousExchanges).toHaveLength(1);
    });
  });
});
