<?php
$home_dir = '/home/ethos/';
$ethos_autominer_dir = $home_dir . '.autominer/';

$db = json_decode(file_get_contents($ethos_autominer_dir . 'db.json'));

$since = (!empty($_GET['since']) ? $_GET['since'] : 0);
$metric = (!empty($_GET['metric']) ? $_GET['metric'] : 0);

$output = new \stdClass();
$output->stats = [];

$pool_data = new \stdClass();
$pool_data->result = [];

$current_pool = '';

$pools = [];
for ($i = 0; $i < count($db->stats); $i++) {
    $pool_url = $db->stats[$i]->data->pool;
    if ($db->stats[$i]->timestamp > $since) {
        if (empty($pools[$pool_url])) {
            $pools[$pool_url] = 1;
        } else {
            $pools[$pool_url] += 1;
        }
    }
    if ($i == count($db->stats) - 1) {
        $current_pool = $pool_url;
    }
}

$config_dir = scandir($ethos_autominer_dir . 'configs');
$configs = array();

for($i = 0; $i < count($config_dir); $i++) {
    if ($config_dir[$i] == '.' || $config_dir[$i] == '..') {
        continue;
    }
    $conf = explode('.', $config_dir[$i]);
    $conf = $conf[0];
    $configs[$conf] = file_get_contents($ethos_autominer_dir . 'configs/' . $config_dir[$i]);
}

foreach($pools as $pool => $qty) {
    $pool_name = $pool;
    foreach($configs as $conf => $data) {
        if (strpos($data, $pool) !== false) {
            if ($pool == $current_pool) {
                $current_pool = $conf;
            }
            $pool_name = $conf;
        }
    }
    $p = new \stdClass();
    $p->pool = $pool_name;
    $p->result = $qty;
    array_push($pool_data->result, $p);
}

$pool_data->current_config = $current_pool;

echo json_encode($pool_data);
