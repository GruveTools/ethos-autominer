# ethOS Autominer

## Usage

_Backup your `local.conf` before running this script._

The script file can live in the `/home/ethos` directory on your rig. Run the script using cron at your chosen interval, such as hourly with `0 * * * *`.

You should also create a `scripts` and `configs` directory alongside the script. The `configs` directory should contain the various config files for the coins you want to mine, and you should copy the `config.sample.php` to `config.php` and edit it to refer to your config files and contain just the coins you want to switch between.

If you pass `--dry-run` to the script, it won't do any of the miner restarting, _but will still switch configs_.
