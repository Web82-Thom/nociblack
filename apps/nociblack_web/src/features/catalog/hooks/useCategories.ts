import { useEffect, useState } from "react";

import { supabase } from "../../../core/supabase/supabaseClient";

type Category = {
  id: string;
  name: string;
};

export function useCategories() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    async function loadCategories() {
      setIsLoading(true);
      setErrorMessage(null);

      const { data, error } = await supabase
        .from("categories")
        .select("id, name")
        .order("name", { ascending: true });

      if (error) {
        setErrorMessage("Impossible de charger les catégories.");
        setCategories([]);
        setIsLoading(false);
        return;
      }

      setCategories(data ?? []);
      setIsLoading(false);
    }

    loadCategories();
  }, []);

  return {
    categories,
    isLoading,
    errorMessage,
  };
}