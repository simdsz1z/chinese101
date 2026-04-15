import { useState, useEffect } from 'react';
import { UserProfile } from '../types';
import { Settings, Award, Calendar, Book, ShieldCheck } from 'lucide-react';
import { motion } from 'motion/react';
import { cn } from '../lib/utils';
import { localStore } from '../lib/localData';

export function Profile() {
  const [profile, setProfile] = useState<UserProfile | null>(null);

  useEffect(() => {
    const loadProfile = () => {
      setProfile(localStore.getProfile());
    };
    loadProfile();
    window.addEventListener('local-data-updated', loadProfile);
    return () => window.removeEventListener('local-data-updated', loadProfile);
  }, []);

  if (!profile) return null;

  return (
    <div className="space-y-12">
      <div className="bg-surface p-12 rounded-[40px] border border-white/10 text-center relative overflow-hidden">
        <div className="absolute top-8 right-8">
          <button className="text-text-dim hover:text-white transition-colors">
            <Settings size={24} />
          </button>
        </div>
        
        <div className="relative inline-block mb-8">
          <img 
            src={profile.photoURL || 'https://picsum.photos/seed/profile/200/200'} 
            alt="Profile" 
            className="w-32 h-32 rounded-2xl border-4 border-white/5 mx-auto bg-bg"
            referrerPolicy="no-referrer"
          />
          <div className="absolute -bottom-3 -right-3 bg-accent text-white w-12 h-12 rounded-xl flex items-center justify-center font-black border-4 border-surface text-xl">
            {profile.level}
          </div>
        </div>

        <h1 className="text-4xl font-black uppercase tracking-tighter mb-2">{profile.displayName}</h1>
        <p className="text-text-dim font-bold uppercase tracking-widest text-xs mb-10">Joined April 2026</p>

        <div className="grid grid-cols-2 sm:grid-cols-4 gap-6">
          <div className="p-6 bg-bg rounded-2xl border border-white/5">
            <p className="text-3xl font-black text-white">{profile.xp}</p>
            <p className="section-label mb-0 mt-1">Total XP</p>
          </div>
          <div className="p-6 bg-bg rounded-2xl border border-white/5">
            <p className="text-3xl font-black text-white">{profile.streak}</p>
            <p className="section-label mb-0 mt-1">Day Streak</p>
          </div>
          <div className="p-6 bg-bg rounded-2xl border border-white/5">
            <p className="text-3xl font-black text-white">{profile.totalCharactersLearned}</p>
            <p className="section-label mb-0 mt-1">Characters</p>
          </div>
          <div className="p-6 bg-bg rounded-2xl border border-white/5">
            <p className="text-3xl font-black text-accent">TOP 5%</p>
            <p className="section-label mb-0 mt-1">Ranking</p>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        <section className="bg-surface p-10 rounded-3xl border border-white/5">
          <span className="section-label">Achievements</span>
          <div className="space-y-4">
            {[
              { title: 'Early Bird', desc: 'Complete a lesson before 8 AM', icon: Calendar, color: 'text-blue-400' },
              { title: 'Character Master', desc: 'Learn 100 characters', icon: Book, color: 'text-green-400' },
              { title: 'Streak Legend', desc: 'Reach a 7-day streak', icon: ShieldCheck, color: 'text-accent' },
            ].map((ach) => (
              <div key={ach.title} className="flex items-center gap-4 p-5 bg-bg rounded-xl opacity-30 grayscale border border-white/5">
                <div className={cn("w-12 h-12 rounded-lg bg-surface flex items-center justify-center", ach.color)}>
                  <ach.icon size={24} />
                </div>
                <div>
                  <p className="font-black uppercase tracking-tight text-sm">{ach.title}</p>
                  <p className="text-[10px] text-text-dim font-bold uppercase tracking-wider">{ach.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </section>

        <section className="bg-surface p-10 rounded-3xl border border-white/5">
          <span className="section-label">Learning Stats</span>
          <div className="space-y-8">
            <div>
              <div className="flex justify-between text-[10px] font-black uppercase tracking-widest mb-3">
                <span>Listening</span>
                <span className="text-blue-400">75%</span>
              </div>
              <div className="w-full h-2 bg-bg rounded-full overflow-hidden border border-white/5">
                <div className="h-full bg-blue-500 w-[75%]" />
              </div>
            </div>
            <div>
              <div className="flex justify-between text-[10px] font-black uppercase tracking-widest mb-3">
                <span>Reading</span>
                <span className="text-green-400">40%</span>
              </div>
              <div className="w-full h-2 bg-bg rounded-full overflow-hidden border border-white/5">
                <div className="h-full bg-green-500 w-[40%]" />
              </div>
            </div>
            <div>
              <div className="flex justify-between text-[10px] font-black uppercase tracking-widest mb-3">
                <span>Writing</span>
                <span className="text-accent">20%</span>
              </div>
              <div className="w-full h-2 bg-bg rounded-full overflow-hidden border border-white/5">
                <div className="h-full bg-accent w-[20%]" />
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}
