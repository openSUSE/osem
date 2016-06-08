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

## Configure
There are a couple of environment variables you can set to configure OSEM.

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
| OSEM_GOOGLE_KEY/OSEM_GOOGLE_SECRET | *string*			| OMNIAUTH Developer Keys/Secrets for GOOGLE
| OSEM_FACEBOOK_KEY/OSEM_FACEBOOK_SECRET | *string*		| OMNIAUTH Developer Keys/Secrets for Facebook
| OSEM_GITHUB_KEY/OSEM_GITHUB_SECRET |*string*			| OMNIAUTH Developer Keys/Secrets for GitHub
| OSEM_SMTP_ADDRESS		| smtp.opensuse.org		| The smtp server to use
| OSEM_SMTP_PORT		| *int*				| The port on the smtp server
| OSEM_SMTP_USERNAME		| *string*			| The user for the smtp server
| OSEM_SMTP_PASSWORD		| *string*			| The password for the smtp server
| OSEM_SMTP_AUTHENTICATION	| plain, login or cram_md5      | The auth method for the smtp server
| OSEM_SMTP_DOMAIN		| opensuse.org			| The HELO domain for the smtp server
| CLOUDINARY_URL		| *sting*			| Configure your cloudinary.com cloud name and api key/secret

## Dependencies

### ImageMagick
We use [ImageMagick](http://imagemagick.org/) for image manipulation so it needs to be available in your installation.
If you would like to resize exisiting logos in your OSEM installation you can do so by running the following rake task:

```shell
$ bundle exec rake logo:reprocess
```

### openID
In order to use [openID](http://openid.net/) logins for your OSEM installation you need to register your application with the providers ([Google](https://code.google.com/apis/console#:access), [GitHub](https://github.com/settings/applications/new) or [Facebook](https://developers.facebook.com/)) and enter their API keys in `config/secrets.yml` file, changing the existing sample values.

## Recurring Jobs
=======
Open a separate terminal and go into the directory where the rails app is present, and type the following to start the delayed_jobs worker for sending email notifications.
```
bundle exec rake jobs:work
```
