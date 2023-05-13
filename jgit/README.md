# jgit

jgit is a simple bash script that helps manage git branches

## Usage

Run `jgit` with one of the following commands:

- `-p` or `--purge-gone`: Remove local branches tracking remote branches that are gone.
- `-m` or `--purge-merged`: Remove local branches that have been merged.
- `-f` or `--files-changed`: List files changed from `origin/master`.
- `-t` or `--track-all`: Track all remote branches locally.
- `-h` or `--help`: Show help information and exit.

## Installation

1. Clone the repository
```bash
git clone https://github.com/username/jgit.git
```

2. Navigate to the `jgit` directory
```bash
cd jgit
```

3. Create a symbolic link to the script in `/usr/local/bin`
```bash
sudo ln -s /absolute/path/to/your/script/jgit.sh /usr/local/bin/jgit
```

Now, you should be able to run the `jgit` command from anywhere

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
