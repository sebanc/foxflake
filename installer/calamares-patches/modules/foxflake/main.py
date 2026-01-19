#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
#   SPDX-FileCopyrightText: 2022 Victor Fuentes <vmfuentes64@gmail.com>
#   SPDX-FileCopyrightText: 2019 Adriaan de Groot <groot@kde.org>
#   SPDX-License-Identifier: GPL-3.0-or-later
#
#   Calamares is Free Software: see the License-Identifier above.
# ------------------------------------------------------------------------------

import libcalamares
import os
import subprocess
import re
import tempfile

import gettext

_ = gettext.translation(
    "calamares-python",
    localedir=libcalamares.utils.gettext_path(),
    languages=libcalamares.utils.gettext_languages(),
    fallback=True,
).gettext

# ====================================================
# Configuration.nix
# ====================================================

cfghead = """{ config, pkgs, lib, ... }:
{
  # Imports
  imports =
    [
      ./hardware-configuration.nix
    ];

"""

cfgenvironment = """
  # Desktop environment type
  foxflake.environment.type = "@@environment@@";
  
"""

cfgautologin = """
  # Autologin
  foxflake.environment.autologinUser = "@@username@@";

"""

cfgsystem = """
  # Bundles, system packages, flatpaks and waydroid configuration
  foxflake.system.bundles = [ @@bundles@@ ];         # e.g.: "standard" and/or "gaming" and/or "studio"
  foxflake.system.packages = with pkgs; [ ];         # e.g.: with pkgs; [ firefox ]
  foxflake.system.flatpaks = [ ];                    # e.g.: [ "org.mozilla.firefox" ];
  foxflake.system.waydroid = @@waydroid@@;

"""

cfgusers = """
  # User configuration (including user packages and flatpaks)
  foxflake.users.@@username@@.description = "@@fullname@@";
  foxflake.users.@@username@@.extraGroups = [ @@groups@@ ];
  foxflake.users.@@username@@.packages = with pkgs; [ ];         # e.g.: with pkgs; [ firefox ]
  foxflake.users.@@username@@.flatpaks = [ ];                    # e.g.: [ "org.mozilla.firefox" ];

"""

cfg_nvidia_open = """
  # Nvidia open source driver support
  foxflake.nvidia.enable = true;

"""

cfgkeymap = """
  # Keyboard configuration
  foxflake.internationalisation.keyboard.layout = "@@kblayout@@";
  foxflake.internationalisation.keyboard.variant = "@@kbvariant@@";
"""
cfgconsole = """  foxflake.internationalisation.keyboard.consoleKeymap = "@@vconsole@@";

"""

cfglocale = """
  # Locale configuration
  foxflake.internationalisation.defaultLocale = "@@LANG@@";
"""

cfglocaleextra = """  foxflake.internationalisation.extraLocaleSettings = {
    LC_ADDRESS = "@@LC_ADDRESS@@";
    LC_IDENTIFICATION = "@@LC_IDENTIFICATION@@";
    LC_MEASUREMENT = "@@LC_MEASUREMENT@@";
    LC_MONETARY = "@@LC_MONETARY@@";
    LC_NAME = "@@LC_NAME@@";
    LC_NUMERIC = "@@LC_NUMERIC@@";
    LC_PAPER = "@@LC_PAPER@@";
    LC_TELEPHONE = "@@LC_TELEPHONE@@";
    LC_TIME = "@@LC_TIME@@";
  };

"""

cfgtime = """
  # Timezone configuration
  foxflake.internationalisation.timezone = "@@timezone@@";

"""

cfgbootefi = """
  # Bootloader configuration
  foxflake.boot.efiSupport = true;
  foxflake.boot.device = "nodev";

"""

cfgbootbios = """
  # Bootloader configuration
  foxflake.boot.efiSupport = false;
  foxflake.boot.device = "@@bootdev@@";

"""

cfgbootnone = """
  # Bootloader configuration
  foxflake.boot.enable = false;

"""

cfgbootgrubcrypt = """
  # Encryption configuration
  foxflake.boot.encryption = true;
  foxflake.boot.encryptionSecrets = { "/boot/crypto_keyfile.bin" = null; };

"""

cfgtail = """ 
  # Initially installed version (DO NOT TOUCH)
  foxflake.stateVersion = "@@nixosversion@@";
}
"""

# =================================================
# Required functions
# =================================================

def env_is_set(name):
    envValue = os.environ.get(name)
    return not (envValue is None or envValue == "")

