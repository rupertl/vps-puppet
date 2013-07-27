# This is the main puppet catalog for udon. Running this will ensure
# all items under puppet control are executed. Individual items can be
# run by eg
#    puppet apply -e 'include postfix'

include logrotate
include ntpd

include nginx
nginx::site {'www.rupert-lane.org':}
nginx::site {'qxnp.rupert-lane.org':}
nginx::site {'ttrss.rupert-lane.org':}

class {'postfix':
  server_type  => 'mailhost'
}

include logwatch
include radicale
include pup_check



