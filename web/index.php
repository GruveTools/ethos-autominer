<!DOCTYPE html>
<html>
<head>
<?php
$home_dir = '/home/ethos/';
$ethos_autominer_dir = $home_dir . '.autominer/';
require_once($ethos_autominer_dir . 'config.php');
$current_coin = file_get_contents($ethos_autominer_dir . 'current_coin.txt');
$local_conf = file_get_contents($home_dir . 'local.conf');

$rig = gethostname();

$custom_panel = '';
$local_conf = explode("\n", $local_conf);
for ($i = 0; $i < count($local_conf); $i++) {
    if (strpos($local_conf[$i], 'custompanel') !== false) {
        $cp = explode(' ', $local_conf[$i]);
        $cp = $cp[1];
        $custom_panel = 'http://' . substr($cp, 0, 6) . '.ethosdistro.com/?json=yes';
    }
}
?>
  <meta charset="utf-8">
  <title>ethOS Autominer</title>
  <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no' />

  <link rel="icon" type="image/png" href="favicon.png">

  <!-- Demo Dependencies -->
  <script src="assets/js/jquery.min.js" type="text/javascript"></script>
  <script src="assets/js/bootstrap.min.js" type="text/javascript"></script>
  <link href="assets/css/bootstrap.min.css" rel="stylesheet" type="text/css" />

  <!-- keen-analysis@1.2.2 -->
  <script src="assets/js/keen-analysis-1.2.2.js" type="text/javascript"></script>

  <!-- keen-dataviz@1.1.3 -->
  <link href="assets/css/keen-dataviz-1.1.3.css" rel="stylesheet" />
  <script src="assets/js/keen-dataviz-1.1.3.js" type="text/javascript"></script>

  <!-- Dashboard -->
  <link href="assets/css/keen-dashboards.css" rel="stylesheet" type="text/css" />
  <script>
    var custompanel = '<?php echo $custom_panel; ?>';
    var rig = '<?php echo $rig; ?>';
    </script>
  <script type="text/javascript" src="assets/js/ethos-autominer.js"></script>
</head>
<body class="keen-dashboard" style="padding-top: 80px;">

  <div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
    <div class="container-fluid">
      <div class="navbar-header">
        <a class="navbar-brand" href="/">ethOS Autominer</a>
      </div>
      <div class="navbar-collapse collapse">
        <ul class="nav navbar-nav navbar-left">
            <li><a href="#">Rig: <?php echo $rig; ?></a></li>
            <li><a href="#">Current coin: <?php echo $current_coin; ?></a></li>
        </ul>
      </div>
    </div>
  </div>

  <div class="container-fluid">
    <div class="row">

      <div class="col-sm-8">
        <div id="chart-hashrate"></div>
        <br>
      </div>

      <div class="col-sm-4">
        <div id="chart-overview">
          <div class="keen-dataviz">
            <div class="keen-dataviz-title">Overview</div>
            <div class="keen-dataviz-stage">
              <div class="keen-dataviz-rendering" style="height: 223px;">
                <ul id="overview-list" style="list-style: none; margin-left: 0; padding-left: 10px;">
                </ul>
              </div>
            </div>
          </div>
        </div>
        <br>
      </div>

    </div>

    <div class="row">

      <div class="col-sm-8">
        <div id="chart-temp"></div>
        <br>
      </div>

      <div class="col-sm-4">
        <br>
      </div>

    </div>

    <hr>

    <p class="small text-muted"><a href="https://github.com/Japh/ethos-autominer">Built with &#9829;</a></p>
  </div>

</body>
</html>
