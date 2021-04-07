import { Box, Fade } from "@material-ui/core";
import React, { ReactNode } from "react";

interface AppWrapperProps {
  children: ReactNode;
  visible?: boolean;
}

export const AppWrapper = ({ children, visible }: AppWrapperProps) => (
  <Fade in={visible}>
    <Box width="100%" height="100%" display="flex" flexDirection="column">
      {children}
    </Box>
  </Fade>
);
