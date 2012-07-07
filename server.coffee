# ---- clicks server ----

# -- funciones
# alias a console.log
cl = (what) -> console.log(what)
# remover elementos de un array. sacado de http://stackoverflow.com/questions/4825812/clean-way-to-remove-element-from-javascript-array-with-jquery-coffeescript
Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1

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

app.listen 3456
io.set "log level", 1
conexiones = []
users = []
io.sockets.on "connection", (socket) ->
  conexiones.push socket
  user = 
    id: conexiones.length
    name: ''
    clicks: []
  users.push user
  cl "+ ahora somos #{users.length}"
  
  socket.on 'disconnect', (socket) ->
    conexiones.remove socket
    users.remove user
    cl "- ahora somos #{users.length}"
  
  socket.on "name", (name) ->
    user.name = name
    socket.set 'name', name, ->
      socket.emit 'ready'
    
  socket.on "click", (data) ->
    user.clicks.push new Date
    socket.get 'name', (err, nombre) ->
      cl "click! #{user.name}: #{user.clicks.length}"
      for conexion in conexiones
        conexion.emit 'clickDe', user.name
      
