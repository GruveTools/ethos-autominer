var refresh_interval = 60; // in seconds
var hashrate_timeline, temperature_timeline;
var hashrate_data = { result: []};
var temperature_data = { result: []};

Keen.ready(function(){

  // Hashrate by GPU

  hashrate_timeline = new Keen.Dataviz()
    .el('#chart-hashrate')
    .type('area')
    .height(280)
    .stacked(true)
    .title('Hashrate by GPU')
    .prepare();

  // Temperature by GPU

  temperature_timeline = new Keen.Dataviz()
  .el('#chart-temp')
  .type('area')
  .height(280)
  .stacked(false)
  .title('Temperature by GPU')
  .prepare();

  // Minutes by Pool (pie)

  pools_pie = new Keen.Dataviz()
  .el('#chart-pools')
  .type('pie')
  .height(280)
  .title('Time by Config')
  .prepare();

  fetchPanelData();
  fetchPanelHashrate();
  fetchPanelTemp();
  fetchPanelPools();
  setInterval(fetchPanelData, refresh_interval * 1000);
  setInterval(fetchPanelHashrate, refresh_interval * 1000);
  setInterval(fetchPanelTemp, refresh_interval * 1000);
  setInterval(fetchPanelPools, refresh_interval * 1000);
});

function fetchPanelData() {
  jQuery.getJSON(custompanel, function(data) {
    var overviewList = jQuery('#overview-list');
    overviewList.html('');

    rigData = data.rigs[rig];

    overviewList.append(jQuery('<li>').html('<strong>Rig:</strong> ' + rig));
    overviewList.append(jQuery('<li>').html('<strong>Condition:</strong> ' + rigData.condition));
    overviewList.append(jQuery('<li>').html('<strong>CPU Temperature:</strong> ' + rigData.cpu_temp + '&deg;C'));
    overviewList.append(jQuery('<li>').html('<strong>RAM:</strong> ' + rigData.ram + 'GB'));
    overviewList.append(jQuery('<li>').html('<strong>Free space:</strong> ' + rigData.freespace + 'GB'));
    overviewList.append(jQuery('<li>').html('<strong>GPUs:</strong> ' + rigData.gpus));
    overviewList.append(jQuery('<li>').html('<strong>Miner:</strong> ' + rigData.miner));
    overviewList.append(jQuery('<li>').html('<strong>Pool:</strong> ' + rigData.pool));
    overviewList.append(jQuery('<li>').html('<strong>Current hash:</strong> ' + rigData.hash));
    overviewList.append(jQuery('<li>').html('<strong>Rig uptime:</strong> ' + humanTime(rigData.uptime)));
    overviewList.append(jQuery('<li>').html('<strong>Miner running time:</strong> ' + humanTime(rigData.miner_secs)));

  });
}

function fetchPanelHashrate() {
  var since = (new Date().getTime() / 1000) - 86400;
  jQuery.getJSON('/stats.php?metric=miner_hashes&since=' + since, function(data) {
    hashrate_timeline
      .data(data)
      .sortGroups('desc')
      .render();
  });
}

function fetchPanelTemp() {
  var since = (new Date().getTime() / 1000) - 86400;
  jQuery.getJSON('/stats.php?metric=temp&since=' + since, function(data) {
    temperature_timeline
      .data(data)
      .sortGroups('desc')
      .render();
  });
}

function fetchPanelPools() {
  var since = (new Date().getTime() / 1000) - 86400;
  jQuery.getJSON('/chart.php?since=' + since, function(data) {
    pools_pie
      .data(data)
      .sortGroups('desc')
      .render();
  });
}

function humanTime(delta) {
  var minute = 60,
      hour = minute * 60,
      day = hour * 24,
      week = day * 7;

  var fuzzy;

  if (delta < 30) {
      fuzzy = 'just then.';
  } else if (delta < minute) {
      fuzzy = delta + ' seconds ago.';
  } else if (delta < 2 * minute) {
      fuzzy = 'a minute ago.'
  } else if (delta < hour) {
      fuzzy = Math.floor(delta / minute) + ' minutes ago.';
  } else if (Math.floor(delta / hour) == 1) {
      fuzzy = '1 hour ago.'
  } else if (delta < day) {
      fuzzy = Math.floor(delta / hour) + ' hours ago.';
  } else if (delta < day * 2) {
      fuzzy = 'yesterday';
  }

  return fuzzy;
}
