import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { EventListPage } from './pages/EventListPage'
import { EventCreatePage } from './pages/EventCreatePage'
import { EventDetailPage } from './pages/EventDetailPage'
import { EventEditPage } from './pages/EventEditPage'
import './App.css'

function App() {
  return (
    <BrowserRouter>
      <main className="container">
        <h1>bplus 管理画面</h1>
        <Routes>
          <Route path="/" element={<EventListPage />} />
          <Route path="/events/new" element={<EventCreatePage />} />
          <Route path="/events/:eventId" element={<EventDetailPage />} />
          <Route path="/events/:eventId/edit" element={<EventEditPage />} />
        </Routes>
      </main>
    </BrowserRouter>
  )
}

export default App
