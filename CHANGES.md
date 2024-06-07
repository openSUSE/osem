# Changes in OSEM 2.0

Not release yet...

## Update from 1.0

### Dropped travel information
We have dropped input and storage of travel schedules for event registrants. If
you would like to continue to collect travel schedules, please create a custom
survey for this purpose.
_Please be aware that existing travel data will be destroyed during migration._

### Multiple Schedules
A conference can have multiple schedules now so it's easier for organizers to
test schedules and collaborate on different versions.

For this some of the existing data needs to be changed. If you update
from 1.0 please run this rake task to move your old schedules to the
new system.

```
bundle exec rake data:move_events_attributes RAILS_ENV=production
```

### Dropped visit/campaign tracking
We have dropped the feature to track visits and campaigns (utm parameters)
inside OSEM. We recommend you use [matomo](https://matomo.org/) for things
like that. Before you update to OSEM 1.1 you should drop all the data we
have collected.

```
bundle exec rake data:drop_all_ahoy_events RAILS_ENV=production
```

### Conference wide revision history
There is now a conference wide revision history that will show organizers
everything that is happening. To be able to do this we need to change old
data.

```
bundle exec rake data:set_conference_in_versions RAILS_ENV=production
```

# Changes in OSEM 1.0

[Released May 24, 2016](https://osem.io/1.0)

Our first release after developing and using this app in production for
many years. Too many changes to list, see the release announcement to
learn what OSEM is about.

https://osem.io/1.0

## Update from master

### Configuration through the environment
If you have deployed OSEM from master before there is one thing you need to do
manually. OSEM is now configured through environment variables and not through
the config/options.yml anymore. There is a rake task to migrate your existing
data to a .env file that OSEM will use:

```
bundle exec rake data:migrate:config2dotenv RAILS_ENV=production
```
