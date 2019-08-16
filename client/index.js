var evilscan = require('evilscan');

var options = {
    target: '192.168.1.1-254',
    port: '5001',
    status: 'O',
};

var scanner = new evilscan(options);

scanner.on('result', function (data) {
    console.log(data);
});

scanner.on('error', function (err) {
    throw new Error(data.toString());
});

scanner.on('done', function () {
    // finished !
    console.log("finished");
});

scanner.run();
