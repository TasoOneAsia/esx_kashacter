import React, { useState } from "react";
import { useNuiEvent } from "../nui-events/useNuiEvent";

export const useMenuVisibility = (): boolean => {
  const [visible, setVisible] = useState<boolean>(false);

  useNuiEvent("CHAR_MENU", "setVisible", setVisible);

  return visible;
};
