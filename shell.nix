{
    pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
    buildInputs = with pkgs; [
        # dependencies for the installer
        bash
        curl
        zenity
        p7zip
        jq
        protontricks

        # dependencies to build the steam redirector
        gcc
        gnumake
        pkgsCross.mingwW64.stdenv.cc
    ];

    shell = pkgs.bashInteractive;

    shellHook = ''
        # don't build the steam redirector again if it's already there
        if ! [ -f ./steam-redirector/main.exe ]; then
            cd steam-redirector
            make main.exe
            cd ..
        fi

        ./install.sh
    '';
}