def generateProxyStrings():
    proxyEnv = []
    if env_is_set('http_proxy'):
        proxyEnv.append('http_proxy={}'.format(os.environ.get('http_proxy')))
    if env_is_set('https_proxy'):
        proxyEnv.append('https_proxy={}'.format(os.environ.get('https_proxy')))
    if env_is_set('HTTP_PROXY'):
        proxyEnv.append('HTTP_PROXY={}'.format(os.environ.get('HTTP_PROXY')))
    if env_is_set('HTTPS_PROXY'):
        proxyEnv.append('HTTPS_PROXY={}'.format(os.environ.get('HTTPS_PROXY')))

    if len(proxyEnv) > 0:
        proxyEnv.insert(0, "env")

    return proxyEnv

def pretty_name():
    return _("Installing FoxFlake.")

status = pretty_name()

def pretty_status_message():
    return status

def catenate(d, key, *values):
    """
    Sets @p d[key] to the string-concatenation of @p values
    if none of the values are None.
    This can be used to set keys conditionally based on
    the values being found.
    """
    if [v for v in values if v is None]:
        return

    d[key] = "".join(values)

def detect_nvidia():
    result = subprocess.run(['sudo', 'bash', '-c', 'lspci | grep "VGA compatible controller:\|3D controller:"'], stdout=subprocess.PIPE, text=True)
    lspci_output = result.stdout.strip()
    if "RTX 50" in lspci_output or "RTX 40" in lspci_output or "RTX 30" in lspci_output or "RTX 20" in lspci_output or "GTX 16" in lspci_output:
        nvidia_driver = "open"
    else:
        nvidia_driver = ""
    return nvidia_driver

# ==================================================================================================
# Configuration
# ==================================================================================================

## Execution start here
def run():
    """NixOS Configuration."""

    global status
    status = _("Configuring FoxFlake")
    libcalamares.job.setprogress(0.1)

    # Create initial config file
    cfg = cfghead
    gs = libcalamares.globalstorage
    variables = dict()

    # Setup variables
    root_mount_point = gs.value("rootMountPoint")
    dest_dir = os.path.join(root_mount_point, "etc/nixos/")
    config = os.path.join(dest_dir, "configuration.nix")
    fw_type = gs.value("firmwareType")
    bootdev = (
        "nodev"
        if gs.value("bootLoader") is None
        else gs.value("bootLoader")["installPath"]
    )

    # Define desktop environment
    cfg += cfgenvironment
    catenate(variables, "environment", gs.value("packagechooser_environment"))

    # Add autologin if needed
    if gs.value("autoLoginUser") is not None:
        cfg += cfgautologin

    cfg += cfgsystem
    catenate(variables, "bundles", gs.value("packagechooser_bundles"))
    if gs.value("packagechooser_waydroid") == "waydroid":
        catenate(variables, "waydroid", "true")
    else:
        catenate(variables, "waydroid", "false")

    # Setup user
    if gs.value("username") is not None:
        fullname = gs.value("fullname")
        groups = ["networkmanager", "wheel"]
        cfg += cfgusers
        catenate(variables, "username", gs.value("username"))
        catenate(variables, "fullname", fullname)
        catenate(variables, "groups", (" ").join(['"' + s + '"' for s in groups]))

    # Nvidia support
    nvidia_driver = detect_nvidia()
    if nvidia_driver == "open":
        cfg += cfg_nvidia_open

# ================================================================================
# Writing cfg modules to configuration.nix
# ================================================================================

    status = _("Configuring NixOS")
    libcalamares.job.setprogress(0.18)

    # Internationalisation properties
    if (
        gs.value("keyboardLayout") is not None
        and gs.value("keyboardVariant") is not None
    ):
        cfg += cfgkeymap
        catenate(variables, "kblayout", gs.value("keyboardLayout"))
        catenate(variables, "kbvariant", gs.value("keyboardVariant"))

        if gs.value("keyboardVConsoleKeymap") is not None:
            try:
                subprocess.check_output(
                    ["pkexec", "loadkeys", gs.value("keyboardVConsoleKeymap").strip()],
                    stderr=subprocess.STDOUT,
                )
                cfg += cfgconsole
                catenate(
                    variables, "vconsole", gs.value("keyboardVConsoleKeymap").strip()
                )
            except subprocess.CalledProcessError as e:
                libcalamares.utils.error("loadkeys: {}".format(e.output))
                libcalamares.utils.error(
                    "Setting vconsole keymap to {} will fail, using default".format(
                        gs.value("keyboardVConsoleKeymap").strip()
                    )
                )
        else:
            kbdmodelmap = open("/run/current-system/sw/share/systemd/kbd-model-map", "r")
            kbd = kbdmodelmap.readlines()
            out = []
            for line in kbd:
                if line.startswith("#"):
                    continue
                out.append(line.split())
            # Find rows with same layout
            find = []
            for row in out:
                if gs.value("keyboardLayout") == row[1]:
                    find.append(row)
            if find != []:
                vconsole = find[0][0]
            else:
                vconsole = ""
            if gs.value("keyboardVariant") is not None:
                variant = gs.value("keyboardVariant")
            else:
                variant = "-"
            # Find rows with same variant
            for row in find:
                if variant in row[3]:
                    vconsole = row[0]
                    break
                # If none found set to "us"
            if vconsole != "" and vconsole != "us" and vconsole is not None:
                try:
                    subprocess.check_output(
                        ["pkexec", "loadkeys", vconsole], stderr=subprocess.STDOUT
                    )
                    cfg += cfgconsole
                    catenate(variables, "vconsole", vconsole)
                except subprocess.CalledProcessError as e:
                    libcalamares.utils.error("loadkeys: {}".format(e.output))
                    libcalamares.utils.error("vconsole value: {}".format(vconsole))
                    libcalamares.utils.error(
                        "Setting vconsole keymap to {} will fail, using default".format(
                            gs.value("keyboardVConsoleKeymap")
                        )
                    )

    if gs.value("localeConf") is not None:
        localeconf = gs.value("localeConf")
        locale = localeconf.pop("LANG").split("/")[0]
        cfg += cfglocale
        catenate(variables, "LANG", locale)
        if (
            len(set(localeconf.values())) != 1
            or list(set(localeconf.values()))[0] != locale
        ):
            cfg += cfglocaleextra
            for conf in localeconf:
                catenate(variables, conf, localeconf.get(conf).split("/")[0])

    if gs.value("locationRegion") is not None and gs.value("locationZone") is not None:
        cfg += cfgtime
        catenate(
            variables,
            "timezone",
            gs.value("locationRegion"),
            "/",
            gs.value("locationZone"),
        )

