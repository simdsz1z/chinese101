import { ReactNode, useEffect, useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Home, Trophy, Map, User, LogOut } from 'lucide-react';
import { cn } from '../lib/utils';
import { localStore } from '../lib/localData';
import { UserProfile } from '../types';

interface LayoutProps {
  children: ReactNode;
}

export function Layout({ children }: LayoutProps) {
  const location = useLocation();
  const [user, setUser] = useState<UserProfile | null>(localStore.getProfile());

  useEffect(() => {
    const handleUpdate = () => {
      setUser(localStore.getProfile());
    };
    window.addEventListener('local-data-updated', handleUpdate);
    return () => window.removeEventListener('local-data-updated', handleUpdate);
  }, []);

  const navItems = [
    { icon: Home, label: 'Home', path: '/' },
    { icon: Map, label: 'Quest', path: '/quest' },
    { icon: Trophy, label: 'Leaderboard', path: '/leaderboard' },
    { icon: User, label: 'Profile', path: '/profile' },
  ];

  const handleLogout = () => {
    localStore.setProfile(null);
  };

  return (
    <div className="min-h-screen bg-bg flex flex-col md:flex-row text-white">
      {/* Sidebar - Desktop */}
      <aside className="hidden md:flex flex-col w-64 bg-bg border-r border-white/10 p-10 fixed h-full">
        <div className="mb-12">
          <h1 className="text-2xl font-black tracking-tighter uppercase">
            Hanzi Master.
          </h1>
        </div>

        <nav className="flex-1 space-y-4">
          <span className="section-label">Menu</span>
          {navItems.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              className={cn(
                "flex items-center gap-3 px-0 py-2 transition-all font-bold text-sm uppercase tracking-wider",
                location.pathname === item.path
                  ? "text-accent"
                  : "text-text-dim hover:text-white"
              )}
            >
              <item.icon size={18} />
              {item.label}
            </Link>
          ))}
        </nav>

        <div className="mt-auto pt-6 border-t border-white/10">
          <div className="flex items-center gap-3 mb-6">
            <img 
              src={user?.photoURL || 'https://picsum.photos/seed/user/100/100'} 
              alt="Avatar" 
              className="w-10 h-10 rounded-lg bg-surface"
              referrerPolicy="no-referrer"
            />
            <div className="overflow-hidden">
              <p className="font-bold text-sm truncate">{user?.displayName}</p>
              <p className="text-[10px] text-text-dim uppercase font-bold tracking-tighter">Level 12 Learner</p>
            </div>
          </div>
          <button
            onClick={handleLogout}
            className="flex items-center gap-3 w-full text-accent hover:opacity-80 transition-all font-bold text-xs uppercase tracking-widest"
          >
            <LogOut size={16} />
            Sign Out
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 md:ml-64 p-4 md:p-10 pb-24 md:pb-10">
        <div className="max-w-5xl mx-auto">
          {children}
        </div>
      </main>

      {/* Bottom Nav - Mobile */}
      <nav className="md:hidden fixed bottom-0 left-0 right-0 bg-surface border-t border-white/10 px-6 py-4 flex justify-between items-center z-50">
        {navItems.map((item) => (
          <Link
            key={item.path}
            to={item.path}
            className={cn(
              "flex flex-col items-center gap-1 transition-all",
              location.pathname === item.path ? "text-accent" : "text-text-dim"
            )}
          >
            <item.icon size={20} />
            <span className="text-[8px] font-black uppercase tracking-widest">{item.label}</span>
          </Link>
        ))}
      </nav>
    </div>
  );
}
