// Controls the main view (index.html)
import * as fs from "fs";
import * as os from "os";

import { Server } from "./server";
import * as robot from "robotjs";
import { GameState, GameProfile } from "./game";
import { create } from "domain";


let selectIndex: number = 0;
let server: Server;
let profiles: GameProfile[];
let delay: number = 3;

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
let delayInput = <HTMLInputElement>document.getElementById("delayInput");
let queueDurationInput = <HTMLInputElement>document.getElementById("queueDurationInput");
let queueBtn = document.getElementById("queueBtn");
let successBtn = document.getElementById("successBtn");

let queueX = document.getElementById("queueX");
let queueY = document.getElementById("queueY");
let queueColor = document.getElementById("queueColor");

let successX = document.getElementById("successX");
let successY = document.getElementById("successY");
let successColor = document.getElementById("successColor");


window.onload = loadProfiles;

// Try to load the ~/.rqProfiles file, otherwise intialized the app without it
function loadProfiles() {
  fs.readFile(os.homedir + "/.rqProfiles", 'utf8', (err, data) => {
    if (err) {
      console.log("File doesn't exist");
      profiles = [];
      initDummyProfile();
      updateDisplays();
      // Create a new entry in the select dropdown
      let opt = document.createElement('option');
      opt.value = (selectIndex + 1).toString();
      opt.innerHTML = "Unamed Profile";
      gameSelect.appendChild(opt);
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


// ================================
// Game Profiles Controls
// ================================
saveBtn.onclick = saveProfiles;
gameSelect.onchange = switchActiveGame;
addBtn.click = createProfile;
deleteBtn.click = deleteProfile;

// Save all changes to file located at ~/.rqProfiles
function saveProfiles() {
  fs.writeFile(os.homedir() + "/.rqProfiles", JSON.stringify(profiles), (err) => {
    if (err) {
      return console.log("Error Saving Profile: " + err);
    }
  });
}


// Change the active game 
function switchActiveGame() {
  // Get the newly selected game index
  selectIndex = gameSelect.selectedIndex;
  // Tell the server which game we are now using
  if (server !== undefined) {
    console.log("switching games");
    server.setGame(profiles[selectIndex]);
  }
  // Show the user the new profile's settings
  updateDisplays();
}

function createProfile() {
  // Create a new entry in the select dropdown
  let opt = document.createElement('option');
  opt.value = (selectIndex + 1).toString();
  opt.innerHTML = "Unamed Profile";
  gameSelect.appendChild(opt);

  initDummyProfile();

  // Switch the current view to the new profile
  selectIndex = profiles.length - 1;
  gameSelect.selectedIndex = selectIndex;
  updateDisplays();
}

// Create a new GameProfile object with default values + add it to profiles list
function initDummyProfile() {
  // Create a new profile and add it to list
  let newProfile = {} as GameProfile;
  newProfile.name = "Unnamed Profile";
  newProfile.queueDuration = 10;
  newProfile.queueState = new GameState(0, 0, "ffffff");
  newProfile.successState = new GameState(0, 0, "ffffff");
  profiles.push(newProfile);
}

function deleteProfile() {
  // Remove the current index
  gameSelect.options[selectIndex].remove();
  // Remove the index from 
  profiles.splice(selectIndex, 1);
  selectIndex = 0;
  if (server !== undefined) {
    server.setGame(profiles[selectIndex]);
  }
  updateDisplays();
}

// ================================
// Game Profile Settings
// ================================

// Update the profile list and the select dropdown name 
nameInput.oninput = () => {
  profiles[selectIndex].name = nameInput.value;
  gameSelect.options[selectIndex].text = nameInput.value;
};

// Update the delay settings on input
delayInput.oninput = () => delay = parseInt(delayInput.value);

// Update the queue duration on change
queueDurationInput.onchange = () => {
  profiles[selectIndex].queueDuration = parseInt(queueDurationInput.value);
  if (server !== undefined) {
    server.game.queueDuration = parseInt(queueDurationInput.value);
  }
};

// Update the queue state settings on click
queueBtn.onclick = () => {
  getScreenData(delay).then((val: GameState) => {
    profiles[selectIndex].queueState = val;
    if (server !== undefined) {
      server.setGame(profiles[selectIndex]);
    }
    updateDisplays();
  });
};

// Update the success state on click
successBtn.onclick = () => {
  getScreenData(delay).then((val: GameState) => {
    profiles[selectIndex].successState = val;
    if (server !== undefined) {
      server.setGame(profiles[selectIndex]);
    }
    updateDisplays();
  });
};

// ==================================
// SERVER CONTROLS
// ==================================
startBtn.onclick = startServer;

// Start the server and update the display when a client connects
function startServer() {
  server = new Server(portInput.value, (ip: string) => {
    info.innerText = info.innerText + "\n Device Connected: " + ip.substring(ip.indexOf("1"));
  }, (ip: string) => {
    info.innerText = info.innerText + "\n Device Disconnected: " + ip.substring(ip.indexOf("1"));
  });
  server.setGame(profiles[selectIndex]);
  server.startServer();
  info.innerText = "Server Started";
  info.classList.add("is-success")
  info.classList.remove("is-danger")
}

stopBtn.onclick = stopServer;

// Stop the server and updat the display
function stopServer() {
  server.stopServer();
  info.innerText = "Server Stopped";
  info.classList.add("is-danger")
  info.classList.remove("is-success")
}

/** 
 * Get color under mouse after [sec] seconds 
 * 
 * Parameters: sec - the number of seconds to wait before capturing
 */
function getScreenData(sec: number): Promise<GameState> {
  var audio = new Audio('./assets/camera_sound.wav');
  audio.currentTime = .5;

  return new Promise((resolve, reject) => {
    setTimeout(() => {
      audio.play();
      var { x, y } = robot.getMousePos();
      var color = robot.getPixelColor(x, y);
      resolve(new GameState(x, y, color));
    }, sec * 1000);
  });
}

/**
 * Update the screen info with the new data values
 * 
 * NOTE: If I used a reactive framework like React or Vue, this would be 
 *       unecessary. Because it is vanilla JS I have to manually update each 
 *       DOM element.
 */
function updateDisplays() {

  nameInput.value = profiles[selectIndex].name;
  queueDurationInput.value = profiles[selectIndex].queueDuration.toString();

  queueX.innerText = profiles[selectIndex].queueState.x.toString();
  queueY.innerText = profiles[selectIndex].queueState.y.toString();
  queueColor.style.backgroundColor = `#${profiles[selectIndex].queueState.color}`
  queueColor.innerText = `#${profiles[selectIndex].queueState.color}`

  successX.innerText = profiles[selectIndex].successState.x.toString();
  successY.innerText = profiles[selectIndex].successState.y.toString();
  successColor.style.backgroundColor = `#${profiles[selectIndex].successState.color}`
  successColor.innerText = `#${profiles[selectIndex].successState.color}`
}