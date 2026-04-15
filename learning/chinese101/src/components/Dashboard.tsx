import { useState, useEffect } from 'react';
import { Zap, Flame, Star, ChevronRight, Play, BookOpen, Trophy } from 'lucide-react';
import { UserProfile, DailyChallenge } from '../types';
import { Link } from 'react-router-dom';
import { motion } from 'motion/react';
import { localStore } from '../lib/localData';

export function Dashboard() {
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [challenge, setChallenge] = useState<DailyChallenge | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadData = () => {
      const data = localStore.getData();
      setProfile(data.profile);
      setChallenge(data.challenges[0] || null);
      setLoading(false);
    };

    loadData();
    window.addEventListener('local-data-updated', loadData);
    return () => window.removeEventListener('local-data-updated', loadData);
  }, []);

  if (loading) return null;

  return (
    <div className="space-y-12">
      {/* Header Stats */}
      <section className="grid grid-cols-1 sm:grid-cols-3 gap-6">
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-surface p-8 rounded-2xl border border-white/5 flex items-center gap-4"
        >
          <div className="text-accent">
            <Flame size={24} />
          </div>
          <div>
            <p className="section-label mb-1">Streak</p>
            <p className="text-3xl font-black">{profile?.streak || 0} DAYS</p>
          </div>
        </motion.div>

        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="bg-surface p-8 rounded-2xl border border-white/5 flex items-center gap-4"
        >
          <div className="text-gold">
            <Zap size={24} />
          </div>
          <div>
            <p className="section-label mb-1">Total XP</p>
            <p className="text-3xl font-black">{profile?.xp || 0}</p>
          </div>
        </motion.div>

        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="bg-surface p-8 rounded-2xl border border-white/5 flex items-center gap-4"
        >
          <div className="text-blue-400">
            <Star size={24} />
          </div>
          <div>
            <p className="section-label mb-1">Level</p>
            <p className="text-3xl font-black">{profile?.level || 1}</p>
          </div>
        </motion.div>
      </section>

      {/* Daily Challenge */}
      <section className="bg-surface p-10 rounded-3xl border border-white/10 relative overflow-hidden">
        <div className="relative z-10">
          <span className="section-label">Daily Challenge</span>
          <h2 className="text-4xl font-black mb-4 tracking-tighter uppercase">The Character of the Day</h2>
          <p className="text-text-dim mb-8 max-w-md font-medium">
            Test your knowledge of common radicals and unlock bonus XP for your daily streak.
          </p>
          <Link 
            to="/practice/daily"
            className="inline-flex items-center gap-2 bg-accent text-white px-10 py-4 rounded-xl font-black uppercase tracking-widest hover:opacity-90 transition-all"
          >
            <Play size={18} fill="currentColor" />
            Start Challenge
          </Link>
        </div>
        <div className="absolute top-0 right-0 p-10 opacity-5 pointer-events-none">
          <span className="text-[240px] leading-none font-bold">龍</span>
        </div>
      </section>

      {/* Quick Actions / Progress */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        <section className="bg-surface p-10 rounded-3xl border border-white/5">
          <div className="flex items-center justify-between mb-8">
            <span className="section-label mb-0">Next Lesson</span>
            <BookOpen size={20} className="text-accent" />
          </div>
          <div className="space-y-4">
            <div className="p-5 bg-bg rounded-xl border border-white/5 flex items-center justify-between group cursor-pointer hover:border-accent/50 transition-all">
              <div>
                <p className="font-black text-sm uppercase tracking-tight">Unit 4: At the Market</p>
                <p className="text-[10px] text-text-dim font-bold uppercase tracking-wider">5 characters • 50 XP</p>
              </div>
              <ChevronRight className="text-text-dim group-hover:text-accent transition-colors" />
            </div>
            <div className="p-5 bg-bg rounded-xl border border-white/5 flex items-center justify-between group cursor-pointer hover:border-accent/50 transition-all">
              <div>
                <p className="font-black text-sm uppercase tracking-tight">Review: Common Verbs</p>
                <p className="text-[10px] text-text-dim font-bold uppercase tracking-wider">10 characters • 30 XP</p>
              </div>
              <ChevronRight className="text-text-dim group-hover:text-accent transition-colors" />
            </div>
          </div>
        </section>

        <section className="bg-surface p-10 rounded-3xl border border-white/5">
          <div className="flex items-center justify-between mb-8">
            <span className="section-label mb-0">Recent Mastery</span>
            <Trophy size={20} className="text-gold" />
          </div>
          <div className="grid grid-cols-3 gap-4">
            {['你好', '谢谢', '再见'].map((char) => (
              <div key={char} className="aspect-square bg-bg rounded-xl border border-white/5 flex flex-col items-center justify-center p-4">
                <span className="text-2xl font-bold mb-3">{char}</span>
                <div className="w-full h-1.5 bg-white/10 rounded-full overflow-hidden">
                  <div className="h-full bg-accent w-[80%]" />
                </div>
              </div>
            ))}
          </div>
        </section>
      </div>
    </div>
  );
}
