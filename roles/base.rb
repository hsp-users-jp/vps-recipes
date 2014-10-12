name        "base"
description "base configuration"

run_list    "recipe[base::yum]",
            "recipe[simple_iptables]",
            "recipe[ntp]",
            "recipe[nginx]",
            "recipe[php]",
            "recipe[php::fpm]",
            "recipe[php::module_mbstring]",
            "recipe[php::module_mysql]",
            "recipe[php::module_mcrypt]",
            "recipe[mysql::server]",
            "recipe[mysql::client]",
            "recipe[database::mysql]",
            "recipe[base::nginx]",
            "recipe[base::iptables]",
            "recipe[base::phpmyadmin]",
            "recipe[base::piwik]",
            "recipe[www-pkg.hsp-users.jp]"

default_attributes(
  "ntp" => {
    "servers" => ["ntp.nict.jp"],
    "restrictions" => ["default ignore",
                       "-6 default ignore",
                       "127.0.0.1",
                       "ntp.nict.jp kod nomodify notrap nopeer noquery"]
  },
  "php" => {
    "use_atomic_repo" => false,
    "mysql_module_edition_" => "mysql",
  },
  "mysql" => {
    "server_root_password" => "123456"
  },
  "phpmyadmin" => {
    "fpm" => "true",
    "home" => "/var/www/html/phpmyadmin",
    "socket" => "/var/run/php-fpm/phpmyadmin.php-fpm.sock",
    "mirror" => "http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin"
  },
  "ya-piwik" => {
    "home" => "/var/www/html/piwik",
    "fpm" => {
      "enable" => true,
      "socket" => "/var/run/php-fpm/piwik.php-fpm.sock"
    },
    "database" => {
      "pass" => "123456"
    },
    "root" => {
      "pass" => "0123456",
      "email" => "webmaster@sharkpp.net"
    }
  }
)
