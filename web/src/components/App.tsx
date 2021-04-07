import React from "react";
import { useMenuVisibility } from "../hooks/useMenuVisibility";
import { Box, MuiThemeProvider } from "@material-ui/core";
import { MainTheme } from "../styles/theme";
import { AppWrapper } from "./layout/AppWrapper";
import InjectDebugData from "../debug/InjectDebugData";

function App() {
  const visible = useMenuVisibility();

  return (
    <MuiThemeProvider theme={MainTheme}>
      <AppWrapper visible={visible}>
        <Box></Box>
      </AppWrapper>
    </MuiThemeProvider>
  );
}

InjectDebugData(
  [
    {
      app: "CHAR_MENU",
      method: "setVisible",
      data: true,
    },
  ],
  1000
);

export default App;
