class openvpn::params {
  case $::operatingsystem {
    /(Ubuntu|Debian)/: {
      $openvpn_package_name    = 'openvpn'
      $openvpn_service_name    = 'openvpn'
      $openvpn_service_default = '/etc/default/openvpn'
    }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}

