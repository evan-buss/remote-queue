# Remote Queue

Allows you to confirm any game from your mobile device when you are away from your
PC.

## How it Works
1. Adjust the settings for your specific game using the desktop client.
2. Start the server using the desktop client.
3. Open the mobile app while connected to the same local network as the PC
4. Choose your PC from the list of available devices.
5. Open your game and join the game queue.
6. Keep the app open on your phone anywhere in your house.
7. When you get the notification on your phone, accept or decline. The game will
   be accepted on your PC.


## Game Support
Remote Queue should support any game. Each game will require you to set the 
settings in the desktop client. Settings can be saved and loaded so you only 
need to set them up once. Settings are stored in JSON format to `~/.rqProfiles`

## Mobile App
- The mobile app is written in Flutter which allows it to work on both iOS and Android
- Using Dart's multithreading paradigm "Isolates", your local network is traversed and seached for the specified open port that you set. Once the port is found, the app attempts to send a GET request to `/poll`. The request returns the computer's hostname if it is running the server.
- It then establishes a websocket connection which allows realtime data to be passed between the app and the server.

## Desktop Client / Server
- The server is written in JavaScript using Node.js
- It makes use of Robots.js to manipulate the mouse and keyboard, as well as see what is on the screen.
- The desktop client uses Electron. The client allows you to adjusts the server's settings as well as save and load specific game profiles.