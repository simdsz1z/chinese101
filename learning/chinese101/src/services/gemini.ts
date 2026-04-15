import { GoogleGenAI, Type } from "@google/genai";

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

export async function generateDailyChallenge() {
  const response = await ai.models.generateContent({
    model: "gemini-3-flash-preview",
    contents: "Generate a daily Chinese learning challenge. It should be a multiple choice question about a common Chinese character or phrase. Include pinyin, meaning, and a brief explanation.",
    config: {
      responseMimeType: "application/json",
      responseSchema: {
        type: Type.OBJECT,
        properties: {
          type: { type: Type.STRING, enum: ["vocabulary", "translation"] },
          content: {
            type: Type.OBJECT,
            properties: {
              question: { type: Type.STRING },
              options: { type: Type.ARRAY, items: { type: Type.STRING } },
              answer: { type: Type.STRING },
              explanation: { type: Type.STRING },
              pinyin: { type: Type.STRING },
              character: { type: Type.STRING }
            },
            required: ["question", "options", "answer", "explanation"]
          }
        },
        required: ["type", "content"]
      }
    }
  });

  return JSON.parse(response.text);
}

export async function generatePracticeSession(level: number) {
  const response = await ai.models.generateContent({
    model: "gemini-3-flash-preview",
    contents: `Generate 5 Chinese practice items for level ${level}. Each item should have a character, pinyin, meaning, and 3 options for a multiple choice quiz.`,
    config: {
      responseMimeType: "application/json",
      responseSchema: {
        type: Type.ARRAY,
        items: {
          type: Type.OBJECT,
          properties: {
            character: { type: Type.STRING },
            pinyin: { type: Type.STRING },
            meaning: { type: Type.STRING },
            options: { type: Type.ARRAY, items: { type: Type.STRING } },
            answer: { type: Type.STRING }
          },
          required: ["character", "pinyin", "meaning", "options", "answer"]
        }
      }
    }
  });

  return JSON.parse(response.text);
}
