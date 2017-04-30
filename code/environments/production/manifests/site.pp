# site.pp - main puppet catalog for all nodes.

# Running this with `puppet apply` will ensure all items under puppet
# control are executed.

# Determine what classes to configure on this host from hiera
lookup('classes', {merge => unique}).include
