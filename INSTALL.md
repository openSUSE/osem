## Install OSEM
You can run rails apps in different modes (development, production). For more information
about rails and what it can do, see the [rails guides.](http://guides.rubyonrails.org/getting_started.html)

### Run OSEM in development
We are using [Vagrant](https://www.vagrantup.com/) to create our development environments.

1. Install [Vagrant](https://www.vagrantup.com/downloads.html) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads). Both tools support Linux, MacOS and Windows.

2. Install [vagrant-exec](https://github.com/p0deje/vagrant-exec):

    ```
    vagrant plugin install vagrant-exec
    vagrant plugin install vagrant-reload
    ```

3. Clone this code repository:

    ```
    git clone https://github.com/openSUSE/osem.git
    ```

4. Execute Vagrant:

    ```
    vagrant up
    ```

5. Start your OSEM rails app:

    ```
    vagrant exec rails server -b 0.0.0.0
    ```

6. Check out your OSEM rails app:
You can access the app [localhost:3000](http://localhost:3000). Whatever you change in your cloned repository will have effect in the development environment. Sign up, the first user will be automatically assigned the admin role.

7. Changed something? Test your changes!:

    ```
    vagrant exec rake test
    ```

8. Explore the development environment:

    ```
    vagrant ssh
    ```

9. Or issue any standard `rails`/`rake`/`bundler` command by prepending `vagrant exec`

    ```
    vagrant exec rake db:migrate
    ```
### Run OSEM in Docker containter using Docker Compose tool

1. Install [Docker](https://docs.docker.com/linux/step_one/) and [Docker-Compose](https://docs.docker.com/compose/install/). It is better run on Linux, but you can run it on MacOS or Windows with Docker-Machine. Don't forget to add your user to ```docker``` group.

2. Clone this code repository:

    ```
    git clone https://github.com/openSUSE/osem.git
    ```

3. Change current directory to OSEM project:

    ```
    cd osem/
    ```

4. Start building your OSEM rails app container:

    ```
    docker-compose build
    ```

5. Run your OSEM rails app container for the first time:

    ```
    docker-compose up
    ```

6. In another terminal change directory to your OSEM rails app and make a create db and make migrations:

    ```
    docker-compose run web rake db:create db:migrate
    ```

7. Press ```Ctrl-C``` in previous terminal to stop running container and start container again:

    ```
    docker-compose start
    ```

8. Check that new OSEM rails app container is running:

    ```
    docker-compose ps
    ```

9. Now you can look at browser by passing url ```http:\\localhost:8080\```. Stop container with

    ```
    docker-compose stop
    ```

**Note**: We use [letter_opener](https://github.com/ryanb/letter_opener) in development environment.
However, letter_opener uses launchy to present the emails in your browser which doesn't work in combination with Vagrant.
Therefore we use [letter_open_web](https://github.com/fgrehm/letter_opener_web).
You can check out your mails by visiting [localhost:3000/letter_opener](http://localhost:3000/letter_opener) if you use Vagrant.

### Run OSEM in production
We recommend to run OSEM in production with [mod_passenger](https://www.phusionpassenger.com/download/#open_source)
and the [apache web-server](https://www.apache.org/). There are tons of guides on how to deploy rails apps on various
base operating systems. Check Google ;-)

#### Use openID
In order to use the OpenID feature you need to register your application with the providers
(Google and Facebook) and enter their API keys in config/secrets.yml file, changing the existing sample values.

You can register as a developer with Google from https://code.google.com/apis/console#:access
You can register as a developer with Facebook from https://developers.facebook.com/,
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
