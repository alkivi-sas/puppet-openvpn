# OpenVPN Module

This module will install and configure an openvpn server and/or openvpn client files

## Usage

### Server configuration

```puppet
openvpn::server { 'customer_vpn':
  vpn_network        => "192.168.1.0",
  vpn_server_ip      => "192.168.1.1",
  vpn_netmask        => "255.255.255.0',
  local_network      => "192.168.0.0",
  local_netmask      => "255.255.255.0",
  domain             => "mydomain.local",
  customer_long_name => "Alkivi Super Long Name",
  customer_fqdn      => "client.alkivi.fr",
}
```
This will do the typical install, configure and service management.
Class openvpn is automatically included, but need to change that.
Automatic forwarding from vpn to local network  is put in place using alkivi-iptables package and sysctl configuration

There is also a class alkivi_admin which create a vpn using puppet ssl keys


## Limitations

* This module has been tested on Debian Wheezy, Squeeze.

## License

All the code is freely distributable under the terms of the LGPLv3 license.

## Contact

Need help ? contact@alkivi.fr

## Support

Please log tickets and issues at our [Github](https://github.com/alkivi-sas/)
