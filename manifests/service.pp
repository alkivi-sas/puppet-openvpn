class openvpn::service () {
    service { $openvpn::params::openvpn_service_name:
        ensure     => running,
        hasrestart => true,
        enable     => true,
    }
}
