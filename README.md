# ethOS Autominer

> _**Note:** I'm not convinced that providing the parameters in the URL for the whattomine JSON actually does anything, therefore I'd recommend manually checking with the form which coins, and this script will determine which of those coins whattomine says is most profitable at any given moment._

## Usage

_Backup your `local.conf` before running this script. You may also choose to run `force-local` on your rig to prevent override from a remote config._

The script file can live in the `/home/ethos` directory on your rig. Run the script using cron at your chosen interval, such as hourly with `0 * * * *`.

You should also create a `scripts` and `configs` directory alongside the script. The `configs` directory should contain the various config files for the coins you want to mine, and you should copy the `config.sample.php` to `config.php` and edit it to refer to your config files and contain just the coins you want to switch between.

If you pass `--dry-run` to the script, it won't do any of the miner restarting, _but will still switch configs_.

## Background

This script was originally shared by AllCrypto in the YouTube video [How I Mine the Most Profitable Altcoins With ethOS](https://www.youtube.com/watch?v=vf0doK-j54g), with the [snippet](http://textuploader.com/dl3w5) linked in the comments.

I've adapted it to remove some of the personal peculiarities to AllCrypto's preferences and needs, so it's now just a simple profitability switcher.
