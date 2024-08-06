# Systemd
## Introduction
In systemd, everything is a unit. Units can be services, mount points, devices, sockets, or timers.
Every service is put inside a dedicated control group (for process isolation and resource allocation) named after the service name.
A unit have:
- a type (service, mount, device, socket timer, target)
  [available unit types](https://docs.redhat.com/fr/documentation/red_hat_enterprise_linux/7/html/system_administrators_guide/chap-managing_services_with_systemd#sect-Managing_Services_with_systemd-Introduction)
- a state (static, generated, enabled, disabled, transient, masked, indirect)
- a status (eventually)
- a base-name (usually unique), combined with the type to produce the service name
- a description (eventually)

Common unit states are:
- static: cannot be enabled
- enabled: could be started automatically
- disabled: Can’t be started automatically but can be triggered from another unit
- masked: Can’t be enabled or triggered from another unit

Targets are groups of units.  Targets can build on top of another or depend on other targets.
At boot time, systemd activates the target `default.target` which is an alias for another target such as `graphical.target`.

Systemd uses dependencies and ordering to determine when it starts and stops units.
Dependencies can be soft (“Wants”) or hard (“Requires”).
Ordering is done with “After” and/or “Before”.
Without “After” or “Before”, services start at the same time which is likely to cause problems.

## Systemd System Services (Daemons)
Systemd commes with a bunch of services:
- systemd: the main systemd process (replaces /etc/initd)
- journald: event logging
- networkd: manages network configuration
- logind: manages user login
- udevd: manages devices
- resolved: manage DNS

All theses services are identified as `<service-name>.service`.

## Systemd User Sessions
When a user login a user session is launched: `systemd --user`. It behaves like
the system systemd (/etc/init) and is responsible for launching user-defined services.

When the user logout, the systemd user session is killed with all user services.

It may be interesting for a user to be able to run services when it is logged-off.
In that case you must use `loginctl enable-linger <user>`. The `user@.service` service
will be started at boot-time and will stay alive even if the user is not connected.

User services are stored in `~/.config/systemd/user`.

## Basic Usage
[see](https://www.accs.com/p_and_p/Systemd/Systemd.pdf)
* `systemctl`: display the status of all units that systemd has loaded.
* `systemctl status`: show system status
* `systemctl --failed`: list failed units
* `systemctl list-unit-files`: list installed unit files

Services control:
* `systemctl start <srv>`: activates service immediately (also: `service <srv> start`)
* `systemctl stop <srv>`: deactivates service immediately (also: `service <srv> stop`)
* `systemctl restart <srv>`: restarts service immediately (also `service <srv> restart`)
* `systemctl status <srv>`: shows status of service (also: `service <srv> status`)
* `systemctl enable <srv>`: enables service to be started on bootup
* `systemctl disable <srv>`: diables service to be started on bootup (but can be started with the `--now` option)
* `systemctl reload <unit>`: request the specified unit to reload its configuration file (also: `service <srv> reload`)
* `systemctl reboot`: reboot the system and come up to the default target.
  This is equivalent to the sysVinit command “init 6” or “shutdown -r”.
  See also `suspend` and `power` off commands.
* `systemctl reenable`: disable then enable the specified unit. The unit will not be stopped or started.
  This is used to reset the symbolic links to the defaults, as specified in the “[Install]” section of the unit.
  (“systemctl get-default” returns the current default target).
* `systemctl cat <unit>`: display the files for the specified unit.
* `systemctl edit <unit>`: bring up an editor on the specified unit. (Use“--full” to create a copy of the original file.)
* `systemctl isolate <target>`: stop all running units not specified for the target and start non‐running units that are specified for the target.
  This is equivalent to using the “init” command to change the runlevel with sysVinit.
* `systemctl set-default <target>`: set the specified target to be the default.
  When the system is booted, this is the target to which the system will be brought.

Unit files are stored in `/lib/systemd/system`.
Modified unit files should be stored in `/etc/systemd/system` (it will take precedence).

To debug a service either:
- enable debug on the service startup.
```
  [Service]
  Environment=SYSTEMD_LOG_LEVEL=debug
```
  This requires the service to be restarted:
```
  systemctl daemon-reload
  systemctl restart systemd-networkd
  journalctl -b -u systemd-networkd
```
- enable temporary debug for the service:
```
  systemctl service-log-level systemd-networkd.service debug
```
  No need to restart the service. To check the current log-level:
```
  systemctl service-log-level systemd-networkd.service
```

## Services
### Basic services control

afficher directement à la fin des logs

$ journalctl -xeu service-name

afficher les derniers logs en direct

$ journalctl -xefu service-name

editer le contenu d(un service systemd existant (très important, pour éviter d'écrire par dessus les services gérés par le système avec les )

$ systemctl edit service-name

afficher le contenu d(un service systemd (incluant aussi les modifications faites via edit, qui se retrouveront dans le dossier override.conf)

$ systemctl cat service-name

afficher les valeurs de toutes les variables associées à un service :

$ systemctl show service-name

afficher les variables d(environnement associées à un service :

$ systemctl show-environment service-name

après avoir créé ou modifié un service, il faut penser à lancer :

$ systemctl daemon-reload

affiche tous les emplacements de documentation pour trouver différentes informations

$ man 7 systemd.directives

affiche les dépendances d'un service

$ systemctl list-dependencies service-name

affiche les dépendances inverses d'un service

$ systemctl list-dependencies --reverse service-name

affiche les services qui ont pris le plus de temps à s'activer

systemd-analyze blame

affiche la chaine critique de démarrage du système, et mets en évidence qui est resté le plus longtemps sur le chemin critique de démarrage:

systemd-analyze critical-chain

créé un fichier .svg qui affiche graphiquement comment sont séquencés les services au démarrage et en combien de temps:

systemd-analyze plot

créé un fichier .svg qui affiche graphiquement les dépendences et reverses dépendances d'un service:

systemd-analyze dot "service-name.service" | dot  -Tx11

    Start the service_name service:

# systemctl start service_name

Stop the service_name service:

# systemctl stop service_name

Restart the service_name service:

# systemctl restart service_name

Reload service_name configuration without stopping the service_name service:

# systemctl reload service_name

Check the service_name service status:

# systemctl status service_name

Enable the service_name service on system boot:

# systemctl enable service_name

Disable the service_name service on system boot:

# systemctl disable service_name

Check if the service_name service is enable or disable on system boot:

    # systemctl is-enabled service_name

Inspect services¶

    Check if any SystemD services have entered in a failed state:

$ systemctl --failed

List SystemD services that have failed:

$ systemctl list-units --state=failed

- [Stephane cheat sheets](https://cheatsheets.stephane.plus/init-systems/systemd/)
- [Systemd Documentation](https://systemd.io/)
