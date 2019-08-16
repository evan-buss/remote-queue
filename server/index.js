// Type "Hello World" then press enter.
var robot = require("robotjs");

setTimeout(() => {
    // Type "Hello World".
    // robot.typeString("Hello World");

    // // Press enter.
    // robot.keyTap("enter");

    robot.moveMouse(150, 100);
    robot.mouseToggle("down");
    // robot.dragMouse(1000, 1000);
    robot.moveMouseSmooth(1000, 1000);
    robot.mouseToggle("up");
}, 3000);

