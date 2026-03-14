/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const isDev = import.meta.env.MODE !== "production";
const DEV_SERVER_IP = import.meta.env.DEV_SERVER_IP || "127.0.0.1";

let socket = null;
const queue = [];
const subscribers = [];

const ensureConnection = () => {
  if (isDev) {
    if (!window.WebSocket) {
      return;
    }
    if (!socket || socket.readyState === WebSocket.CLOSED) {
      socket = new WebSocket(`ws://${DEV_SERVER_IP}:3000`);
      socket.onopen = () => {
        // Empty the message queue
        while (queue.length !== 0) {
          const msg = queue.shift();
          if (msg) socket.send(msg);
        }
      };
      socket.onmessage = (event) => {
        const msg = JSON.parse(event.data);
        for (const subscriber of subscribers) {
          subscriber(msg);
        }
      };
    }
  }
};

if (isDev) {
  window.onunload = () => socket && socket.close();
}

export const subscribe = (fn) => subscribers.push(fn);

/**
 * A json serializer which handles circular references and other junk.
 */
const serializeObject = (obj) => {
  let refs = [];

  const primitiveReviver = (value) => {
    if (typeof value === "number" && !Number.isFinite(value)) {
      return {
        __number__: String(value),
      };
    }
    if (typeof value === "undefined") {
      return {
        __undefined__: true,
      };
    }
    return value;
  };

  const objectReviver = (_key, value) => {
    if (typeof value === "object") {
      if (value === null) {
        return value;
      }
      // Circular reference
      if (refs.includes(value)) {
        return "[circular ref]";
      }
      refs.push(value);
      // Error object
      const isError =
        value instanceof Error ||
        (value.code && value.message && value.message.includes("Error"));
      if (isError) {
        return {
          __error__: true,
          string: String(value),
          stack: value.stack,
        };
      }
      // Array
      if (Array.isArray(value)) {
        return value.map(primitiveReviver);
      }
      return value;
    }
    return primitiveReviver(value);
  };

  const json = JSON.stringify(obj, objectReviver);
  refs = null;
  return json;
};

export const sendMessage = (msg) => {
  if (isDev) {
    const json = serializeObject(msg);
    // Send message using WebSocket
    if (window.WebSocket) {
      ensureConnection();
      if (socket && socket.readyState === WebSocket.OPEN) {
        socket.send(json);
      } else {
        // Keep only 100 latest messages in the queue
        if (queue.length > 100) {
          queue.shift();
        }
        queue.push(json);
      }
    } else {
      // Send message using plain HTTP request.
      const req = new XMLHttpRequest();
      req.open("POST", `http://${DEV_SERVER_IP}:3001`, true);
      req.timeout = 250;
      req.send(json);
    }
  }
};

export const sendLogEntry = (level, ns, ...args) => {
  if (isDev) {
    try {
      sendMessage({
        type: "log",
        payload: {
          level,
          ns: ns || "client",
          args,
        },
      });
    } catch (err) {
      // Ignore errors
    }
  }
};

export const setupHotReloading = () => {
  if (isDev && import.meta.hot && window.WebSocket) {
    ensureConnection();
    sendLogEntry(0, null, "setting up hot reloading");

    subscribe((msg) => {
      const { type } = msg;
      sendLogEntry(0, null, "received", type);

      if (type === "hotUpdate") {
        sendLogEntry(0, null, "hot update received, Vite will handle it");
      }
    });

    import.meta.hot.on("vite:beforeUpdate", (payload) => {
      sendLogEntry(0, null, "vite:beforeUpdate", payload);
    });

    import.meta.hot.on("vite:afterUpdate", (payload) => {
      sendLogEntry(0, null, "vite:afterUpdate", payload);
    });

    import.meta.hot.on("vite:error", (payload) => {
      sendLogEntry(0, null, "vite:error", payload);
    });
  }
};
