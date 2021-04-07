interface DebugEvent<P = any> {
  app: string;
  method: string;
  data: P;
}

/**
 * Will mock data as if it were coming from an NUI message event
 * @param events {DebugEvent[]} An array of debug events
 * @param ms {number?} Optional amount of ms between dispatch events
 * @example
 * InjectDebugData([
 *  {
 *   app: 'CAMERA',
 *   method: 'setPhotos',
 *   data: [
 *    {
 *      id: 1,
 *      image: 'https://beta.iodine.gg/noDcb.jpeg',
 *    },
 *    {
 *      id: 2,
 *      image: 'https://beta.iodine.gg/noDcb.jpeg',
 *    }
 *   ]
 *  }
 * ])
 **/
const InjectDebugData = <P>(events: DebugEvent<P>[], ms = 1000) => {
  if (process.env.NODE_ENV === "development") {
    for (const event of events) {
      setTimeout(() => {
        window.dispatchEvent(
          new MessageEvent("message", {
            data: {
              app: event.app,
              method: event.method,
              data: event.data,
            },
          })
        );
      }, ms);
    }
  }
};

export default InjectDebugData;
