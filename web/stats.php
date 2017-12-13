<?php
$home_dir = '/home/ethos/';
$ethos_autominer_dir = $home_dir . '.autominer/';

$db = json_decode(file_get_contents($ethos_autominer_dir . 'db.json'));

$since = (!empty($_GET['since']) ? $_GET['since'] : 0);
$metric = (!empty($_GET['metric']) ? $_GET['metric'] : 0);

$output = new \stdClass();
$output->stats = [];

$hashrate_data = new \stdClass();
$hashrate_data->result = [];

for ($i = 0; $i < count($db->stats); $i++) {
    if ($db->stats[$i]->timestamp > $since) {
        array_push($output->stats, $db->stats[$i]);
        $hashrate_row = new \stdClass();
        $hashrate_row->value = [];
        $hashrate_row->timeframe = new \stdClass();
        $hashrate_row->timeframe->start = date('c', $db->stats[$i]->timestamp);
        $hashrate_row->timeframe->end = date('c', $db->stats[$i]->timestamp);

        $gpus = explode(' ', $db->stats[$i]->data->$metric);
        for($j = 0; $j < count($gpus); $j++) {
            $gpu = new \stdClass();
            $gpu->gpu = 'GPU #' . $j;
            $gpu->result = $gpus[$j];
            array_push($hashrate_row->value, $gpu);
        }

        array_push($hashrate_data->result, $hashrate_row);
    }
}

echo json_encode($hashrate_data);
