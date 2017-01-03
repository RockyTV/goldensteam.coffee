do ->
  SteamUser = require 'steam-user'
  fs = require 'fs'
  readline = require 'readline'
  client = new SteamUser()
  
  username = ""

  # Override the setPersona function to include our flags
  SteamUser.prototype.setPersona = (state, name) ->
    this._send SteamUser.EMsg.ClientChangeStatus, {
      'persona_state': state,
      'persona_state_flags': 4095,
      'player_name': name
    }

  rl = readline.createInterface {
    input: process.stdin,
    output: process.stdout
  }

  # Function to write options to file
  writeOptions = (accountName, loginKey) ->
    login_options = JSON.stringify {
      "accountName": accountName,
      "loginKey": loginKey,
      "rememberPassword": true
    }

    fs.writeFile 'options.json', login_options, (err) ->
      if err then throw err

  # Function to read options from file
  readOptions = () ->
    fs.readFile 'options.json', (err, data) ->
      if err
        if err.code is 'ENOENT'
          console.log 'Options file not found, prompting for account details...'

          # Get Steam username and password to login
          rl.question 'Steam Username: ', (answer) ->
            username = answer
            rl.question 'Steam Password: ', (answer) ->
              password = answer

              # Clear out the typed password
              readline.moveCursor(process.stdout, 16, -1)
              readline.clearLine(process.stdout, 1)
              rl.write "\n"

              # Login to Steam
              client.logOn {
                'accountName': username,
                'password': password,
                'rememberPassword': true
              }

              rl.close()
          
        else throw err
      else
        client.logOn JSON.parse(data)

  client.on 'loggedOn', (details) ->
    console.log "Logged into Steam as #{client.steamID.getSteam3RenderedID()},
                    press Ctrl+C to exit."
    client.setPersona SteamUser.EPersonaState.Online

  client.on 'error', (err) ->
    console.error err

  # A login key can be used to deprecate password/steam auth login.
  client.on 'loginKey', (key) ->
    console.debug "Got login key: #{key}"
    writeOptions username, key
    return

  readOptions()