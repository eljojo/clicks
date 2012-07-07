socket_server = (window.location.hostname == 'localhost' ? 'http://localhost' : 'http://eljojo.net:3456')
var socket = io.connect(socket_server);
$(function() {
  $("#boton").hide()
  $("#nombre").val('')
  $("#boton").click(function(){
    socket.emit('clickDown')
  })
  $("#nombre").change(function(){
    socket.emit('name', $(this).val())
  })
  socket.on('clickDe', function(user) {
    nombre = user.name
    console.log(nombre + " hizo click")
    date = new Date();
    fecha = date.getHours()+ ':'+date.getMinutes() + ':'+date.getSeconds()
    $("#clicks").prepend($("<li>").text(fecha+' -> '+nombre))
    if($("#clicks li").length > 10) {
      $("#clicks li").last().remove()
    }
  })
  socket.on('ready', function(){
    $("#boton").show()
  })
})
