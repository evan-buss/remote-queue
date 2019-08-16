# Remote Queue

Allows you to confirm a game from your mobile device when you are away from your
PC.

## How it Works
1. Run the server on your PC with the game open and waiting in queue
2. Open the mobile app while connected to the same local network as the PC
3. Choose your PC from the list of available devices.
4. Wait for the notification that you must accept the game
5. Click the accept button and it will be accepted on your PC


## Game Support
I currently only plan on supporting Counter Strike: Global Offensive. I hope to 
develop the application in such a way that adding support for new games is trivial.

## Tech
### Mobile App
- The mobile app is written in Flutter which allows it to work on both iOS and Android
- It makes use of websockets to send and recieve data from the server.

### Server
- The server is written in JavaScript using Node.js
- It makes use of Robots.js to manipulate the mouse and keyboard, as well as see what is on the screen.