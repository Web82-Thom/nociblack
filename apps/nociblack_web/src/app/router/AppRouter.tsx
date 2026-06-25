import { BrowserRouter, Route, Routes } from "react-router";
import { HomePage } from "../../features/home/presentation/pages/HomePage/HomePage";

import { NotFoundPage } from "./pages/NotFoundPage/NotFoundPage";
import { ProductDetailPage } from "../../features/catalog/presentation/pages/ProductDetailPage/ProductDetailPage";

export function AppRouter() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/articles/:slug" element={<ProductDetailPage />} />
        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </BrowserRouter>
  );
}
