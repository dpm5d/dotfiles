#!/bin/sh

GIT=$(which git 2>/dev/null)
if [ -z "$GIT" ]; then
    echo "no git"
    exit
fi

function install_prelude
{
    pushd $HOME
    if [ -d .emacs.d ]; then
        mv -v .emacs.d .emacs.d.pre-prelude
    fi

    if [ -e .emacs ]; then
        mv -v .emacs .emacs.pre-prelude
    fi

    git clone https://github.com/bbatsov/prelude .emacs.d
    cd .emacs.d
    cp sample/prelude-modules.el .
    popd
}

function write_emacs_service
{
    mkdir -p $HOME/.config/systemd/user

    echo "Writing $HOME/.config/systemd/user/emacs.service"
    cat <<EOF > $HOME/.config/systemd/user/emacs.service
[Unit]
Description=Emacs Daemon

[Service]
Type=forking
ExecStart=/usr/bin/emacs --daemon
ExecStop=/usr/bin/emacsclient --eval "(progn (setq kill-emacs-hook 'nil) (kill-emacs))"
Restart=always

[Install]
WantedBy=default.target
EOF

}

function run_emacs_service
{
    write_emacs_service
    echo "Starting and enabling emacs.service"
    systemctl --user daemon-reload
    systemctl --user start emacs.service
    systemctl --user enable emacs.service
}

install_prelude
run_emacs_service
