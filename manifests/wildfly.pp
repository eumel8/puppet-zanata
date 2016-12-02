# Copyright 2014 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: zanata::wildfly
#
class zanata::wildfly(
  $wildfly_version = '9.0.1',
  $wildfly_install_source = 'https://repo1.maven.org/maven2/org/wildfly/wildfly-dist/9.0.1.Final/wildfly-dist-9.0.1.Final.tar.gz',
) {

  $javahome = '/usr/lib/jvm/default-java/jre/'

  package { 'default-jre-headless':
    ensure => present,
  }

  if ($::operatingsystem == 'Ubuntu') and ($::operatingsystemrelease >= '16.04') {
    # This is a hack to make sure that systemd is aware of the new service
    # before we attempt to start it.
    exec { 'wildfly-systemd-daemon-reload':
      command     => '/bin/systemctl daemon-reload',
      before      => Service['wildfly'],
      subscribe   => File['/etc/init.d/wildfly'],
      refreshonly => true,
    }
  }

  class { '::wildfly':
    version        => $wildfly_version,
    install_source => $wildfly_install_source,
    config         => 'standalone.xml',
    java_home      => $javahome,
    java_xmx       => '4096m',
    require        => Package['default-jre-headless'],
  }
}
