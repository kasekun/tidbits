# jtm

jtm is a simple bash script that helps manage tmux instances by allowing you to create a simple
tmux session setup script that can be executed with jtm. 
jtm will help you handle cases where the session already exists, too.

## Installation

1. Clone the parent repository
```bash
git clone https://github.com/kasekun/tidbits.git
```

2. Navigate to the `jtm` directory
```bash
cd tidbits/jtm
```

3. Create a symbolic link to the script in `/usr/local/bin`
```bash
sudo ln -s $(pwd)/jtm.sh /usr/local/bin/jtm
```

## Getting started

Create a folder for these `jtm` launch scripts
```sh
    mkdir -p "~/scripts/jtm-launchers"
```

Inside of `~/scripts/jtm-launchers` folder, create a tmux setup script ending in `.sh` similar to this.

```sh
#!/bin/bash

session_name="my-project"
dir="$HOME/work/my-project"

# The function name `setup_session()` is critical
function setup_session() {
    # Create a session with a single window and vertically stacked panes
    # the top pane will navigate to `dir` then run `yarn && yarn dev`
    # the bottom pane will navigate to `dir`
    tmux new-session -d -s "$session_name" -n 'dev'
    sleep 0.1
    tmux send-keys -t "$session_name:dev.0" "cd ${dir}" C-m
    tmux send-keys -t "$session_name:dev.0" "yarn && yarn dev" C-m
    tmux split-window -v -t "$session_name:dev"
    sleep 0.1
    tmux send-keys -t "$session_name:dev.1" "cd ${dir}" C-m
}
```

Make sure that your script is executable 

`chmod +x ~/scripts/jtm-launchers/your-launcher.sh`

create this tmux session by running `jtm` and selecting `your-launcher.sh` from the list

## Usage

Run `jtm` with one of the following commands:

- `-r` or `--r`: Run the selector for selecting your tmux
- `-l` or `--list`: List all available jtm session scripts.
- `-h` or `--help`: Show help information and exit.

### to do

 - [ ] add a `--new-script` flag 
 - [ ] allow configuration of default path 
 - [ ] remove the need to have scripts end in `.sh`



Now, you should be able to run the `jtm` command from anywhere

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
