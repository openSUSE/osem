## Install OSEM
You can run rails apps in different modes (development, production). For more information
about rails and what it can do, see the [rails guides.](http://guides.rubyonrails.org/getting_started.html)

### Run OSEM in development
1. Clone the git repository to the directory you want Apache to serve the content from.

  ```
  git clone https://github.com/openSUSE/osem.git
  ```

2. Install all the ruby gems.

  ```
  bundle install
  ```

3. Install [ImageMagick](http://imagemagick.org/script/binary-releases.php)

4. Generate secret key for devise and the rails app with

  ```
  rake secret
  ```

5. Copy the sample configuration files and adapt them

  ```
  cp config/config.yml.example config/config.yml
  cp config/database.yml.example config/database.yml
  cp config/secrets.yml.example config/secrets.yml
  ```

6. Setup the database

  ```
  bundle exec rake db:setup
  ```

7. Run OSEM

  ```
  rails server
  ```

8. Visit the APP at

  ```
  http://localhost:3000
  ```
9. Sign up, the first user will be automatically assigned the admin role.

10. Hack!

### Run OSEM in production
We recommend to run OSEM in production with [mod_passenger](https://www.phusionpassenger.com/download/#open_source)
and the [apache web-server](https://www.apache.org/). There are tons of guides on how to deploy rails apps on various
base operating systems. Check Google ;-)

#### Use openID
In order to use the OpenID feature you need to register your application with the providers
(Google and Facebook) and enter their API keys in config/secrets.yml file, changing the existing sample values.

You can register as a devoloper with Google from https://code.google.com/apis/console#:access
You can register as a devoloper with Facebook from https://developers.facebook.com/,
by selecting from the top menu the option 'Apps' -> 'Create a New App'

Unless you add the key and secret for each provider, you will not be able to see the image that
redirects to the login page of the provider.

If you add a provider that does not require developers to register their application, you still need
to create two (2) variables, in config/secrets.yml
with the format of providername_key and providername_secret and add some sample text as their values.
Example:
myprovider_key = 'sample data'
myprovider_secret = 'sample data'

That is required so that the check in app/views/devise/shared/_openid.html.haml will pass and
the image-link to login using the provider will be shown.


#### Email Notifications
Open a separate terminal and go into the directory where the rails app is present, and type the following to start the delayed_jobs worker for sending email notifications.
```
rake jobs:work
```
