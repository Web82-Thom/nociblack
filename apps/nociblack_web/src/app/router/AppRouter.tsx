import { BrowserRouter, Route, Routes } from 'react-router'
import { HomePage } from '../../features/home/presentation/pages/HomePage/HomePage'
import { NotFoundPage } from './pages/NotFoundPage/NotFoundPage'

export function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </BrowserRouter>
  )
}