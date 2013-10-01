class openvpn::install () {
    package { $openvpn::params::openvpn_package_name:
        ensure => installed,
    }
}
