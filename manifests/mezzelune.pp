# This is the main puppet catalog for mezzelune. Running this will ensure
# all items under puppet control are executed. Individual items can be
# run by eg
#    puppet apply -e 'include postfix'

include apticron
include logrotate
include logwatch
include ntpd

class {'postfix':
  server_type  => 'satellite'
}

include pup_check
