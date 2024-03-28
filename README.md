# MagicalProtection
Magisk-only completely systemless adblocking.

[![GitHub Latest Release (by date)](https://img.shields.io/github/v/release/programminghoch10/MagicalProtection?label=latest&logo=github&display_name=release)](https://github.com/programminghoch10/MagicalProtection/releases/latest)
[![GitHub Automatic Update Workflow Status](https://img.shields.io/github/actions/workflow/status/programminghoch10/MagicalProtection/autoupdate.yml?logo=github%20actions&logoColor=white&label=autoupdate)](https://github.com/programminghoch10/MagicalProtection/actions/workflows/autoupdate.yml) \
[![GitHub Global Download Counter](https://img.shields.io/github/downloads/programminghoch10/MagicalProtection/total?logo=github)](https://github.com/programminghoch10/MagicalProtection/releases)
[![GitHub Latest Download Counter](https://img.shields.io/github/downloads/programminghoch10/MagicalProtection/latest/total?logo=github)](https://github.com/programminghoch10/MagicalProtection/releases/latest) \
[![GitHub last commit](https://img.shields.io/github/last-commit/programminghoch10/MagicalProtection?logo=git&logoColor=white)](https://github.com/programminghoch10/MagicalProtection/commits/main)
[![GitHub Latest Release Date](https://img.shields.io/github/release-date/programminghoch10/MagicalProtection?logo=github)](https://github.com/programminghoch10/MagicalProtection/releases/latest) \
[![GitHub Build Workflow Status](https://img.shields.io/github/actions/workflow/status/programminghoch10/MagicalProtection/build.yml?logo=github%20actions&logoColor=white&label=build)](https://github.com/programminghoch10/MagicalProtection/actions/workflows/build.yml)
[![ShellCheck Status](https://img.shields.io/github/actions/workflow/status/programminghoch10/MagicalProtection/shellcheck.yml?logo=github%20actions&logoColor=white&label=shellcheck)](https://github.com/programminghoch10/MagicalProtection/actions/workflows/shellcheck.yml) \
[![GitHub Repo stars](https://img.shields.io/github/stars/programminghoch10/MagicalProtection?style=social)](https://github.com/programminghoch10/MagicalProtection/stargazers) \
[![GitHub followers](https://img.shields.io/github/followers/programminghoch10?style=social)](https://github.com/programminghoch10)

## Inspiration

I've been loving
[`EnergizedProtection`](https://github.com/EnergizedProtection)
and its simplicity of setting it up once
without an app and then forgetting about it.  
However, setting up the
[`EnergizedProtection Magisk Module`](https://github.com/Magisk-Modules-Repo/energizedprotection)
includes executing some shell commands
to download and install the preferred pack.
Additionally, 
their infrastructure was kinda flaky, 
the shellscripts weren't POSIX compliant 
and some other minor inconveniences...

So I've been envisioning a Magisk Module,
which simply can be installed and forgot about.
And with updates simply delivered
via the Magisk inbuilt module updater,
updating is an easy and straight forward process.

The name `MagicalProtection` is inspired by
Magisk's Magic Mount 
and _(obviously)_ by 
[`EnergizedProtection`](https://github.com/EnergizedProtection).

## Usage / Installation

To use this Magisk module, install it and reboot.  
There is nothing more to do, it will work straightaway.  
_Magisk's Systemless Hosts module is not required._

## Automatic Updates

[![GitHub Automatic Update Workflow Status](https://img.shields.io/github/actions/workflow/status/programminghoch10/MagicalProtection/autoupdate.yml?logo=github%20actions&logoColor=white&label=autoupdate)](https://github.com/programminghoch10/MagicalProtection/actions/workflows/autoupdate.yml)

Updates for this module and its hosts lists are 
[completely automated in GitHub Actions](https://github.com/programminghoch10/MagicalProtection/actions/workflows/autoupdate.yml).

To differentiate kinds of module updates, 
the version info contains two version numbers:  
The module version (`mv`) 
and the hosts version (`hv`).  
Both will tick up individually 
as updates for module and hosts are deployed.

## Blocklist Issues

This mod uses blocklists from other sources.
If you have an issue with the blocked domains, 
look at [the currently used blocklists](lists.txt)
and report the issue there.
