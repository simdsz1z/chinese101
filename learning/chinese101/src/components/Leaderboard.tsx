import { useState, useEffect } from 'react';
import { Trophy, Medal, Award } from 'lucide-react';
import { UserProfile } from '../types';
import { cn } from '../lib/utils';
import { motion } from 'motion/react';
import { localStore } from '../lib/localData';

export function Leaderboard() {
  const [users, setUsers] = useState<UserProfile[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadLeaderboard = () => {
      const profile = localStore.getProfile();
      
      // Mock other users for the leaderboard
      const mockUsers: UserProfile[] = [
        { uid: '1', displayName: 'DragonMaster', xp: 2500, level: 6, streak: 12, photoURL: 'https://picsum.photos/seed/1/100/100', lastActive: '', totalCharactersLearned: 50, role: 'user' },
        { uid: '2', displayName: 'HanziHero', xp: 1800, level: 4, streak: 8, photoURL: 'https://picsum.photos/seed/2/100/100', lastActive: '', totalCharactersLearned: 35, role: 'user' },
        { uid: '3', displayName: 'PinyinPro', xp: 1200, level: 3, streak: 5, photoURL: 'https://picsum.photos/seed/3/100/100', lastActive: '', totalCharactersLearned: 20, role: 'user' },
      ];

      if (profile) {
        // Remove existing local user if present in mock (unlikely with IDs but good practice)
        const filtered = mockUsers.filter(u => u.uid !== profile.uid);
        filtered.push(profile);
        const sorted = filtered.sort((a, b) => b.xp - a.xp);
        setUsers(sorted);
      } else {
        setUsers(mockUsers.sort((a, b) => b.xp - a.xp));
      }
      setLoading(false);
    };

    loadLeaderboard();
    window.addEventListener('local-data-updated', loadLeaderboard);
    return () => window.removeEventListener('local-data-updated', loadLeaderboard);
  }, []);

  if (loading) return null;

  return (
    <div className="space-y-12">
      <div className="mb-12">
        <span className="section-label">Global Board</span>
        <h1 className="text-4xl font-black uppercase tracking-tighter">Hall of Fame</h1>
      </div>

      {/* Podium - Simplified for Bold Theme */}
      <div className="grid grid-cols-1 gap-4">
        {users.map((user, i) => {
          const isTop3 = i < 3;
          const isFirst = i === 0;
          
          return (
            <motion.div 
              key={user.uid}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: i * 0.05 }}
              className={cn(
                "flex items-center gap-6 p-6 rounded-2xl border transition-all",
                isFirst ? "bg-accent/10 border-accent/20" : "bg-surface border-white/5",
                !isTop3 && "opacity-70"
              )}
            >
              <span className={cn(
                "text-3xl font-black w-12",
                isFirst ? "text-accent" : "text-text-dim"
              )}>
                {String(i + 1).padStart(2, '0')}
              </span>
              
              <img 
                src={user.photoURL || `https://picsum.photos/seed/${user.uid}/100/100`} 
                alt={user.displayName}
                className={cn(
                  "w-12 h-12 rounded-lg bg-bg",
                  isFirst && "ring-2 ring-accent ring-offset-2 ring-offset-bg"
                )}
                referrerPolicy="no-referrer"
              />
              
              <div className="flex-1">
                <p className="font-black uppercase tracking-tight text-sm">{user.displayName}</p>
                <p className="text-[10px] text-text-dim font-bold uppercase tracking-widest">Level {user.level}</p>
              </div>
              
              <div className="text-right">
                <p className="font-black text-gold text-lg">{user.xp.toLocaleString()}</p>
                <p className="text-[8px] text-text-dim font-black uppercase tracking-[0.2em]">XP</p>
              </div>
            </motion.div>
          );
        })}
      </div>
    </div>
  );
}
