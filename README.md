puppet-find
===========

Tool to help locate (from a Puppet client) where a resource is defined and what it looks like.

Usage
=====

All you need to know is the 'title' of the resource you want to find. Output includes the place the resource
is defined in your manifests, and the resource in manifest form. 

For example:

    # pfind httpd
    =====================================================================================
    Items in Puppet catalog matching 'httpd':
    =====================================================================================
      Type:          Service
      Manifest file: /puppet/etc/modules/httpd_module/manifests/init.pp
      Line:          211
      Manifest code:
       service { 'httpd':
         ensure  => 'running',
         enable  => 'true',
         require => ['Package[httpd]', 'File[/etc/httpd/conf.d/ssl.conf]', 'File[/etc/httpd/conf/httpd.conf]', 'File[/etc/httpd/conf.d/welcome.conf]', 'Exec[make_docroot]', 'Exec[make_cgiroot]'],
         restart => '/usr/sbin/apachectl -t && /etc/init.d/httpd graceful',
       }
    -------------------------------------------------------------------------------------
      Type:          Exec
      Manifest file: /puppet/etc/modules/httpd_module/manifests/init.pp
      Line:          276
      Manifest code:
       exec { 'httpd':
         command     => '/etc/puppet/scripts/safe-restart-apache.sh',
         logoutput   => 'true',
         path        => '/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
         refreshonly => 'true',
         require     => 'File[/etc/puppet/scripts/safe-restart-apache.sh]',
       }
    -------------------------------------------------------------------------------------
      Type:          Package
      Manifest file: /puppet/etc/modules/httpd_module/manifests/init.pp
      Line:          126
      Manifest code:
       package { 'httpd':
         ensure => 'installed',
       }
    -------------------------------------------------------------------------------------

pfind located a Service, an Exec, and a Package with the title 'httpd'. The title for a File resource
is the full path, so you can locate where a file is defined like so:

    # pfind /etc/motd
    =====================================================================================
    Items in Puppet catalog matching '/etc/motd':
    =====================================================================================
      Type:          File
      Manifest file: /puppet/etc/modules/motd_module/manifests/init.pp
      Line:          26
      Manifest code:
       file { '/etc/motd':
         ensure  => 'present',
         content => '
       ------------------------------------------------------------------------
       ---                This machine is managed by Puppet                 ---
       ------------------------------------------------------------------------
    
       ',
         group   => 'root',
         mode    => '644',
         owner   => 'root',
       }
    -----------------------------------------------------------------------------------
