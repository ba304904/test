package { 'ntp':
    provider => yum,
    ensure   => installed,
    enable   => true,
}
