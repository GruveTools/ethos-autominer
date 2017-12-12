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

  fetchPanelData();
  setInterval(fetchPanelData, refresh_interval * 1000);
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

    var hashrates = rigData.miner_hashes.split(' ');
    var temperatures = rigData.temp.split(' ');

    var now = new Date().toISOString();

    var hashrate_row = {
      value: [],
      timeframe: {
        start: now,
        end: now
      }
    };

    var temperature_row = {
      value: [],
      timeframe: {
        start: now,
        end: now
      }
    };

    for (var i = 0; i < hashrates.length; i++) {
      hashrate_row.value.push({
        gpu: "GPU #" + i,
        result: hashrates[i]
      })
    }

    for (var i = 0; i < temperatures.length; i++) {
      temperature_row.value.push({
        gpu: "GPU #" + i,
        result: temperatures[i]
      })
    }

    hashrate_data.result.push(hashrate_row);
    temperature_data.result.push(temperature_row);

    if (hashrate_data.result.length > refresh_interval) {
      hashrate_data.result.shift();
    }

    if (temperature_data.result.length > refresh_interval) {
      temperature_data.result.shift();
    }

    hashrate_timeline
      .data(hashrate_data)
      .sortGroups('desc')
      .render();

    temperature_timeline
      .data(temperature_data)
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
