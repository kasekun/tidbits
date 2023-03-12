### Install and set up Pyenv
```bash
brew install pyenv
pyenv install 3.11.2
pyenv global 3.11.2
```
### Initialize Pyenv for the current shell session (follow instructions for ~/.zshrc)
```bash
pyenv --init
source ~/.zshrc
```
### Verify that we're using Pyenv
```bash
which python # should be `/Users/<user>/.pyenv/shims/python`
python --version # should be `Python 3.11.2`
```

### If everything looks good, let's install Pipenv using this new Python
```bash
pyenv shell 3.11.2
```

### Install Pipenv
```bash
pip install --upgrade pip
pip install pipenv
```

### Now set up a Pipenv virtual environment for your project
```bash
cd ~/path/to/your/project
```
### Initialize a new Git repository if one does not already exist
```bash
git init
pipenv --python $(which python)
```

### Install and set up Direnv so we can automatically use the Pipenv environment
```bash
brew install direnv
```
### Add Direnv to the shell configuration file
```bash
echo -e '\neval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc

echo "layout pipenv" > .envrc
```
### Activate Direnv for this project
```bash
direnv allow
```

### Verify that the Python environments are distinct for this directory and the external global environment
#### (i.e., automatically switch when we `cd` into the project)
```bash
cd
which python # should be `/Users/<user>/.pyenv/shims/python`
cd -
which python # will be something like `/Users/<user>/.local/share/virtualenvs/<project>-<randomString>/bin/python`
```

### Install some packages
```bash
pipenv install --dev black isort
pipenv install arrow
```

### add and commit
```bash
git add . && git commit -m "initialise python environment"
```
