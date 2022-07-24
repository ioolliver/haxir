import Config

config :haxir, Haxir.Socket.Handler,
  port: 4333,
  path: "/ws",
  max_connections: 2, # don't accept connections if server already has this number of connections
  max_connection_age: :infinity, # force to disconnect a connection if the duration passed. if :infinity is set, do nothing.
  idle_timeout: :infinity, # disconnect if no event comes on a connection during this duration
  reuse_port: false, # TCP SO_REUSEPORT flag
  show_debug_logs: false,
  transmission_limit: [
    capacity: 1000,  # if 1000 frames are sent on a connection
    duration: 2000 # in 2 seconds, disconnect it.
  ]

config :haxir, :config, %{
    room_name: "Haxir's Headless room",
    max_players: 12,
    public: false,

    token: ""
  }
