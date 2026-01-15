import {Routes, Route} from 'react-router-dom'

import './css/App.css'
import Home from './pages/Home'
import Favorites from './pages/Favorites'
import NavBar from './components/NavBar'
import { LikedContextProvider } from './contexts/likedContent'

function App() {

  return (
    <>
    <LikedContextProvider>
      
    {/* navbar */}
    <NavBar />
    {/* Main Content Area */}
    <main className="main-container">
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/favorites" element={<Favorites />} />
      </Routes>
    </main>

    </LikedContextProvider>
    </>
  )
}


function Text({display}) {
  return(
    <div>
      <p>{display}</p>
    </div>
  )
}


export default App
