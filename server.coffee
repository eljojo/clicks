cl = (what) -> console.log(what)

handler = (req, res) ->
  peticion = (if (req.url is "/") then "/client.html" else req.url)
  fs.readFile __dirname + peticion, (err, data) ->
    if err
      res.writeHead 500
      return res.end("Error loading index.html")
    res.writeHead 200
    res.end data

app = require("http").createServer(handler)
io = require("socket.io").listen(app)
fs = require("fs")

app.listen 3000
io.set "log level", 1
conexiones = []

io.sockets.on "connection", (socket) ->
  conexiones.push socket
  
  #socket.on 'disconnect', (socket) ->
    #cl socket
  
  socket.on "name", (name) ->
    socket.set 'name', name, ->
      socket.emit 'ready'
    
  socket.on "click", (data) ->
    socket.get 'name', (err, nombre) ->
      cl "#{nombre} hizo click"
      for conexion in conexiones
        conexion.emit 'clickDe', nombre
      