socket_server = (window.location.hostname == 'clix.herokuapp.com' ? 'http://eljojo.net:3456' : 'http://'+window.location.hostname)
var socket = io.connect(socket_server);
$(function() {
  $("#boton").hide()
  $("#nombre").val('')
  $("#boton").mousedown(function(){
    socket.emit('clickDown')
  })
  $("#boton").mouseup(function(){
    socket.emit('clickUp')
  })
  $("#nombre").change(function(){
    socket.emit('name', $(this).val())
  })
  socket.on('clickDe', function(user) {
    nombre = user.name
    puntaje = user.puntaje
    console.log(nombre + " hizo click")
    date = new Date();
    fecha = date.getHours()+ ':'+date.getMinutes() + ':'+date.getSeconds()
    $("#clicks").prepend($("<li>").text(fecha+' -> '+nombre+' puntaje: '+puntaje))
    if($("#clicks li").length > 10) {
      $("#clicks li").last().remove()
    }
  })
  socket.on('ready', function(){
    $("#boton").show()
  })
})
