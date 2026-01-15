import { useContext, createContext, useState, useEffect } from "react";

const LikedContentContext = createContext();
export const useLikedContext = () => useContext(LikedContentContext);

export const LikedContextProvider = ({ children }) => {
  const [likedContent, setLikedContent] = useState(() => {
    try {
      const stored = localStorage.getItem("likedContent");
      return stored ? JSON.parse(stored) : [];
    } catch {
      return [];
    }
  });

  useEffect(() => {
    localStorage.setItem("likedContent", JSON.stringify(likedContent));
  }, [likedContent]);

  const addToLiked = (content) => {
    setLikedContent((prev) => [...prev, content]);
  };

  const removeFromLiked = (contentId) => {
    setLikedContent((prev) => prev.filter((item) => item.id !== contentId));
  };

  const isLiked = (contentId) => likedContent.some((item) => item.id === contentId);

  const value = {
    likedContent,
    addToLiked,
    removeFromLiked,
    isLiked,
  };

  return <LikedContentContext.Provider value={value}>{children}</LikedContentContext.Provider>;
};