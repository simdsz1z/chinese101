import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Auth } from './components/Auth';
import { Layout } from './components/Layout';
import { Dashboard } from './components/Dashboard';
import { LearningPath } from './components/LearningPath';
import { Leaderboard } from './components/Leaderboard';
import { Profile } from './components/Profile';
import { Practice } from './components/Practice';

export default function App() {
  return (
    <Router>
      <Auth>
        <Routes>
          <Route path="/" element={<Layout><Dashboard /></Layout>} />
          <Route path="/quest" element={<Layout><LearningPath /></Layout>} />
          <Route path="/leaderboard" element={<Layout><Leaderboard /></Layout>} />
          <Route path="/profile" element={<Layout><Profile /></Layout>} />
          <Route path="/practice/:id" element={<Practice />} />
        </Routes>
      </Auth>
    </Router>
  );
}
