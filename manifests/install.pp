define drush::install($version) {
  $parts = split($version, '[.]')
  $v = $parts[0]

  $drush = "drush${v}"
  $install_dir = "/opt/drush/${v}"

  file { $install_dir:
    ensure => directory,
  }
  composer::exec { "${drush}-install":
    packages    => ["drush/drush:${v}"],
    cmd         => 'require',
    #cwd         => '/tmp',
    dev         => false,
    global      => false,
    cwd         => $install_dir,
    notify      => Exec["${drush}-first-run"],
    require     => File[$install_dir],
  }

  # Symlink to drush executable.
  $drush_exec = "/usr/local/bin/${drush}"
  file { $drush_exec:
    ensure => link,
    target => "${install_dir}/vendor/bin/drush",
  }

  # Run drush after installation,
  # so it downloads non-composer based dependencies.
  # Only needed for $version <= 6
  exec { "${drush}-first-run":
    command => $drush_exec,
    refreshonly => true,
    require     => File[$drush_exec],
  }
}

