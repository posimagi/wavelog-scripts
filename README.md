# AK6EU's Wavelog scripts

Setting up and maintaining a Wavelog instance isn't always as straightforward as I'd like. That's why these scripts exist.

## How to use

1. Clone the repo by running `git clone https://github.com/posimagi/wavelog-scripts.git`
2. Run `sudo ./scripts/step-1-configure-environment.sh` from the repo root
3. Go to `http://localhost:8086` in your browser and follow the instructions on screen
   1. For the database configuration, use `wavelog-db` as the hostname. The other items can be found in `docker-compose.yaml` and `secrets/db.env`.
4. Run `sudo ./scripts/step-2-extract-configuration-files.sh` from the repo root
5. Make any configuration changes you want in `config/config.php` and/or `config/wavelog.php`
   1. Changing `$config['encryption_key']` is highly recommended.
6. Run `./scripts/apply-configuration-changes.sh`
7. When you want to update Wavelog, run `./scripts/update-wavelog.sh`
