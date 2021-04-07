import { MutableRefObject, useEffect, useRef } from "react";
import { eventNameFactory } from "../utils/eventNameFactory";
import DebugLog from "../debug/LogDebugEvents";

interface IOptions {
  capture?: boolean;
  passive?: boolean;
  once?: boolean;
}

interface EventPacket {
  app: string;
  method: string;
  data: unknown;
}

/**
 * A hook that manage events listeners for receiving data from the NUI
 * @param app The app name in which this hoook is used
 * @param method The specific `method` field that should be listened for.
 * @param handler The callback function that will handle data relayed by this hook
 * @param options Any options to pass to the addEventListener
 **/

const defaultOptions = {};

export const useNuiEvent = <T = unknown>(
  app: string,
  method: string,
  handler: (r: T) => void,
  options: IOptions = defaultOptions
) => {
  const savedHandler: MutableRefObject<any> = useRef();

  // When handler value changes set mutable ref to handler val
  useEffect(() => {
    savedHandler.current = handler;
  }, [handler]);

  // Will run every rerender
  useEffect(() => {
    const eventName = eventNameFactory(app, method);

    const eventListener = (event: any) => {
      if (savedHandler.current && savedHandler.current.call) {
        const { data } = event;
        DebugLog({
          action: `NUI Data Received (${eventName})`,
          data: event.data,
          level: 1,
        });
        // const newData = currentState ? { ...currentState, ...data } : data;
        savedHandler.current(data as T);
      }
    };

    window.addEventListener(eventName, eventListener, options);
    // Remove Event Listener on component cleanup
    return () => window.removeEventListener(eventName, eventListener, options);
  }, [app, method, options]);
};
