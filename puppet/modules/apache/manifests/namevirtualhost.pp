define apache::namevirtualhost {
  $addr_port = $name

  concat::fragment { "NameVirtualHost ${addr_port}":
    target  => $::apache::ports_file,
    content => template('apache/namevirtualhost.erb'),
  }
}
