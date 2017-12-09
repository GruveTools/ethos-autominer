<?php
	if (empty($pushbullet_token)) {
		$pushbullet_token = 'YOUR_PUSH_BULLET_TOKEN';
	}

	$coins = [
		'BTG' => array(
			'hash_rate' => 0,
			'config' => 'btg.conf',
		),
		'ETH' => array(
			'hash_rate' => 0,
			'config' => 'eth.conf',
		),
		'BTCZ' => array(
			'hash_rate' => 0,
			'config' => 'BTCZ.conf',
		),
		'ZEC' => array(
			'hash_rate' => 0,
			'config' => 'zec.conf',
		),
		'ZEN' => array(
			'hash_rate' => 0,
			'config' => 'zen.conf',
		),
		'ZCL' => array(
			'hash_rate' => 0,
			'config' => 'zcl.conf',
		),
		'KMD' => array(
			'hash_rate' => 0,
			'config' => 'kmd.conf',
		),
		'ETN' => array(
			'hash_rate' => 0,
			'config' => 'etn.conf',
		),
	];
