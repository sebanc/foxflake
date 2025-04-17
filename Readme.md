<!-- Shields/Logos -->
[![License][license-shield]][license-url]
[![Issues][issues-shield]][issues-url]
[![Discord][discord-shield]][discord-url]

<h1 align="center">FoxFlake</h1>

## About this project

FoxFlake is a customized version of the NixOS Linux distribution (Flake) that aims to reproduce the best features of ChromeOS using Open Source Software (simple, very stable system and without any maintenance tasks needed) while providing native access to the full catalogue of Linux applications:  
- Plasma and Gnome desktop environments ensure simplicity of use and respectively provide KDE Connect / GSConnect for Phone integration with your Computer.  
- Firefox is proposed as default web browser (but is not imposed, the choice remains yours).  
- Optional installation of Waydroid for android apps integration.  
- Complement your system with Linux applications of your choice for productivity, gaming, media creation...  

The use of NixOS as a base guarantees the overall system stability and provides incredible rollback capabilities through the generations system. FoxFlake adds:  
- Its own configurations declared in this repository that allows delegated management of maintenance tasks (NixOS options changes, package name changes...). All NixOS configurations are still available for users who want to customize their systems and supersede any FoxFlake default configuration.  
- The use of NixOS stable channel as a rolling release (the switch from one stable version to the next is automated).  
- Unattended daily updates of your system (for both NixOS system packages and system / user flatpaks).  
- NixOS community maintained modules home-manager, plasma-manager and nix-flatpak modules are included for those interested in having a fully declarative configuration from system to user profiles.  

As such, there are 2 main usages with FoxFlake:  
- Zero maintenance mode: Install the system with the bundles of packages that correspond to your needs and complement them with flatpak applications.  
- Customized declarative configurations: FoxFlake will manage the main system configurations and you are only in charge of the maintenance of your customizations.  

The 3 bundles of applications included in FoxFlake are all optional and respectively contain:  
- Standard bundle: Firefox, Thunderbird and LibreOffice.  
- Gaming bundle: Steam, Heroic and Lutris.  
- Studio bundle: DaVinci Resolve, OBS Studio, Blender, Kdenlive, GIMP, Audacity.  

## Complementary instructions:

### Installing the nvidia driver

If you have a nvidia card supported by the latest nvidia open source driver, select the 2nd bootloader option (nvidia_driver) when booting the installer iso and the latest nvidia-open driver will be installed automatically.  
After install, you can add the line `foxflake.nvidia.enable = true;` to /etc/nixos/configuration.nix to enable the nvidia-open driver.  

For older nvidia card, you will need to follow the [NixOS nvidia instructions][NixOS-nvidia].  

### Changing desktop environment or application bundles after installation

The "FoxFlake Environment Selection" application allows you to review at any point in time the desktop environment and bundles choices you made.  

### Setting up android apps

It is highly recommended to use the "FoxFlake Waydroid setup" for the first time setup of Waydroid as it will detect your computer graphics and apply corresponding options.  
Once Waydroid is setup, you can use the "Waydroid helper" application to add complementary features (ARM translation tools, Tweaks...).  

### Setting up the Home manager user environment

Home manager is installed by default, to initialize home manager for your user you need to run the command: `nix run home-manager -- init --switch`.  
You can then apply your user home manager configuration updates with the command: `nix run home-manager switch`.  

## Thanks goes to:
- [NixOS][NixOS] and community modules (home-manager, plasma-manager and nix-flatpak) maintainers.  
- The Gaming Linux France community for the inspiration coming from their [gaming oriented GLF OS][GLF-OS].  


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


