<!-- Shields/Logos -->
[![License][license-shield]][license-url]
[![Issues][issues-shield]][issues-url]
[![Discord][discord-shield]][discord-url]

<h1 align="center">FoxFlake</h1>

## About this project

FoxFlake is a comprehensive configuration of the NixOS Linux distribution (Flake) which aims to reproduce the best features of ChromeOS using Open Source Software (simple, very stable system and without any maintenance tasks needed) while providing native access to the full catalogue of Linux applications:<br>
- FoxFlake automatically configures the system and does not require any preliminary NixOS knowledge.<br>
- Plasma and Gnome desktop environments ensure ease of use and respectively provide KDE Connect / GSConnect for Phone integration with your Computer.<br>
- Firefox is proposed as default web browser (but is not imposed, the choice remains yours).<br>
- Waydroid can be included for android applications support (optional).<br>
- Flatpak allows to complement your system with Linux applications of your choice for productivity, gaming, media creation...<br><br>

Plasma:<br><img alt="Plasma" src="https://github.com/sebanc/foxflake/blob/stable/installer/calamares-patches/config/images/plasma6.png?raw=true" width="480" height="270" /><br><br>
Gnome:<br><img alt="Gnome" src="https://github.com/sebanc/foxflake/blob/stable/installer/calamares-patches/config/images/gnome.png?raw=true" width="480" height="270" /><br><br>

## Installation

Download the installer iso from the releases section of this repository.<br><br>

## Features

The use of NixOS as a base guarantees the overall system stability and provides strong rollback capabilities through the generations mechanism. FoxFlake provides:<br>
- A comprehensive NixOS configuration, declared in this repository, that allows delegated management of maintenance tasks (NixOS options changes, package name changes...). All NixOS options are still available for users who want to customize their systems and supersede any FoxFlake default configuration.<br>
- The use of NixOS stable channel as a rolling release (the switch from one stable version to the next is automated).<br>
- Unattended daily updates of your system (for both NixOS system packages and system / user flatpaks).<br>
- NixOS community maintained modules home-manager, plasma-manager and nix-flatpak modules are included and allow to have a fully declarative configuration from system to user profiles.<br><br>

3 bundles of applications are proposed, they are all optional and respectively contain:<br>
- Standard bundle: Firefox, Thunderbird and LibreOffice.<br>
- Gaming bundle: Steam, Heroic and Lutris.<br>
- Studio bundle: OBS Studio, Blender, Kdenlive, GIMP, Audacity.<br><br>

As such, there are 2 possible usages with FoxFlake:<br>
- Zero maintenance mode: Install the system with the bundles of packages that correspond to your needs and complement them with flatpak applications.<br>
- Custom declarative configurations: FoxFlake will manage the main system configurations and you are only in charge of the maintenance of your custom configurations.<br><br>

## Complementary instructions:

### Installing the nvidia driver

For Nvidia GPU compatible with the latest open source or proprietary kernel modules, recommended drivers are automatically enabled during install.<br><br>

For older nvidia cards, you will need to follow the [NixOS nvidia instructions][NixOS-nvidia].<br><br>

### Changing desktop environment or application bundles after installation

The "FoxFlake Environment Selection" application allows you to review at any point in time the desktop environment and bundles choices you made.<br><br>

### Setting up android apps

It is highly recommended to use the "FoxFlake Waydroid setup" for the first time setup of Waydroid as it will detect your computer graphics and apply corresponding options.<br>
Once Waydroid is setup, you can use the "Waydroid helper" application to add complementary features (Magisk, Tweaks...).<br><br>

### Setting up the Home manager user environment

Home manager is installed by default, to initialize home manager for your user you need to run the command: `nix run home-manager -- init --switch`.<br>
You can then apply your user home manager configuration updates with the command: `nix run home-manager switch`.<br><br>

### Building the FoxFlake installer iso image

1. Install the nix package manager on your system according to the instructions at: https://nixos.org/download.<br>

2. Clone this repository:<br>
`git clone -b stable https://github.com/sebanc/foxflake.git`<br>

3. Enter the "installer" subfolder:<br>
`cd ./foxflake/installer`<br>

4. Update the installer flake lock:<br>
`nix --extra-experimental-features "nix-command flakes" flake update --flake .`<br>

5. Launch the build:<br>
`nix --extra-experimental-features "nix-command flakes" build .#installer`<br><br>

The generated installer iso image will be located in the "result/iso" folder.

## Thanks goes to:
- [NixOS][NixOS] and community modules (home-manager, plasma-manager and nix-flatpak) maintainers.<br>
- The Gaming Linux France community for the inspiration coming from their [gaming oriented GLF OS][GLF-OS].<br><br>


<!-- Reference Links -->
<!-- Badges -->
[license-shield]: https://img.shields.io/github/license/sebanc/foxflake?label=License&logo=Github&style=flat-square
[license-url]: ./LICENSE
[issues-shield]: https://img.shields.io/github/issues/sebanc/foxflake?label=Issues&logo=Github&style=flat-square
[issues-url]: https://github.com/sebanc/foxflake/issues
[discord-shield]: https://img.shields.io/badge/Discord-Join-7289da?style=flat-square&logo=discord&logoColor=%23FFFFFF
[discord-url]: https://discord.gg/x2EgK2M

<!-- Internal Links -->


<!-- Outbound Links -->
[NixOS]: https://nixos.org/
[NixOS-nvidia]: https://nixos.wiki/wiki/Nvidia
[GLF-OS]: https://github.com/Gaming-Linux-FR/GLF-OS


