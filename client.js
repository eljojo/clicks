socket_server = (window.location.hostname.indexOf('heroku') > 0) ? 'http://eljojo.net:3456' : 'http://'+window.location.hostname
var socket = io.connect(socket_server);
$(function() {
  var chart = new SmoothieChart();
  var clicks = new TimeSeries();
  chart.addTimeSeries(clicks, { strokeStyle: 'rgba(0, 255, 0, 1)', fillStyle: 'rgba(0, 255, 0, 0.2)', lineWidth: 4 });
  chart.streamTo(document.getElementById("clicks_stats"), 600);
  
  socket.emit('quieroMisStatsConQuesoAHORA')
  socket.on('stats!', function(stats) {
    console.log(stats)
    clicks.append(stats.date, stats.clicks);
  })
  
})
