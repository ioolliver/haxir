/* Typescript support */
export interface HBWindow extends Window {
  onHBLoaded: Function;
  HBInit: (properties?: any) => any;
  room: any;
  socket: WebSocket;
}
declare let window: HBWindow;



/* UTILS */

var linkSent = false

function convertName(name : string) {

  name = name.substring(1)

  name = name.replace(/_/g, " ")
  
  return name
}

function getPlayersMentioned(message : string) {

  let mentioned = []
  let players = window.room.getPlayerList()
  
  for(let word of message.split(" ")) {

      if(!word.startsWith("@")) continue

      let name = convertName(word)

      let mentionedPlayers = players.filter((p : any) => p.name.replace(/_/g, " ") == name)

      for(let pl of mentionedPlayers) mentioned.push(pl.id)
      
  }

  return mentioned
  
}

function send(message : string, args? : {}) {

  window.socket.send(JSON.stringify({
    message,
    args: args || {}
  }))

}

function invalidTokenChecker() {
  setTimeout(() => {

    let is_room_linked = document.querySelector("iframe")?.contentWindow?.document.querySelector("#roomlink p")

    if(!is_room_linked) send("invalid_token")

  }, 5000)
}

function messageListener() {


  window.socket.onmessage = (message) => {

    const data = JSON.parse(message.data)

    const msg = data.message
    const args = data.args

    handleMessage(msg, args || {})

  }


}



/* EVENTS */
function setEvents() {

  /* EVENTS NAME PATTERN: Same as described in documentation (https://github.com/haxball/haxball-issues/wiki/Headless-Host) */

  window.room.onRoomLink = (link : any) => {
    // Sometimes onRoomLink event is called more than once (Haxball's bug?)
    if(linkSent) return
    linkSent = true
    send("event", { event: "onRoomLink", args: { link } })
  }

  window.room.onPlayerJoin = (player : any) => {
    send("event", { event: "onPlayerJoin", args: { player } })
  }

  window.room.onPlayerLeave = (player : any) => {
    // A fast way of preventing onPlayerLeave event being called before onPlayerKicked
    setTimeout(() => {
      send("event", { event: "onPlayerLeave", args: { player } })
    }, 30)
  }

  window.room.onPlayerChat = (player : any, message : any) => {
    send("event", { event: "onPlayerChat", args: { player, message } })
    return false
  }

  window.room.onGameTick = () => {

    // A way of updating scores and discs on Elixir"s side

    let scores = window.room.getScores()
    let discs = []
    for (let i = 0; i < window.room.getDiscCount(); i++) {
        discs.push(window.room.getDiscProperties(i))
    }
    let playersDiscs = []
    for (let player of window.room.getPlayerList().filter((p : any) => p.team != 0)) {
        let props = window.room.getPlayerDiscProperties(player.id)
        props.id = player.id
        playersDiscs.push(props)
    }
    let state = {
        scores,
        discs,
        playersDiscs
    };

    send("event", { event: "onGameTick", args: state })

  }

  window.room.onTeamVictory = () => {
    send("event", { event: "onTeamVictory", args: null})
  }

  window.room.onPlayerBallKick = (player : any) => {
    send("event", { event: "onPlayerBallKick", args: { player }})
  }

  window.room.onTeamGoal = (team : any) => {
    send("event", { event: "onTeamGoal", args: { team }})
  }

  window.room.onGameStart = (byPlayer : any) => {
    send("event", { event: "onGameStart", args: { byPlayer }})
  }
  
  window.room.onGameStop = (byPlayer : any) => {
    send("event", { event: "onGameStop", args: { byPlayer }})
  }

  window.room.onPlayerAdminChange = (changedPlayer : any, byPlayer : any) => {
    send("event", { event: "onPlayerAdminChange", args: { changedPlayer, byPlayer }})
  }

  window.room.onPlayerTeamChange = (changedPlayer : any, byPlayer : any) => {
    send("event", { event: "onPlayerTeamChange", args: { changedPlayer, byPlayer }})
  }

  window.room.onPlayerKicked = (kickedPlayer : any, reason : any, ban : any, byPlayer : any) => {
    send("event", { event: "onPlayerKicked", args: { kickedPlayer, reason, ban, byPlayer }})
  }

  window.room.onGamePause = (byPlayer : any) => {
    send("event", { event: "onGamePause", args: { byPlayer }})
  }

  window.room.onGameUnpause = (byPlayer : any) => {
    send("event", { event: "onGameUnpause", args: { byPlayer }})
  }

  window.room.onPositionsReset = () => {
    send("event", { event: "onPositionsReset", args: null})
  }

  window.room.onPlayerActivity = (player : any) => {
    send("event", { event: "onPlayerActivity", args: { player }})
  }

  window.room.onStadiumChange = (newStadiumName : any, byPlayer : any) => {
    send("event", { event: "onStadiumChange", args: { newStadiumName, byPlayer }})
  }

  window.room.onKickRateLimitSet = (min : any, rate : any, burst : any) => {
    send("event", { event: "onKickRateLimitSet", args: { min, rate, burst }})
  }

}


