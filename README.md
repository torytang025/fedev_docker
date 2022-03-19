# A docker image for front-end development

## Intro

- This image is based on Ubuntu:20.04
- pre-installed:
  - common utils:
    - git
    - vim
    - wget
    - curl
    - lsof
    - ping
    - thefuck
  - fe dev
    - node v16
    - nvm
    - nrm
    - yarn
  - zsh & oh-my-zsh
  - zsh plugins:
    - zsh-autosuggestions
    - zsh-syntax-highlighting
    - [_powerlevel10k_](https://github.com/romkatv/powerlevel10k) terminal theme

## Getting started

To run a new container `dev1` with default user `root`:

```shell
docker run --name dev1 -itd torytang025/fedev
```

This image has default users: root & me, and password is the same as username. So you can start with user `me`:

```shell
docker run --user=me --name dev1 -itd torytang025/fedev
```

When you get into the container you created, you will access [_powerlevel10k_](https://github.com/romkatv/powerlevel10k)'s builtin configuration wizard where you can customize your terminal style.

After configuration, the default path has been set to /home/me. Enjoy code~.
