# Start from the code-server Debian base image
FROM codercom/code-server:latest

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Install Inital Dependencies
RUN sudo apt-get update
sudo apt-get install unzip make -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# -----------------------------------------------
# ------ CUSTOM ---------------------------------
# -----------------------------------------------

# Install Dotfiles
RUN git clone https://github.com/martokk/dotfiles-dev /home/coder/dotfiles-dev
RUN make -C /home/coder/dotfiles-dev install

# Install ZSH, set shell to zsh
RUN sudo apt-get install zsh -y
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /home/coder/.oh-my-zsh/plugins/zsh-autosuggestions
RUN echo "source ~/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> /home/coder/.zshrc
ENV SHELL=/bin/zsh

# Add JetBrains Mono font
WORKDIR /usr/lib/code-server
RUN find . -name workbench.html | sudo xargs sed -i "s%</head>%<style>@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono\&display=swap');</style></head>%g"

# Setup python development
RUN sudo apt-get update
RUN sudo apt-get install python3-dev python3-pip nano git curl wget -y
RUN python3 -m pip install pip
RUN python3 -m pip install wheel

# Add Python Extentions
RUN code-server --install-extension ms-python.python
RUN code-server --install-extension ms-python.black-formatter
RUN code-server --install-extension ms-toolsai.jupyter
RUN code-server --install-extension redhat.vscode-yaml
RUN code-server --install-extension SonarSource.sonarlint-vscode
RUN code-server --install-extension sourcery.sourcery
RUN code-server --install-extension formulahendry.code-runner
RUN code-server --install-extension KevinRose.vsc-python-indent

# Add Dart/Flutter Extentions
# RUN code-server --install-extension Dart-Code.dart-code
# RUN code-server --install-extension Dart-Code.flutter

# Other Extensions from https://open-vsx.org/
RUN code-server --install-extension esbenp.prettier-vscode

# -----------------------------------------------
# -----------------------------------------------
# -----------------------------------------------

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
