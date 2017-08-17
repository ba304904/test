define apache::listen {
  $listen_addr_port = $name

  concat::fragment { "Listen ${listen_addr_port}":
    target  => $::apache::ports_file,
    content => template('apache/listen.erb'),
  }
}
