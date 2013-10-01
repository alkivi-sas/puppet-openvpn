class openvpn::config (
) {
  File {
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service[$openvpn::params::openvpn_service_name],
  }


  file {  $openvpn::params::openvpn_service_default:
    source  => 'puppet:///modules/openvpn/etc_default',
  }

}
