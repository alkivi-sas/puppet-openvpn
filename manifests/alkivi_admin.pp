define openvpn::alkivi_admin (
  $customer_fqdn,
  $dev_interface = 'tun0',
  $server        = 'admin.alkivi.fr',
  $port          = 1194,
) {

  # params check
  validate_string($customer_fqdn)
  validate_string($dev_interface)
  validate_string($server)
  validate_string($port)

  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
    notify => Class['openvpn::service']
  }


  ############################################
  # Final touch for server conf
  ############################################

  file { '/etc/openvpn/alkivi_admin.conf':
    content => template('openvpn/alkivi_admin.conf.erb'),
    require => Class['openvpn'],
  }

  file { '/etc/iptables.d/51-admin-vpn.rules':
    content => template('openvpn/admin-vpn.rules.erb'),
    require => Package['alkivi-iptables'],
    notify  => Service['alkivi-iptables'],
  }
}

