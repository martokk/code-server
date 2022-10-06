# Start from the code-server Debian base image
FROM codercom/code-server:latest

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# Install Inital Dependencies
RUN sudo apt-get update
RUN sudo apt install software-properties-common fontconfig gpg unzip make nano git curl wget zsh -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Install Dotfiles
RUN git clone https://github.com/martokk/dotfiles /home/coder/dotfiles
RUN make -C /home/coder/dotfiles install profile=dev

# Install ZSH, set shell to zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /home/coder/.oh-my-zsh/plugins/zsh-autosuggestions
RUN echo "source ~/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> /home/coder/.zshrc
ENV SHELL=/bin/zsh

# Setup Python3 Environment
# RUN sudo apt-get install python3-dev python3-pip -y
# RUN python3 -m pip install pip
# RUN python3 -m pip install wheel

# Setup Python3.10 Environment
RUN echo "deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu focal main" | sudo tee /etc/apt/sources.list.d/deadsnakes.list
RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BA6932366A755776
RUN sudo apt-get update
RUN sudo apt-get install python3.10 python3.10-dev python3.10-venv python3.10-distutils python3.10-tk -y
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
RUN python3.10 -m pip install --upgrade pip
RUN python3.10 -m pip install wheel

# Add Python Extentions
RUN code-server --install-extension 2gua.rainbow-brackets
RUN code-server --install-extension aaron-bond.better-comments
RUN code-server --install-extension christian-kohler.path-intellisense
RUN code-server --install-extension donjayamanne.python-environment-manager
RUN code-server --install-extension esbenp.prettier-vscode
RUN code-server --install-extension formulahendry.code-runner
RUN code-server --install-extension hyesun.py-paste-indent
RUN code-server --install-extension johnpapa.vscode-peacock
RUN code-server --install-extension kde.breeze
RUN code-server --install-extension KevinRose.vsc-python-indent
RUN code-server --install-extension marclipovsky.string-manipulation
RUN code-server --install-extension ms-python.black-formatter
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension ms-python.vscode-pylance
RUN code-server --install-extension ms-toolsai.jupyter
RUN code-server --install-extension ms-vscode.makefile-tools
RUN code-server --install-extension njqdev.vscode-python-typehint
RUN code-server --install-extension oderwat.indent-rainbow
RUN code-server --install-extension patrick91.python-dependencies-vscode
RUN code-server --install-extension piotrpalarz.vscode-gitignore-generator
RUN code-server --install-extension redhat.vscode-yaml
RUN code-server --install-extension sdras.night-owl
RUN code-server --install-extension SonarSource.sonarlint-vscode
RUN code-server --install-extension sourcery.sourcery
RUN code-server --install-extension streetsidesoftware.code-spell-checker
RUN code-server --install-extension truman.autocomplate-shell
RUN code-server --install-extension usernamehw.errorlens
RUN code-server --install-extension VisualStudioExptTeam.intellicode-api-usage-examples
RUN code-server --install-extension VisualStudioExptTeam.vscodeintellicode
RUN code-server --install-extension VisualStudioExptTeam.vscodeintellicode-completions

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
