const WebSocket = require("ws");

const wss = new WebSocket.Server({ port: 8080 });

let users = {}; // { userId: socket }

wss.on("connection", (ws) => {
  console.log("Client connected");

  ws.on("message", (data) => {
    const msg = JSON.parse(data);

    // Register user
    if (msg.type === "register") {
      users[msg.userId] = ws;
      console.log(`User registered: ${msg.userId}`);
      return;
    }

    // Send message to receiver
    if (msg.type === "message") {
      const receiverSocket = users[msg.to];

      if (receiverSocket) {
        receiverSocket.send(
          JSON.stringify({
            type: "message",
            from: msg.from,
            text: msg.text,
            time: new Date().toISOString(),
          })
        );
      }
    }
  });

  ws.on("close", () => {
    console.log("Client disconnected");

    // Remove disconnected user
    for (let userId in users) {
      if (users[userId] === ws) {
        delete users[userId];
        console.log("User removed:", userId);
      }
    }
  });
});

console.log("WebSocket Server running on ws://localhost:8080");