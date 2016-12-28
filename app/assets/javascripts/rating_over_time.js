$(function() {
  var playerId = $('#rating-over-time-graph').data('player-id');
  if(playerId) {
    $.getJSON('/player_stats/' + playerId)
      .error(function() {
        console.log('could not get player stats for: ' + playerId);
      })
    .done(function(data) {
      var ctx = $('#rating-over-time-graph');
      var chart = new Chart(ctx, {
        type: 'line',
        data: {
          labels: xAxisData(data),
          datasets: [
          {
            label: 'Rating',
            lineTension: 0,
            data: yAxisData(data),
            backgroundColor: [
              'rgba(97,179,234, 0.2)'
            ],
            borderColor: [
              'rgba(97,179,234, 1)'
            ],
            borderWidth: 1
          }
          ]
        },
        options: {
          responsive: true,
          maintainAspectRatio: true,
          scales: {
            xAxis: [{
              type: 'time',
              time: {
                unit: 'll'
              }
            }]
          }
        }
      });
    });

    function formatDate(s) {
      var date = new Date(s);
      return (date.getMonth() + 1) + '/' + date.getDate() + '/' + date.getFullYear()
    }

    function xAxisData(data) {
      return $.map(data, function(datum) {
        return formatDate(datum.x);
      });
    }

    function yAxisData(data) {
      return $.map(data, function(datum) {
        return datum.y;
      });
    }
  }
});
