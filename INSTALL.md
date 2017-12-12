# Install Open Source Event Manager
All the information that you need to install OSEM. If you have any problems with installing don't hesitate to [contact us](https://github.com/openSUSE/osem#contact)

## Versions
OSEM is an [semantic versioned](http://semver.org/) app. That means given a version number MAJOR.MINOR.PATCH we increment the:

1. MAJOR version when we make incompatible changes,
2. MINOR version when we add functionality in a backwards-compatible manner
3. PATCH version when we make backwards-compatible bug fixes

## Download
You can find the latest OSEM releases on our [release page](https://github.com/openSUSE/osem/releases/latest) ([older release here](https://github.com/openSUSE/osem/releases))


## Deploy

OSEM is a *Ruby on Rails* application. We recommend to run OSEM in production with [mod_passenger](https://www.phusionpassenger.com/download/#open_source)
and the [apache web-server](https://www.apache.org/). There are tons of guides on how to deploy rails apps on various
base operating systems. [Check Google](https://encrypted.google.com/search?hl=en&q=ruby%20on%20rails%20apache%20passenger) ;-)

For more information about rails and what it can do, see the [rails guides.](http://guides.rubyonrails.org/getting_started.html)

If you have an heroku account you can also

<a href="https://heroku.com/deploy?template=https://github.com/openSUSE/osem/tree/v1.0">
  <img src="https://www.herokucdn.com/deploy/button.svg" alt="Deploy">
</a>

### Deploy with Docker

You can deploy OSEM using [Docker](https://docker.com/) and [Docker-Compose](https://docs.docker.com/compose/overview/).

*This is just a short guide and does not explain how to use Docker and/or Docker-Compose. You need some experience with these tools to be able to deploy OSEM with Docker properly.*

First of all, copy `docker-compose.yml.example` to `docker-compose.yml` and `docker-compose.env.example` to `docker-compose.env`. You should immediately change
`docker-compose.env`'s permissions to `0600` to make sure all the passphrases in it are kept secret.
(Tip: the easiest and most secure way to do it is to do it with a single command, for example `install -m 0600 docker-compose.env.example docker-compose.env`).

There are two configurations to deploy OSEM with Docker: *evaluation mode* and *production mode*.

#### Evaluation mode

If you want to evaluate OSEM to see if it fits your needs, the default configuration in `docker-compose.env` will work perfectly fine for you.
For convenience reasons, `docker-compose.yml` already contains a [MailHog](https://github.com/mailhog/MailHog) service configuration. MailHog
is going to catch every email sent by OSEM and displays them on a special web service. Thus, it eliminates the need to set up an SMTP server just to try out OSEM.
Just point your browser to http://localhost:8025 to get access to registration confirmation links etc.

Run `docker-compose up --build` to start the services. On first run, it will take a few minutes to initialize the database. Thus, wait a few minutes before you open up
http://localhost:9292 in your browser.

#### Production mode

To deploy OSEM for production, you have to make a few changes to `docker-compose.yml`. First, remove (or comment) the `mailhog` service, as it is only useful for evaluation and
cannot be used for production.
You can change the forwarded port from port `9292` to any other value if this port is already in use or you just want to use another one.

Next, you have to modify `docker-compose.env`. This file works as a Docker-like replacement for the regular Rails `.env` files described below.
You can configure any of the configuration values shown in the **Configure** section below in it. The most essential variables are already configured to standard
values in `docker-compose.env` which you most likely want to change.

First, you need to modify the email related settings. You need a working SMTP server for OSEM to send out registration confirmation mails etc.

For security reasons, the following variables have to be changed, too:

  - `MYSQL_PASSWORD`
  - `MYSQL_ROOT_PASSWORD`
  - `SECRET_KEY_BASE`

These variables need to be set to the correct values at first, as they are used to initialize everything. Modification of these variables after installation and initialization is more
complicated and out of this document's scope.

As with any other Docker-Compose configuration, run `docker-compose up --build` (or `docker-compose up --build -d` to run in background) to start the services. During the first
start, the database has to be initialized which can take several minutes. The web service is by default exposed on localhost only as it is intended to be served by a reverse proxy (for SSL
termination, caching etc.).
You should not directly expose the web server port unless you have a good reason to do so.


## Configure
There are a couple of environment variables you can set to configure OSEM. Check out the *dotenv.example* file.

| Variable 			| Content 			| Purpose 				|
|----------			|---------			|---------	       			|
| OSEM_NAME   			| openSUSE Events		| The name of your page			|
| OSEM_HOSTNAME 		| events.opensuse.org		| The host this OSEM instance runs on 	|
| OSEM_EMAIL_ADDRESS 		| events@opensuse.org 		| The address OSEM uses for sending mails |
| OSEM_ICHAIN_ENABLED 		| true/false 			| Enable the usage of [devise_ichain_authenticatable](https://github.com/openSUSE/devise_ichain_authenticatable) |
| OSEM_TRANSIFEX_APIKEY 	| *string* 			| Use this api key for [transifex](https://www.transifex.com/). See TRANSLATION.md for details. |
| OSEM_ERRBIT_HOST 		| errbit.opensuse.org 		| The [errbit](https://github.com/errbit/errbit) host to post exceptions to |
| OSEM_ERRBIT_APIKEY 		| *string* 			| The api key for the errbit host |
| OSEM_FACTORY_LINT		| *boolean* (true/false)        | Setting this to false will disable linting of factories before running spec
| OSEM_GOOGLE_KEY | *string*			| OMNIAUTH Developer Key for GOOGLE
| OSEM_GOOGLE_SECRET | *string*			| OMNIAUTH Developer Secret for GOOGLE
| OSEM_FACEBOOK_KEY | *string*		| OMNIAUTH Developer Key for Facebook
| OSEM_FACEBOOK_SECRET | *string*		| OMNIAUTH Developer Secret for Facebook
| OSEM_GITHUB_KEY | *string*			| OMNIAUTH Developer Key for GitHub
| OSEM_GITHUB_SECRET | *string*			| OMNIAUTH Developer Secret for GitHub
| OSEM_SUSE_KEY | *string*			| OMNIAUTH Developer Key for openSUSE
| OSEM_SUSE_SECRET | *string*			| OMNIAUTH Developer Secret for openSUSE
| OSEM_SMTP_ADDRESS		| smtp.opensuse.org		| The smtp server to use
| OSEM_SMTP_PORT		| *int*				| The port on the smtp server
| OSEM_SMTP_USERNAME		| *string*			| The user for the smtp server
| OSEM_SMTP_PASSWORD		| *string*			| The password for the smtp server
| OSEM_SMTP_AUTHENTICATION	| plain, login or cram_md5      | The auth method for the smtp server
| OSEM_SMTP_DOMAIN		| opensuse.org			| The HELO domain for the smtp server
| CLOUDINARY_URL		| *string*			| Configure your cloudinary.com cloud name and api key/secret
| STRIPE_PUBLISHABLE_KEY    | *string*          | Publishable Key for Stripe Gateway
| STRIPE_SECRET_KEY    | *string*          | Secret Key for Stripe Gateway
| OSEM_REDIS_URL | *string* | Redis server URL e.g. redis://localhost:6379/1

### Online Ticket Payments
We use [Stripe](https://stripe.com) for accepting your ticket payments securely over the web.
Our application uses iFrame for accepting your user's payment details without storing them, making the application PCI SAQ-A Compliant.
Please refer to [PAYMENTS](PAYMENTS.md) documentation file for setting up your stripe account and start accepting payments from your users.

## Dependencies

### ImageMagick
We use [ImageMagick](http://imagemagick.org/) for image manipulation so it needs to be available in your installation.
If you would like to resize exisiting logos in your OSEM installation you can do so by running the following rake task:

```shell
$ bundle exec rake logo:reprocess
```

### openID
In order to use [openID](http://openid.net/) logins for your OSEM installation you need to register your application with the providers ([Google](https://code.google.com/apis/console#:access), [GitHub](https://github.com/settings/applications/new) or [Facebook](https://developers.facebook.com/)) and enter their API keys in the environment variables found in your *.env* file(s).

## Recurring Jobs
Open a separate terminal and go into the directory where the rails app is present, and type the following to start the delayed_jobs worker for sending email notifications.
```
bundle exec rake jobs:work
```
