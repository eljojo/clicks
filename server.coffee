# ---- clicks server ----

# -- funciones
# alias a console.log
cl = (what) -> console.log(what)
# remover elementos de un array. sacado de http://stackoverflow.com/questions/4825812/clean-way-to-remove-element-from-javascript-array-with-jquery-coffeescript
Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1
# Date object a hora
getHora = (date) -> 
  minutos = date.getMinutes()
  minutos = '0'+minutos if minutos < 10
  segundos = date.getSeconds()
  segundos = '0'+segundos if segundos < 10
  date.getHours() + ":#{minutos}:#{segundos}"

calcularPuntaje = (user) ->
  clicks = user.clicks
  totalClicks = clicks.length
  tiempo_de_juego = (clicks[totalClicks - 1].getTime() - clicks[0].getTime())/1000
  puntaje = Math.pow(totalClicks, 2) * Math.log(tiempo_de_juego) / (Math.log(10) * Math.pow(tiempo_de_juego, 1.2))
  if puntaje == -Infinity then puntaje = 0
  return Math.round(puntaje * 10) 


enviarTop = ->
  topsPuntaje = users.sort (a,b) ->
    b.puntaje - a.puntaje
  topsPuntaje = topsPuntaje[0..9].map (user) -> {nombre: user.name, puntaje: user.puntaje}
  conexion.emit 'topPuntajes', topsPuntaje for conexion in conexiones

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

port = process.env.PORT || 3456
app.listen port
io.set "log level", 1
conexiones = []
users = []
io.sockets.on "connection", (socket) ->
  conexiones.push socket
  user = 
    id: conexiones.length
    name: ''
    clicks: []
    lastClick: ''
    puntaje: 0
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
    
  socket.on "clickDown", (data) ->
    #user.clicks.push new Date
    #user.lastClick = new Date
    # cl "click down! #{user.name}: #{getHora(user.lastClick)}"
#    for conexion in conexiones
#      conexion.emit 'clickDe', {name: user.name, clicks: user.clicks.length}
    
  socket.on "clickUp", (data) ->
    user.clicks.push new Date
    user.puntaje = calcularPuntaje(user)
    cl "puntaje de usuario #{user.name}: #{user.puntaje}"
#     for conexion in conexiones
#      conexion.emit 'clickDe', {name: user.name, puntaje: user.puntaje}
    enviarTop()
    

  


