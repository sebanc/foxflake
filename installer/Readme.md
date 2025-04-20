# Building the FoxFlake installer iso image

1. Install the nix package manager on your system according to the instructions at: https://nixos.org/download

2. Clone this repository:
`git clone -b stable https://github.com/sebanc/foxflake.git`

3. Enter the "installer" subfolder:
`cd ./foxflake/installer`

4. Update the installer flake lock
`nix --extra-experimental-features "nix-command flakes" flake update --flake .`

5. Launch the build:
`nix --extra-experimental-features "nix-command flakes" build .#installer`

