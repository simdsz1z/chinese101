import { motion } from 'motion/react';
import { Check, Lock, Star, Play } from 'lucide-react';
import { cn } from '../lib/utils';
import { Link } from 'react-router-dom';

const UNITS = [
  { id: 1, title: 'Basics 1', type: 'lesson', completed: true },
  { id: 2, title: 'Greetings', type: 'lesson', completed: true },
  { id: 3, title: 'Numbers', type: 'quiz', completed: false, active: true },
  { id: 4, title: 'Family', type: 'lesson', completed: false },
  { id: 5, title: 'Food', type: 'lesson', completed: false },
  { id: 6, title: 'Colors', type: 'quiz', completed: false },
];

export function LearningPath() {
  return (
    <div className="py-12 flex flex-col items-center relative">
      <div className="mb-16 text-center">
        <span className="section-label">Learning Path</span>
        <h1 className="text-4xl font-black uppercase tracking-tighter">The Quest</h1>
      </div>
      
      <div className="relative w-full max-w-xs flex flex-col items-center gap-16">
        {/* Path Line */}
        <div className="absolute top-0 bottom-0 w-1 bg-surface left-1/2 -translate-x-1/2 -z-10" />

        {UNITS.map((unit, index) => {
          const isEven = index % 2 === 0;
          return (
            <motion.div
              key={unit.id}
              initial={{ opacity: 0, x: isEven ? -50 : 50 }}
              animate={{ opacity: 1, x: isEven ? -20 : 20 }}
              transition={{ delay: index * 0.1 }}
              className="relative"
            >
              <Link 
                to={unit.active ? `/practice/${unit.id}` : '#'}
                className={cn(
                  "w-24 h-24 rounded-3xl flex items-center justify-center shadow-xl transition-all transform hover:scale-110 relative border-4",
                  unit.completed ? "bg-accent border-accent text-white" : 
                  unit.active ? "bg-surface border-accent text-accent shadow-[0_0_30px_rgba(255,62,62,0.3)]" : 
                  "bg-surface border-white/5 text-text-dim"
                )}
              >
                {unit.completed ? <Check size={32} /> : 
                 unit.active ? <Play size={32} fill="currentColor" /> : 
                 <Lock size={32} />}
                
                {/* Tooltip-like label */}
                <div className={cn(
                  "absolute top-1/2 -translate-y-1/2 whitespace-nowrap px-6 py-3 rounded-xl text-xs font-black uppercase tracking-widest shadow-xl border",
                  isEven ? "left-full ml-8" : "right-full mr-8",
                  unit.active ? "bg-accent border-accent text-white" : "bg-surface border-white/5 text-text-dim"
                )}>
                  {unit.title}
                  {unit.type === 'quiz' && <Star size={14} className="inline ml-2 text-gold fill-gold" />}
                </div>
              </Link>
            </motion.div>
          );
        })}
      </div>
    </div>
  );
}
