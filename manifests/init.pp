class openvpn (
  $motd = true,
) {
  if($motd)
  {
    motd::register{'OpenVPN Server': }
  }
  # declare all parameterized classes
  class { 'openvpn::params': }
  class { 'openvpn::install': }
  class { 'openvpn::config': }
  class { 'openvpn::service': }

  # declare relationships
  Class['openvpn::params'] ->
  Class['openvpn::install'] ->
  Class['openvpn::config'] ->
  Class['openvpn::service']

}

