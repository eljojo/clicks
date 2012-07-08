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

obtenerSegundos = (tiempo) -> Math.round ((new Date()).getTime() - tiempo.getTime())/1000

calcularPuntaje = (user) ->
  clicks = user.clicks
  totalClicks = clicks.length
  return 0 if totalClicks == 0
  tiempo_de_juego = obtenerSegundos(clicks[0])
  puntaje = Math.pow(totalClicks, 2) * Math.log(tiempo_de_juego) / (Math.log(10) * Math.pow(tiempo_de_juego, 1.2))
  if puntaje == -Infinity then puntaje = 0
  return Math.round(puntaje * 10) 


enviarTop = ->
  # -- tops puntaje
  user.puntaje = calcularPuntaje(user) for user in users
  topsPuntaje = users.sort (a,b) ->
    b.puntaje - a.puntaje
  topsPuntaje = topsPuntaje[0..9].map (user) -> {nombre: user.name, id: user.id, puntaje: user.puntaje}
  # -- tops click presionado
  # topsClickPressed = users.sort (a,b) ->
  #   return 0 if b.clicks.length == 0 and a.clicks.length == 0
  #   return 1 if b.clicks.length == 0
  #   return -1 if a.clicks.length == 0
  #   b.clicks[b.clicks.length - 1].getTime() - a.clicks[a.clicks.length - 1].getTime()
  # actualTime = new Date()
  # #masTiempoClick = user if user.lastClick != '' and user.lastClick.getTime() > userLastClick.lastClick.getTime()
  # topsClickPressed = topsClickPressed[0..9].map (user) -> {nombre: user.name, id: user.id, tiempo: user.clicks[user.clicks.length - 1].getTime() - actualTime.getTime()}
  # -- top por tiempo y clicks
  masAntiguo = users[0]
  masAntiguo = { clicks: [new Date()] } if users[0].clicks.length == 0
  masClicks = users[0]
  for user in users
    continue if user.clicks.length == 0
    masAntiguo = user if user.clicks[0].getTime() < masAntiguo.clicks[0].getTime()
    masClicks = user if user.clicks.length > masAntiguo.clicks.length
  # formateamos el resultado y enviamos
  top =
    puntajes: topsPuntaje
    #clickApretado: topsClickPressed
    tiempo: { nombre: masAntiguo.name, id: masAntiguo.id, tiempo: obtenerSegundos masAntiguo.clicks[0] }
    clicks: { nombre: masClicks.name, id: masClicks.id, clicks: masClicks.clicks.length }
  conexion.emit 'top', top for conexion in conexiones

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
setInterval( ->
  enviarTop() if users.length > 0 and users[0].clicks.length > 0
, 250)
io.sockets.on "connection", (socket) ->
  conexiones.push socket
  socket.on "userData", (data) ->
    user = 
      id: data.id
      name: data.nombre
      clicks: []
      lastClick: ''
      puntaje: 0
    users.push user
    cl "+ ahora somos #{users.length}"
    cl "llegó #{user.name}, id: #{user.id}"
    socket.emit 'ready'
    # -- user disconnect
    socket.on 'disconnect', (socket) ->
      conexiones.remove socket
      users.remove user
      cl "se fue #{user.name}"
      cl "- ahora somos #{users.length}"
    # -- user click down
    socket.on "clickDown", (data) ->
      user.lastClick = new Date
    # -- user click up
    socket.on "clickUp", (data) ->
      user.clicks.push new Date
      user.lastClick = ''
      cl "puntaje de #{user.name}: #{user.puntaje}"
      socket.emit 'self', {clicks: user.clicks.length, puntaje: user.puntaje}
      
