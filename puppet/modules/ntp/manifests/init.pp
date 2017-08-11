$ntp_server_suffix = ".ubuntu.pool.ntp.org"

file { '/etc/ntp.conf':
    content => template('ntp/ntp.conf.erb'),
    owner   => root,
    group   => root,
    mode    => 644,
}
