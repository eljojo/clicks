socket_server = (window.location.hostname.indexOf('heroku') > 0) ? 'http://eljojo.net:3456' : 'http://'+window.location.hostname
var socket = io.connect(socket_server);
$(function() {
  socket.emit('quieroMisStatsConQuesoAHORA')
  
  socket.on('stats!', function(stats) {
    console.log(stats)
  })
  
})
