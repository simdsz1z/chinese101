export interface UserProfile {
  uid: string;
  displayName: string;
  photoURL: string;
  xp: number;
  level: number;
  streak: number;
  lastActive: string;
  totalCharactersLearned: number;
  role?: 'user' | 'admin';
}

export interface ProgressItem {
  userId: string;
  itemId: string;
  mastery: number;
  lastReviewed: string;
}

export interface DailyChallenge {
  id: string;
  date: string;
  type: 'vocabulary' | 'translation' | 'listening';
  content: {
    question: string;
    options: string[];
    answer: string;
    explanation: string;
    pinyin?: string;
    character?: string;
  };
}

export interface Lesson {
  id: string;
  title: string;
  description: string;
  characters: {
    char: string;
    pinyin: string;
    meaning: string;
    examples: string[];
  }[];
  xpReward: number;
}
