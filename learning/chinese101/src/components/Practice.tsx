import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { motion, AnimatePresence } from 'motion/react';
import { X, CheckCircle2, AlertCircle, ArrowRight, Loader2 } from 'lucide-react';
import { cn } from '../lib/utils';
import { localStore } from '../lib/localData';

// Mock character data for local development
const MOCK_CHARACTERS = [
  { character: '永', pinyin: 'yǒng', answer: 'forever', options: ['forever', 'dragon', 'peace', 'water'] },
  { character: '龍', pinyin: 'lóng', answer: 'dragon', options: ['dragon', 'tiger', 'mountain', 'fire'] },
  { character: '和', pinyin: 'hé', answer: 'peace', options: ['peace', 'war', 'food', 'drink'] },
  { character: '山', pinyin: 'shān', answer: 'mountain', options: ['mountain', 'river', 'forest', 'sky'] },
  { character: '火', pinyin: 'huǒ', answer: 'fire', options: ['fire', 'water', 'earth', 'air'] },
];

export function Practice() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [items, setItems] = useState<any[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [selectedOption, setSelectedOption] = useState<string | null>(null);
  const [isCorrect, setIsCorrect] = useState<boolean | null>(null);
  const [loading, setLoading] = useState(true);
  const [score, setScore] = useState(0);
  const [finished, setFinished] = useState(false);

  useEffect(() => {
    // Simulate loading
    const timer = setTimeout(() => {
      setItems(MOCK_CHARACTERS);
      setLoading(false);
    }, 800);
    return () => clearTimeout(timer);
  }, [id]);

  const handleCheck = () => {
    if (!selectedOption) return;

    const currentItem = items[currentIndex];
    const correct = selectedOption === currentItem.answer;
    setIsCorrect(correct);
    if (correct) setScore(s => s + 10);

    // If it's the last item, finish the session
    if (currentIndex === items.length - 1) {
      setTimeout(() => setFinished(true), 1500);
    }
  };

  const handleNext = () => {
    setCurrentIndex(i => i + 1);
    setSelectedOption(null);
    setIsCorrect(null);
  };

  const handleFinish = () => {
    localStore.addXP(score);
    navigate('/');
  };

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] gap-4">
        <Loader2 className="w-12 h-12 animate-spin text-[#5A5A40]" />
        <p className="text-gray-500 italic">Generating your practice session...</p>
      </div>
    );
  }

  if (finished) {
    return (
      <motion.div 
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        className="max-w-md mx-auto text-center py-12"
      >
        <div className="w-32 h-32 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-8 text-yellow-600">
          <CheckCircle2 size={64} />
        </div>
        <h2 className="text-4xl font-bold mb-4 font-serif">Quest Complete!</h2>
        <p className="text-xl text-gray-600 mb-8">You earned <span className="text-[#5A5A40] font-bold">{score} XP</span></p>
        <button
          onClick={handleFinish}
          className="w-full bg-[#5A5A40] text-white py-4 rounded-full font-bold text-lg shadow-lg hover:bg-[#4a4a35] transition-all"
        >
          Back to Dashboard
        </button>
      </motion.div>
    );
  }

  const currentItem = items[currentIndex];

  return (
    <div className="max-w-3xl mx-auto min-h-screen flex flex-col py-10">
      {/* Progress Bar */}
      <div className="flex items-center gap-6 mb-16 px-4">
        <button onClick={() => navigate('/')} className="text-text-dim hover:text-white transition-colors">
          <X size={24} />
        </button>
        <div className="flex-1 h-2 bg-surface rounded-full overflow-hidden border border-white/5">
          <motion.div 
            className="h-full bg-accent"
            initial={{ width: 0 }}
            animate={{ width: `${((currentIndex + 1) / items.length) * 100}%` }}
          />
        </div>
      </div>

      <AnimatePresence mode="wait">
        <motion.div
          key={currentIndex}
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          exit={{ opacity: 0, scale: 1.05 }}
          className="flex-1 flex flex-col items-center justify-center space-y-12 px-4"
        >
          <div className="text-center space-y-2">
            <h2 className="text-[180px] font-thin leading-none text-white tracking-tighter">{currentItem.character}</h2>
            <p className="text-3xl text-text-dim font-light tracking-[0.2em] uppercase">{currentItem.pinyin}</p>
            <span className="section-label mt-8">Select the correct meaning</span>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 w-full max-w-xl">
            {currentItem.options.map((option: string) => (
              <button
                key={option}
                disabled={isCorrect !== null}
                onClick={() => setSelectedOption(option)}
                className={cn(
                  "p-8 rounded-2xl border-2 text-center text-lg font-black uppercase tracking-tight transition-all transform active:scale-[0.98]",
                  selectedOption === option 
                    ? "border-accent bg-accent/10" 
                    : "border-transparent bg-surface hover:bg-white/5",
                  isCorrect !== null && option === currentItem.answer && "border-green-500 bg-green-500/10",
                  isCorrect === false && selectedOption === option && "border-accent bg-accent/10"
                )}
              >
                {option}
              </button>
            ))}
          </div>
        </motion.div>
      </AnimatePresence>

      {/* Footer Action */}
      <div className="mt-12 px-4">
        {isCorrect === null ? (
          <button
            disabled={!selectedOption}
            onClick={handleCheck}
            className={cn(
              "w-full py-6 rounded-2xl font-black text-sm uppercase tracking-[0.2em] transition-all shadow-xl",
              selectedOption 
                ? "bg-accent text-white hover:opacity-90" 
                : "bg-surface text-text-dim cursor-not-allowed"
            )}
          >
            Check Answer
          </button>
        ) : (
          <div className={cn(
            "p-8 rounded-3xl flex items-center justify-between animate-in slide-in-from-bottom-4 duration-300 border",
            isCorrect ? "bg-green-500/10 border-green-500/20 text-green-400" : "bg-accent/10 border-accent/20 text-accent"
          )}>
            <div className="flex items-center gap-4">
              {isCorrect ? <CheckCircle2 size={32} /> : <AlertCircle size={32} />}
              <div>
                <p className="font-black text-xl uppercase tracking-tight">{isCorrect ? 'Correct' : 'Incorrect'}</p>
                {!isCorrect && <p className="text-sm font-bold uppercase tracking-wider opacity-70">Answer: {currentItem.answer}</p>}
              </div>
            </div>
            <button
              onClick={handleNext}
              className={cn(
                "px-10 py-4 rounded-xl font-black uppercase tracking-widest transition-all",
                isCorrect ? "bg-green-500 text-white" : "bg-accent text-white"
              )}
            >
              Next <ArrowRight size={18} className="inline ml-2" />
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
