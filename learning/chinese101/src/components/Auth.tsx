import { useState, useEffect, ReactNode } from 'react';
import { motion } from 'motion/react';
import { UserCircle, Loader2 } from 'lucide-react';
import { cn } from '../lib/utils';
import { localStore } from '../lib/localData';
import { UserProfile } from '../types';

export function Auth({ children }: { children: ReactNode }) {
  const [loading, setLoading] = useState(true);
  const [user, setUser] = useState<UserProfile | null>(null);
  const [loginLoading, setLoginLoading] = useState(false);
  const [guestName, setGuestName] = useState('');

  useEffect(() => {
    // Check local storage for existing profile
    const profile = localStore.getProfile();
    setUser(profile);
    setLoading(false);

    const handleUpdate = () => {
      setUser(localStore.getProfile());
    };
    window.addEventListener('local-data-updated', handleUpdate);
    return () => window.removeEventListener('local-data-updated', handleUpdate);
  }, []);

  const handleGuestLogin = () => {
    setLoginLoading(true);
    setTimeout(() => {
      const newProfile: UserProfile = {
        uid: 'local-' + Date.now(),
        displayName: guestName || 'Guest Explorer',
        photoURL: `https://picsum.photos/seed/${Date.now()}/200/200`,
        xp: 0,
        level: 1,
        streak: 1,
        lastActive: new Date().toISOString(),
        totalCharactersLearned: 0,
        role: 'user'
      };
      localStore.setProfile(newProfile);
      setUser(newProfile);
      setLoginLoading(false);
    }, 800);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-bg">
        <Loader2 className="w-8 h-8 animate-spin text-accent" />
      </div>
    );
  }

  if (!user) {
    return (
      <div className="min-h-screen bg-bg flex items-center justify-center p-6">
        <motion.div 
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="max-w-md w-full bg-surface p-12 rounded-[40px] border border-white/10 text-center"
        >
          <div className="mb-12">
            <h1 className="text-5xl font-black tracking-tighter uppercase mb-2">Hanzi Master.</h1>
            <p className="text-text-dim font-bold uppercase tracking-widest text-xs">Local Development Mode</p>
          </div>
          
          <div className="space-y-6 mb-12 text-left">
            <span className="section-label">Create Local Profile</span>
            <input 
              type="text"
              placeholder="Enter your name..."
              value={guestName}
              onChange={(e) => setGuestName(e.target.value)}
              className="w-full bg-bg border border-white/10 rounded-xl p-4 text-white font-bold focus:border-accent outline-none transition-all"
            />
          </div>

          <button
            onClick={handleGuestLogin}
            disabled={loginLoading}
            className={cn(
              "w-full bg-white text-black py-5 rounded-2xl font-black uppercase tracking-widest transition-all flex items-center justify-center gap-3 shadow-xl",
              loginLoading ? "opacity-50 cursor-not-allowed" : "hover:bg-white/90"
            )}
          >
            {loginLoading ? (
              <Loader2 className="w-5 h-5 animate-spin" />
            ) : (
              <>
                <UserCircle size={20} />
                Start Learning
              </>
            )}
          </button>

          <p className="mt-8 text-[10px] text-text-dim font-bold uppercase tracking-widest leading-relaxed">
            Note: Your progress is saved in your browser's local storage.
          </p>
        </motion.div>
      </div>
    );
  }

  return <>{children}</>;
}
