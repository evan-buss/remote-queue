// Controls the main view (index.html)
import * as fs from "fs";
import * as os from "os";

import { Server } from "./server";
import * as robot from "robotjs";
import { GameState, GameProfile } from "./game";


let selectIndex: number = 0;
let server: Server;
let profiles: GameProfile[];

// SERVER CONFIGURATION
let startBtn = document.getElementById("startBtn");
let stopBtn = document.getElementById("stopBtn");
let portInput = <HTMLInputElement>document.getElementById("portInput");
let info = document.getElementById("info");

// PROFILES CONFIGURATION
let gameSelect = <HTMLSelectElement>document.getElementById("games");
let addBtn = document.getElementById("addBtn");
let saveBtn = document.getElementById("saveBtn");
let deleteBtn = document.getElementById("deleteBtn");

// INDIDUAL PROFILE DETAILS
let nameInput = <HTMLInputElement>document.getElementById("nameInput");
let queueBtn = document.getElementById("queueBtn");
let successBtn = document.getElementById("successBtn");
let queueDetails = document.getElementById("queueDetails");
let successDetails = document.getElementById("successDetails");

window.onload = loadProfiles;

// ================================
// Game Profiles Controls
// ================================
saveBtn.addEventListener("click", () => {
  fs.writeFile(os.homedir() + "/.rqProfiles", JSON.stringify(profiles), (err) => {
    if (err) {
      return console.log(err);
    }
  })
});

gameSelect.addEventListener("change", () => {
  selectIndex = gameSelect.selectedIndex;
  if (server !== undefined) {
    console.log("switching games");
    server.setGame(profiles[selectIndex]);
  }
  updateDisplays();
});

addBtn.addEventListener("click", () => {
  let opt = document.createElement('option');
  opt.value = (selectIndex + 1).toString();
  opt.innerHTML = "Unamed Profile";
  gameSelect.appendChild(opt);
  let newProfile = {} as GameProfile;
  newProfile.name = "New Profile " + selectIndex;
  profiles.push(newProfile);
});

deleteBtn.addEventListener("click", () => {
  // Remove the current index
  gameSelect.options[selectIndex].remove();
  // Remove the index from 
  profiles.splice(selectIndex, 1);
  selectIndex = 0;
  if (server !== undefined) {
    server.setGame(profiles[selectIndex]);
  }
  updateDisplays();
});

// ================================
// Game Profile Settings
// ================================

nameInput.addEventListener("input", () => {
  profiles[selectIndex].name = nameInput.value;
  gameSelect.options[selectIndex].text = nameInput.value;
});

queueBtn.addEventListener("click", () => {
  getScreenData(3).then((val: GameState) => {
    profiles[selectIndex].queueState = val;
    if (server !== undefined) {
      server.setGame(profiles[selectIndex]);
    }
    updateDisplays();
  });
});

successBtn.addEventListener("click", () => {
  getScreenData(3).then((val: GameState) => {
    profiles[selectIndex].successState = val;
    if (server !== undefined) {
      server.setGame(profiles[selectIndex]);
    }
    updateDisplays();
  });
});

// ==================================
// SERVER CONTROLS
// ==================================
startBtn.addEventListener("click", () => {
  server = new Server(portInput.value);
  server.setGame(profiles[selectIndex]);
  server.startServer();
  info.innerHTML = "Server Started";
});

stopBtn.addEventListener("click", () => {
  server.stopServer();
  info.innerHTML = "Server Stopped";
});


/** Attempt to load user's game profile from the config file */
function loadProfiles() {
  fs.readFile(os.homedir + "/.rqProfiles", 'utf8', (err, data) => {
    if (err) {
      console.log("File doesn't exist");
      profiles = [];
    } else {
      profiles = JSON.parse(data);
      console.log(profiles.length);
      for (var i = 0; i < profiles.length; i++) {
        let opt = document.createElement('option');
        opt.value = i.toString();
        opt.innerHTML = profiles[i].name !== undefined ? profiles[i].name : "UNKNOWN NAME";
        gameSelect.appendChild(opt);
      }

      updateDisplays();
    }
  });
}

/** 
 * Get color under mouse after [sec] seconds 
 */
function getScreenData(sec: number): Promise<GameState> {
  var audio = new Audio('./assets/camera_sound.wav');

  return new Promise((resolve, reject) => {
    setTimeout(() => {
      audio.play();
      var { x, y } = robot.getMousePos();
      var color = robot.getPixelColor(x, y);
      resolve(new GameState(x, y, color));
    }, sec * 1000);
  });
}

function updateDisplays() {

  nameInput.value = profiles[selectIndex].name;

  successDetails.innerText = `X: ${profiles[selectIndex].successState.x}`
    + ` Y: ${profiles[selectIndex].successState.y}`
    + ` Color: # ${profiles[selectIndex].successState.color}`;

  queueDetails.innerText = `X: ${profiles[selectIndex].queueState.x}`
    + ` Y: ${profiles[selectIndex].queueState.y}`
    + ` Color: # ${profiles[selectIndex].queueState.color}`;
}