define openvpn::server (
  $domain,
  $customer_long_name,
  $customer_fqdn,
  $vpn_network,
  $vpn_server_ip,
  $local_network,

  $dev_interfaces = 'tun1',
  $vpn_netmask    = '255.255.255.0',
  $local_netmask  = '255.255.255.0',

  $basedir        = '/etc/openvpn/alkivi',
  $openssl_config = '/etc/openvpn/alkivi/alkivi.cnf',
  $config         = '/etc/openvpn/server.conf',
  $clients_dir    = '/etc/openvpn/clients-conf',

  $tls_auth       = '/etc/openvpn/alkivi/ta.key',
  $dh             = '/etc/openvpn/alkivi/dh.pem',

  $database       = '/etc/openvpn/alkivi/index.txt',
  $serial         = '/etc/openvpn/alkivi/serial',
  $ca_cert        = '/etc/openvpn/alkivi/alkivi_ca.crt',
  $ca_key         = '/etc/openvpn/alkivi/alkivi_ca.key',
  $ca_crl         = '/etc/openvpn/alkivi/alkivi_crl.pem',

  $server_key     = '/etc/openvpn/alkivi/server.key',
  $server_cert    = '/etc/openvpn/alkivi/server.crt',

  $ca_expire      = 3650,
  $key_expire     = 3650,
  $key_size       = 2048,
) {

  # params check
  validate_string($domain)
  validate_string($customer_long_name)
  validate_string($customer_fqdn)
  validate_string($vpn_network)
  validate_string($vpn_netmask)
  validate_string($vpn_server_ip)
  validate_string($local_network)
  validate_string($local_netmask)
  validate_string($clients_dir)
  validate_string($tls_auth)
  validate_string($dh)

  $temp = split($ca_cert,'/')
  $short_ca_cert = $temp[-1]


  class { 'openvpn': }

  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
    notify => Service[$openvpn::params::openvpn_service_name],
  }

  Exec {
    path => ['/usr/bin', '/bin', '/usr/sbin', '/root/alkivi-scripts'],
  }

  ############################################
  # Helper
  ############################################
  file { '/root/alkivi-scripts/vpn-helper':
    mode    => '0700',
    content => template('openvpn/vpn-helper.erb'),
  }

  # symlink
  file { '/usr/bin/vpn-helper':
    ensure  => link,
    target  => '/root/alkivi-scripts/vpn-helper',
    require => File['/root/alkivi-scripts/vpn-helper'],
  }

  ############################################
  # Base config with CA
  ############################################

  # Base dir where to store keys
  file { $basedir:
    ensure  => directory,
    mode    => '0750',
    require => [ User['alkivi'], File['/usr/bin/vpn-helper'] ],
  }

  # database : put that only once
  file { $database:
    source  => 'puppet:///modules/openvpn/index.txt',
    replace => no,
    require => File[$basedir],
  }

  # serial : put that only once
  file { $serial:
    source  => 'puppet:///modules/openvpn/serial',
    replace => no,
    require => File[$database],
  }

  file { "${basedir}/sample.conf":
    content => template('openvpn/sample.conf.erb'),
    require => File[$basedir],
  }


  # general openssl config ...
  file { $openssl_config:
    content => template('openvpn/alkivi.cnf.erb'),
    require => File[$serial],
  }

  # create ca
  exec { "${basedir}/ca":
    command => "vpn-helper --initca --ca_expire ${ca_expire} --config ${openssl_config} --key_size ${key_size}",
    creates => $ca_key,
    require => File[$openssl_config],
  }

  # Fix permission
  file { $ca_key:
    mode    => '0600',
    require => Exec["${basedir}/ca"],
  }

  file { $ca_cert :
    mode    => '0644',
    require => Exec["${basedir}/ca"],
  }




  ############################################
  # Generate server certificate, only once :)
  ############################################

  exec { "${basedir}/server":
    command => "vpn-helper --server --key_expire ${key_expire} --config ${openssl_config} --key_size ${key_size}",
    creates => "${basedir}/server.key", # TODO make this a parameter ?
    require => [Exec["${basedir}/ca"], File['/usr/bin/vpn-helper']],
  }

  # Build Diffie-Hellman parameters for the server side
  exec { $dh:
    command => "vpn-helper --builddh --key_size ${key_size}",
    creates => $dh,
    require => File['/usr/bin/vpn-helper'],
  }

  file { $clients_dir:
    ensure => 'directory',
    mode   => '0750',
  }




  ############################################
  # Final touch for server conf
  ############################################

  file { $config:
    content => template('openvpn/server.conf.erb'),
    require => [ Exec["${basedir}/server"], Exec[$dh], File[$clients_dir] ],
  }


  ############################################
  # iptables
  ############################################
  file { '/etc/iptables.d/50-vpn.rules.ipv4':
    content => template('openvpn/vpn.rules.ipv4.erb'),
    require => Package['alkivi-iptables'],
    notify  => Service['alkivi-iptables'],
  }

  ############################################
  # sysctl for ipv4 foward
  ############################################
  sysctl { 'net.ipv4.ip_forward': value => '1' }



}

