var SteamUser = require('steam-user');
var fs = require('fs');
var client = new SteamUser();

function writeCredentials(accountName, loginKey) {
    var obj = {
        "accountName": accountName,
        "loginKey": loginKey,
        "rememberPassword": true
    };

    var json = JSON.stringify(obj);
    fs.writeFile('credentials.json', json, (err) => {
        if (err) throw err;
    });
}

function readCredentials() {
    fs.readFile('credentials.json', (err, data) => {
        if (err) throw err;

        var credentials = JSON.parse(data);
        client.logOn(credentials);
    });
}

readCredentials();

client.on('loggedOn', function(details) {
	console.log("Logged into Steam as " + client.steamID.getSteam3RenderedID());
	client.setPersona(SteamUser.EPersonaState.Online, 'El Mariachi');
});


client.on('error', function(e) {
	// Some error occurred during logon
	console.log(e);
});

client.on('loginKey', function(key) {
    console.log('Got login key: ' + key);
    writeCredentials('rockyandirou', key);
});