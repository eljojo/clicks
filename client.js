var socket = io.connect('http://eljojo.net:3456');
$(function() {
  $("#boton").hide()
  $("#nombre").val('')
  $("#boton").click(function(){
    socket.emit('click')
  })
  $("#nombre").change(function(){
    socket.emit('name', $(this).val())
  })
  socket.on('clickDe', function(nombre){
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
