# Building the FoxFlake installer image

1. Install the nix package manager on your system according to the instructions at:
https://nixos.org/download

2. run the below command in this directory:
`nix --extra-experimental-features "nix-command flakes" build .#installer`

