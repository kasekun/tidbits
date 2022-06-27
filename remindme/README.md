# remindme

Set up verbal reminders on your machine (macOS or linux) using Text-To-Speech

## Example

The usage pattern is
```sh
remindme "your reminder" <frequency-of-reminder-in-minutes> <duraiton-of-reminder-in-hours>
```

Remind yourself to drink water every 15 minutes for 5 hours
```sh
remindme "hydration check" 15 5
```
Remind yourself to look away from your monitor every 30 min for 7 hours
```sh
remindme "eye fatigue check" 30 7
```

List all reminders
```sh
remindme -l
```

kill all reminders (with confirmation prompt)
```sh
remindme -k
```

## Usage
Available via 
```sh
remindme -h
```


## Setup
(substitute paths are required by your machine)
1. Download `remindme.sh` and move it somewhere it'll be safe (e.g.,
    
    ```sh
    mv ~/Downloads/remindme.sh ~/scripts/
    ```
2. make a symbolic link to `/usr/local/bin` so you can call `remindme` from anywhere
    
    ```sh
    sudo ln -s ~/scripts/remindme.sh /usr/local/bin/remindme
    ```
3. make the new symbolic link executable
    
    ```sh
    chmod +x /usr/local/bin/remindme
    ```
4. [OPTIONAL] if you want to be able to run `remindme` in the background so it doesn't hog your terminal, add the following function to your `~/.bashrc` or `~/.zshrc`
    
    ```sh
    remindme() {
        if ! [[ ($# -eq 3) ]]; then
            # run in foreground if not a valid reminder (e.g., remindme -k)
            /usr/local/bin/remindme "$@"
        else
            # run in background
            nohup /usr/local/bin/remindme "$@" 2>/dev/null &
        fi
    }
    ```
    Then re-source your `~/.bashrc` or `~/.zshrc`
    ```sh
    source ~/.zshrc
    ```
5. Success! Now you can set reminders from anywhere. 

---

### Making a go-to set of reminders

I have added a function to my `~/.bashrc` to run the following reminders daily

```sh
remindCore() {
  remindme "hydration check" 15 5
  sleep 2
  remindme "posture check" 9 5
  sleep 2
  remindme "focus check" 20 5
  sleep 2
  remindme "eye fatigue check" 30 5
  sleep 2
  remindme "workout" 90 5
}
```
