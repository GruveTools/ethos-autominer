<?php
	if (empty($whattomine_url)) {
		$whattomine_url = 'http://whattomine.com/coins?utf8=%E2%9C%93&adapt_q_280x=0&adapt_q_380=0&adapt_q_fury=0&adapt_q_470=0&adapt_q_480=3&adapt_q_570=0&adapt_q_580=0&adapt_q_vega56=0&adapt_q_vega64=0&adapt_q_750Ti=0&adapt_q_1050Ti=0&adapt_q_10606=0&adapt_q_1070=6&adapt_1070=true&adapt_q_1080=0&adapt_q_1080Ti=0&eth=true&factor%5Beth_hr%5D=180.0&factor%5Beth_p%5D=720.0&grof=true&factor%5Bgro_hr%5D=213.0&factor%5Bgro_p%5D=780.0&x11gf=true&factor%5Bx11g_hr%5D=69.0&factor%5Bx11g_p%5D=720.0&cn=true&factor%5Bcn_hr%5D=3000.0&factor%5Bcn_p%5D=600.0&eq=true&factor%5Beq_hr%5D=2580.0&factor%5Beq_p%5D=720.0&lre=true&factor%5Blrev2_hr%5D=213000.0&factor%5Blrev2_p%5D=780.0&ns=true&factor%5Bns_hr%5D=6000.0&factor%5Bns_p%5D=930.0&lbry=true&factor%5Blbry_hr%5D=1620.0&factor%5Blbry_p%5D=720.0&bk2bf=true&factor%5Bbk2b_hr%5D=9600.0&factor%5Bbk2b_p%5D=720.0&bk14=true&factor%5Bbk14_hr%5D=15000.0&factor%5Bbk14_p%5D=750.0&pas=true&factor%5Bpas_hr%5D=5640.0&factor%5Bpas_p%5D=720.0&skh=true&factor%5Bskh_hr%5D=159.0&factor%5Bskh_p%5D=720.0&factor%5Bl2z_hr%5D=420.0&factor%5Bl2z_p%5D=300.0&factor%5Bcost%5D=0.18&sort=Profitability3&volume=0&revenue=3d&factor%5Bexchanges%5D%5B%5D=&factor%5Bexchanges%5D%5B%5D=bittrex&factor%5Bexchanges%5D%5B%5D=bleutrade&factor%5Bexchanges%5D%5B%5D=cryptopia&factor%5Bexchanges%5D%5B%5D=hitbtc&factor%5Bexchanges%5D%5B%5D=poloniex&factor%5Bexchanges%5D%5B%5D=yobit&dataset=Main&commit=Calculate';
	}

	if (empty($pushbullet_token)) {
		$pushbullet_token = 'YOUR_PUSH_BULLET_TOKEN';
	}

        if (empty($pushover_user) && empty($pushover_token)) {
                $pushover_user = 'YOUR_PUSHOVER_USER_KEY';
                $pushover_token = 'YOUR_PUSHOVER_TOKEN';
        }

	// To set a threshold for switching, specify a percentage value below, example:
	// $switch_threshold = 25;
	// This will only switch coins if the new coin is 25% more profitable than the current coin.
	$switch_threshold = '';

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
