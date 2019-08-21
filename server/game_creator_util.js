const robot = require('robotjs');

// Get color under mouse after 3 seconds
setTimeout(() => {
    var { x, y } = robot.getMousePos();
    console.log("\nMOUSE X: " + x + " Y: " + y);
    console.log(robot.getPixelColor(x, y));
}, 3000);