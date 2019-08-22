// Controls the main view (index.html)
import { Server } from "./server";
import * as robot from "robotjs";
import { GameState, Game } from "./game";
import * as fs from "fs";
import * as os from "os";


interface GameProfile {
  name: string;
  queueState: GameState;
  successState: GameState;
}

let selectIndex: number = 0;
let server: Server;
let profiles: GameProfile[];


let startBtn = document.getElementById("startBtn");
let stopBtn = document.getElementById("stopBtn");

let gameSelect = <HTMLSelectElement>document.getElementById("games");
let addBtn = document.getElementById("addBtn");
let saveBtn = document.getElementById("saveBtn");
let queueBtn = document.getElementById("queueBtn");
let successBtn = document.getElementById("successBtn");

let info = document.getElementById("info");
let queueDetails = document.getElementById("queueDetails");
let successDetails = document.getElementById("successDetails");

gameSelect.addEventListener("change", () => {
  console.log(gameSelect.options[gameSelect.selectedIndex].value);
  selectIndex = gameSelect.selectedIndex;
  updateDisplays();
});

function updateDisplays() {
  successDetails.innerText = `X: ${profiles[selectIndex].successState.x}`
    + ` Y: ${profiles[selectIndex].successState.y}`
    + ` Color: # ${profiles[selectIndex].successState.color}`;

  queueDetails.innerText = `X: ${profiles[selectIndex].queueState.x}`
    + ` Y: ${profiles[selectIndex].queueState.y}`
    + ` Color: # ${profiles[selectIndex].queueState.color}`;
}

window.onload = loadProfiles;

function loadProfiles() {
  fs.readFile(os.homedir + "/.rqProfiles", 'utf8', (err, data) => {
    if (err) {
      console.log("File doesn't exist");
      profiles = [];
    } else {
      profiles = JSON.parse(data);
      console.log(profiles.length);
      if (profiles.length > 0) {
        for (var i = 0; i <= profiles.length; i++) {
          let opt = document.createElement('option');
          opt.value = i.toString();
          opt.innerHTML = profiles[i].name !== undefined ? profiles[i].name : "UNKNOWN NAME";
          gameSelect.appendChild(opt);
        }
      }
    }
  });
}

addBtn.addEventListener("click", () => {
  let opt = document.createElement('option');
  opt.value = (selectIndex + 1).toString();
  opt.innerHTML = "New Profile " + (selectIndex + 1);
  gameSelect.appendChild(opt);
  let newProfile = {} as GameProfile;
  newProfile.name = "New Profile " + selectIndex;
  profiles.push(newProfile);
});

// Control the Current State
queueBtn.addEventListener("click", () => {
  getScreenData(3).then((val: GameState) => {
    profiles[selectIndex].queueState = val;
    updateDisplays();
  });
});

successBtn.addEventListener("click", () => {
  getScreenData(3).then((val: GameState) => {
    profiles[selectIndex].successState = val;
    updateDisplays();
  });
});

// Start and Stop the Server
startBtn.addEventListener("click", () => {
  server = new Server("1337");
  server.startServer();
  info.innerHTML = "Server Started";
});

stopBtn.addEventListener("click", () => {
  server.stopServer();
  info.innerHTML = "Server Stopped";
});

saveBtn.addEventListener("click", () => {
  fs.writeFile(os.homedir() + "/.rqProfiles", JSON.stringify(profiles), (err) => {
    if (err) {
      return console.log(err);
    }
  })
});

/** 
 * Get color under mouse after [sec] seconds 
 */
function getScreenData(sec: number): Promise<GameState> {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      var { x, y } = robot.getMousePos();
      console.log("\nMOUSE X: " + x + " Y: " + y);
      console.log(robot.getPixelColor(x, y));
      var color = robot.getPixelColor(x, y);

      resolve(new GameState(x, y, color));
    }, sec * 1000);
  });
}