/* API */
function handleMessage(message : string, args : any) {

  /* MESSAGES & ARGS NAME PATTERN: Same as described in documentation but with snake case */

  switch(message) {
    case "open_room":
      if (args["room_name"]) args["roomName"] = args["room_name"]
      if (args["max_players"]) args["maxPlayers"] = args["max_players"]
      args["noPlayer"] = true

      window.room = window.HBInit(args)

      setEvents()
      invalidTokenChecker()
    break;
    case "send_announcement":

      let targets : number[] = []
      if(args.targets) {
          args.targets = Object.values(args.targets)

          for(let target of args.targets) {
            if(target.id) {
              targets.push(target.id)
            }else if(Number(target)) {
              targets.push(Number(target))
            }
          }
      }
      let players = window.room.getPlayerList().filter((p : any) => !targets.length || targets.includes(p.id))
      if(args.allow_mentions === false) {

        if(targets.length > 0) {

            for(let player of players) {
                window.room.sendAnnouncement(args.content,
                player.id, 
                args.color,
                args.style,
                args.sound)
            }

        }else{
            window.room.sendAnnouncement(args.content, args.target, args.color, args.style, args.sound)
        }

      }else{

          let mentionedPlayers = getPlayersMentioned(args.content)

          for(let player of players) {
              window.room.sendAnnouncement(args.content,
              player.id, 
              args.color,
              (mentionedPlayers.includes(player.id) ? (args.style == "small" ? "small-bold" : "bold") : args.style),
              (mentionedPlayers.includes(player.id) ? 2 : args.sound)
              )
          }

      }
    break;
    case "set_player_admin":
      window.room.setPlayerAdmin(args.player_id, args.admin)
    break;
    case "set_player_team":
      window.room.setPlayerTeam(args.player_id, args.team)
    break;
    case "kick_player":
      window.room.kickPlayer(args.player_id, args.reason, args.ban)
    break;
    case "clear_ban":
      window.room.clearBan(args.player_id)
    break;
    case "clear_bans":
      window.room.clearBans()
    break;
    case "set_score_limit":
      window.room.setScoreLimit(args.limit)
    break;
    case "set_time_limit":
      window.room.setTimeLimit(args.limit_in_minutes)
    break;
    case "set_custom_stadium":
      window.room.setCustomStadium(args.stadium_file_contents)
    break;
    case "set_default_stadium":
      window.room.setDefaultStadium(args.stadium_name)
    break;
    case "set_teams_lock":
      window.room.setTeamsLock(args.locked)
    break;
    case "set_team_colors":
      window.room.setTeamColors(args.team, args.angle, args.text_color, Object.values(args.colors))
    break;
    case "start_game":
      window.room.startGame()
    break;
    case "stop_game":
      window.room.stopGame()
    break;
    case "pause_game":
      window.room.pauseGame(args.pause_state)
    break;
    case "start_recording":
      window.room.startRecording()
    break;
    case "stop_recording":
      let recording = window.room.stopRecording()
  
      send("event", { event: "onStopRecording", args: { recording } }) // CUSTOM EVENT
    break;
    case "set_password":
      window.room.setPassword(args.pass)
    break;
    case "set_require_captcha":
      window.room.setRequireCaptcha(args.required)
    break;
    case "reorder_players":
      window.room.reorderPlayers(args.player_id_list, args.move_to_top)
    break;
    case "set_kick_rate_limit":
      window.room.setKickRateLimit(args.min, args.rate, args.burst)
    break;
    case "set_player_avatar":
      window.room.setPlayerAvatar(args.player_id, args.avatar)
    break;
    case "set_disc_properties":
      window.room.setDiscProperties(args.disc_index, args.properties)
    break;
    case "set_player_disc_properties":
      window.room.setPlayerDiscProperties(args.player_id, args.properties)
    break;
  }

}

window.onHBLoaded = () => {
  
  window.socket = new WebSocket("ws://localhost:4333/ws")
  window.socket.onopen = () => {
    messageListener()
  }

}