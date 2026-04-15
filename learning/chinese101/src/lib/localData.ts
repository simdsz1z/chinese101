import { UserProfile, ProgressItem, DailyChallenge } from '../types';

const STORAGE_KEY = 'zhongwen_quest_data';

interface LocalData {
  profile: UserProfile | null;
  progress: ProgressItem[];
  challenges: DailyChallenge[];
}

const DEFAULT_DATA: LocalData = {
  profile: null,
  progress: [],
  challenges: [
    {
      id: 'daily-1',
      date: new Date().toISOString(),
      type: 'vocabulary',
      content: {
        question: 'What is the meaning of 龍?',
        options: ['Dragon', 'Tiger', 'Mountain', 'Fire'],
        answer: 'Dragon',
        explanation: '龍 (lóng) means Dragon.',
        character: '龍',
        pinyin: 'lóng'
      }
    }
  ]
};

export const localStore = {
  getData(): LocalData {
    const data = localStorage.getItem(STORAGE_KEY);
    if (!data) return DEFAULT_DATA;
    return JSON.parse(data);
  },

  saveData(data: LocalData) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
  },

  getProfile(): UserProfile | null {
    return this.getData().profile;
  },

  setProfile(profile: UserProfile | null) {
    const data = this.getData();
    data.profile = profile;
    this.saveData(data);
    // Trigger a custom event for real-time updates in components
    window.dispatchEvent(new Event('local-data-updated'));
  },

  updateProfile(updates: Partial<UserProfile>) {
    const profile = this.getProfile();
    if (profile) {
      this.setProfile({ ...profile, ...updates });
    }
  },

  addXP(amount: number) {
    const profile = this.getProfile();
    if (profile) {
      const newXP = profile.xp + amount;
      const newLevel = Math.floor(newXP / 500) + 1;
      this.updateProfile({ 
        xp: newXP, 
        level: newLevel,
        totalCharactersLearned: profile.totalCharactersLearned + 1
      });
    }
  },

  incrementStreak() {
    const profile = this.getProfile();
    if (profile) {
      this.updateProfile({ streak: profile.streak + 1 });
    }
  }
};
