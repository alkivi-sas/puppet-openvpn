class openvpn::client {
    include openvpn::params, openvpn::install, openvpn::client::config, openvpn::config, openvpn::service
}

