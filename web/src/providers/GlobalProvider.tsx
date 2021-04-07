import React, { createContext, useCallback, useState } from "react";

interface CharInfo {
  money?: number;
  bank?: number;
  name?: string;
  dateofbirth: string;
  job: string;
  job_grade: string;
  identifier: string;
  charId: string;
}

interface MenuProviderProps {
  charInfo: CharInfo[];
  removeCharInfo: (charId: string) => void;
  addCharInfo: (char: CharInfo) => void;
  menuVisible: boolean;
  setMenuVisible: (val: boolean) => void;
}

const CharContext = createContext<MenuProviderProps | null>(null);

export const CharProvider: React.FC = ({ children }) => {
  const [charState, setCharState] = useState<CharInfo[]>([]);
  const [menuVisible, setMenuVisible] = useState<boolean>(false);

  const removeCharInfo = useCallback(
    (charId: string) => {
      const itemsFilter = charState.filter((char) => char.charId !== charId);
      setCharState(itemsFilter);
    },
    [charState]
  );

  return (
    <CharContext.Provider
      value={{
        charInfo: charState,
        addCharInfo: (newChar: CharInfo) => charState.push(newChar),
        removeCharInfo,
        menuVisible,
        setMenuVisible,
      }}
    >
      {children}
    </CharContext.Provider>
  );
};