# ================================================================================
# Bootloader
# ================================================================================

    # Check bootloader
    if fw_type == "efi":
        cfg += cfgbootefi
    elif bootdev != "nodev":
        cfg += cfgbootbios
        catenate(variables, "bootdev", bootdev)
    else:
        cfg += cfgbootnone

# ================================================================================
# Setup encrypted swap devices. nixos-generate-config doesn't seem to notice them.
# ================================================================================

    for part in gs.value("partitions"):
        if (
            part["claimed"] is True
            and (part["fsName"] == "luks" or part["fsName"] == "luks2")
            and part["device"] is not None
            and part["fs"] == "linuxswap"
        ):
            cfg += """  boot.initrd.luks.devices."{}".device = "/dev/disk/by-uuid/{}";\n""".format(part["luksMapperName"], part["uuid"])

    # Check partitions
    root_is_encrypted = False
    boot_is_encrypted = False
    boot_is_partition = False

    for part in gs.value("partitions"):
        if part["mountPoint"] == "/":
            root_is_encrypted = part["fsName"] in ["luks", "luks2"]
        elif part["mountPoint"] == "/boot":
            boot_is_partition = True
            boot_is_encrypted = part["fsName"] in ["luks", "luks2"]

    # Setup keys in /boot/crypto_keyfile if using BIOS and Grub cryptodisk
    if fw_type != "efi" and (
        (boot_is_partition and boot_is_encrypted)
        or (root_is_encrypted and not boot_is_partition)
    ):
        cfg += cfgbootgrubcrypt
        status = _("Setting up LUKS")
        libcalamares.job.setprogress(0.15)
        try:
            libcalamares.utils.host_env_process_output(
                ["mkdir", "-p", root_mount_point + "/boot"], None
            )
            libcalamares.utils.host_env_process_output(
                ["chmod", "0700", root_mount_point + "/boot"], None
            )
            # Create /boot/crypto_keyfile.bin
            libcalamares.utils.host_env_process_output(
                [
                    "dd",
                    "bs=512",
                    "count=4",
                    "if=/dev/random",
                    "of=" + root_mount_point + "/boot/crypto_keyfile.bin",
                    "iflag=fullblock",
                ],
                None,
            )
            libcalamares.utils.host_env_process_output(
                ["chmod", "600", root_mount_point + "/boot/crypto_keyfile.bin"], None
            )
        except subprocess.CalledProcessError:
            libcalamares.utils.error("Failed to create /boot/crypto_keyfile.bin")
            return (
                _("Failed to create /boot/crypto_keyfile.bin"),
                _("Check if you have enough free space on your partition."),
            )

        for part in gs.value("partitions"):
            if (
                part["claimed"] is True
                and (part["fsName"] == "luks" or part["fsName"] == "luks2")
                and part["device"] is not None
            ):
                cfg += """  boot.initrd.luks.devices."{}".keyFile = "/boot/crypto_keyfile.bin";\n""".format(
                    part["luksMapperName"]
                )
                try:
                    # Grub currently only supports pbkdf2 for luks2
                    libcalamares.utils.host_env_process_output(
                        [
                            "cryptsetup",
                            "luksConvertKey",
                            "--hash",
                            "sha256",
                            "--pbkdf",
                            "pbkdf2",
                            part["device"],
                        ],
                        None,
                        part["luksPassphrase"],
                    )
                    # Add luks drives to /boot/crypto_keyfile.bin
                    libcalamares.utils.host_env_process_output(
                        [
                            "cryptsetup",
                            "luksAddKey",
                            "--hash",
                            "sha256",
                            "--pbkdf",
                            "pbkdf2",
                            part["device"],
                            root_mount_point + "/boot/crypto_keyfile.bin",
                        ],
                        None,
                        part["luksPassphrase"],
                    )
                except subprocess.CalledProcessError:
                    libcalamares.utils.error(
                        "Failed to add {} to /boot/crypto_keyfile.bin".format(
                            part["luksMapperName"]
                        )
                    )
                    return (
                        _("cryptsetup failed"),
                        _(
                            "Failed to add {} to /boot/crypto_keyfile.bin".format(
                                part["luksMapperName"]
                            )
                        ),
                    )

    # ================================================================================
    # Finalize configuration.
    # ================================================================================

    # Set System version
    cfg += cfgtail
    version = ".".join(subprocess.getoutput(["nixos-version"]).split(".")[:2])[:5]
    catenate(variables, "nixosversion", version)

    # Check that all variables are used
    for key in variables.keys():
        pattern = "@@{key}@@".format(key=key)
        if pattern not in cfg:
            libcalamares.utils.warning("Variable '{key}' is not used.".format(key=key))

    # Check that all patterns exist
    variable_pattern = re.compile(r"@@\w+@@")
    for match in variable_pattern.finditer(cfg):
        variable_name = cfg[match.start() + 2 : match.end() - 2]
        if variable_name not in variables:
            libcalamares.utils.warning(
                "Variable '{key}' is used but not defined.".format(key=variable_name)
            )

    # Do the substitutions
    for key in variables.keys():
        pattern = "@@{key}@@".format(key=key)
        cfg = cfg.replace(pattern, str(variables[key]))

    status = _("Generating NixOS configuration")
    libcalamares.job.setprogress(0.25)

    try:
        # Generate hardware.nix with mounted swap device
        subprocess.check_output(
            ["pkexec", "nixos-generate-config", "--root", root_mount_point],
            stderr=subprocess.STDOUT,
        )
    except subprocess.CalledProcessError as e:
        if e.output is not None:
            libcalamares.utils.error(e.output.decode("utf8"))
        return (_("nixos-generate-config failed"), _(e.output.decode("utf8")))
 
    # Write the configuration.nix file
    libcalamares.utils.host_env_process_output(["cp", "/dev/stdin", config], None, cfg)

    subprocess.run(["sudo", "cp", "/iso/target-configuration/flake.nix", dest_dir], check=True)

    status = _("Installing NixOS")
    libcalamares.job.setprogress(0.3)

    # Flake lock update
    nixosFlakeUpdateCmd = [ 'pkexec' ]
    nixosFlakeUpdateCmd.extend(generateProxyStrings())
    nixosFlakeUpdateCmd.extend(
        [
            'nix',
            '--extra-experimental-features',
            '"nix-command flakes"',
            'flake',
            'update',
            '--flake',
            dest_dir
        ]
    )

    try:
        output = ""
        proc = subprocess.Popen(
            nixosFlakeUpdateCmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT
        )
        while True:
            line = proc.stdout.readline().decode("utf-8")
            output += line
            libcalamares.utils.debug("nix flake update: {}".format(line.strip()))
            if not line:
                break
        exit = proc.wait()
        if exit != 0:
            return (_("nix flake update failed"), _(output))
    except:
        return (_("nix flake update failed"), _("Installation failed to complete"))

    # Installation
    nixosInstallCmd = [ 'pkexec' ]
    nixosInstallCmd.extend(generateProxyStrings())
    nixosInstallCmd.extend(
        [
            'nixos-install',
            '--no-root-passwd',
            '--flake',
            f'{root_mount_point}/etc/nixos#foxflake',
            '--root',
            root_mount_point,
            "--option",
            "build-dir",
            "/nix/var/nix/builds",
            '--show-trace'
        ]
    )

    try:
        output = ""
        proc = subprocess.Popen(
            nixosInstallCmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT
        )
        while True:
            line = proc.stdout.readline().decode("utf-8")
            output += line
            libcalamares.utils.debug("nixos-install: {}".format(line.strip()))
            if not line:
                break
        exit = proc.wait()
        if exit != 0:
            return (_("nixos-install failed"), _(output))
    except:
        return (_("nixos-install failed"), _("Installation failed to complete"))

    # Set maximum EFI boot priority
    if fw_type == "efi":
        subprocess.run(['sudo', 'bash', '-c', 'efibootmgr -o $(efibootmgr | grep "FoxFlake-boot" | tail -1 | cut -d"*" -f1 | sed "s@Boot@@g")'], check=True)

    return None
