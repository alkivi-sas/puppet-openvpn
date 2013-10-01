class openvpn::client::config {

  File {
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 0640,
    require => Class['openvpn::install'],
    notify  => Class['openvpn::service'],
  }

  file { '/etc/openvpn/client.conf' :
    content => template('openvpn/client.conf.erb')
  }
}
