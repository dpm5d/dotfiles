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

function write_emacs_desktop
{
    mkdir -p $HOME/.local/share/applications/
    echo "Writing $HOME/.local/share/applications/emacsclient.desktop"
    cat <<EOF > $HOME/.local/share/applications/emacsclient.desktop
#!/usr/bin/env xdg-open

[Desktop Entry]
Version=1.0
Name=GNU Emacs Client
GenericName=Text Editor
Comment=View and edit files
MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
Exec=/usr/bin/emacsclient -c -a "" %F
Icon=/usr/share/icons/hicolor/scalable/mimetypes/emacs-document.svg
Type=Application
Terminal=false
Categories=Utility;Development;TextEditor;
StartupWMClass=Emacs
Name[en_US]=GNU Emacs Client
EOF

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
    write_emacs_desktop
    echo "Starting and enabling emacs.service"
    systemctl --user daemon-reload
    systemctl --user start emacs.service
    systemctl --user enable emacs.service
}

install_prelude
run_emacs_service
