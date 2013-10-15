# Bridge setup for wire-tapping

A simple bash script which creates a transparent bridge over two physical
network interfaces. If there is no switch available with a monitoring port,
a bridge on a portable system is a nice way to perform network analysis task.

## Running set-bridge

1. Insert your secondary network cards.
2. Check the name of your network interfaces (e.g. `ifconfig` or `ip addr show`
3. Edit the interface names in the script
4. Run the script as root
5. Start collecting data on **br0**.

## License
`set-bridge` is licensed under MIT, for more details check LICENSE.
