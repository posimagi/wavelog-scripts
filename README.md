# AK6EU's Wavelog scripts

Setting up and maintaining a Wavelog instance isn't always as straightforward as I'd like. That's why these scripts exist.

## How to use

1. Clone the repo
2. Run `sudo ./scripts/step-1-configure-environment.sh` from the repo root
3. Go to `http://localhost:8086` in your browser and follow the instructions on screen
4. Run `sudo ./scripts/step-2-extract-configuration-files.sh` from the repo root
5. Make any configuration changes you want in `config/config.php` and/or `config/wavelog.php`
6. Run `scripts/apply-configuration-changes.sh`
7. When you want to update Wavelog, run `scripts/update-wavelog.sh`
