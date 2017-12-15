# ethOS Autominer

## Usage

_Backup your `local.conf` before running this script. You may also choose to run `force-local` on your rig to prevent override from a remote config._

To get up and running, you need to do the following:

### Install script

This script will install to `ethos-autominer` in your home directory, add it to your PATH, and add a cron entry to start it running:

```
curl -o- https://raw.githubusercontent.com/Japh/ethos-autominer/master/install-autominer.sh | bash
```

### Alternative manual install

1. First, clone the repository to your rig:
    `git clone https://github.com/Japh/ethos-autominer ~/ethos-autominer/`

2. Make your configuration directory:
    `mkdir ~/.autominer`

3. Copy the sample config file to your configuration directory:
    `cp ~/ethos-autominer/config.sample.json ~/.autominer/config.json`

4. Edit your `config.json` to set your preferences. The following options in particular:
    * Set the `whattomine_url` by going to [whattomine.com](https://whattomine.com), using the calulator as per your rig setup, and then copy and pasting the URL, replacing `whattomine.com/coins` with `whattomine.com/coins.json` but leaving the rest the same.
    * Set the various `configs` to refer to config files that you have for the relevant coins, which you should copy into `~/.autominer/configs/`.

5. Setup a crontask to run the autominer script every minute, run `crontab -e` to begin editing and add the following line:
    `* * * * * /home/ethos/ethos-autominer/ethos-autominer`

You can also run the script manually, and if you pass `--dry-run` to the script, it won't do any of the miner restarting, _but will still switch configs_.

## Donations

You can send BTC donations to `3Ckx1eocUY5fHinbDXZtCGGqwdT1VwGBa4`.

## Credits

This script has been adapted by [Japh](https://github.com/japh) and [neokjames](https://github.com/neokjames).

This script was originally shared by AllCrypto in the YouTube video [How I Mine the Most Profitable Altcoins With ethOS](https://www.youtube.com/watch?v=vf0doK-j54g), with the [snippet](http://textuploader.com/dl3w5) linked in the comments.
