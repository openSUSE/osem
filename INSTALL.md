# Install Open Source Event Manager

Here is what you need to install OSEM for production usage.

# 💥💥💥 WARNING 💥💥💥

![explosions](https://media.giphy.com/media/Yl5aO3gdVfsQ0/giphy.gif)

OSEM is a Ruby on Rails server application for professional use, not some desktop app you run for yourself. If you deploy it, **YOU** are responsible for the data that users enter into it, this data includes personal information like email addresses and/or passwords that most likely can be used to harm them in some form (cracking, doxing, social engineering).

If you never deployed a Ruby on Rails app before we **strongly** suggest you seek help from someone who has. That someone is **NOT** the OSEM team so please do **NOT** open an issue expecting us to explain how to do this.

*You should know what you do and you have been warned*.

## Versions

OSEM is an [semantic versioned](http://semver.org/) app. That means given a version number MAJOR.MINOR.PATCH we increment the:

1. MAJOR version when we make incompatible changes,
2. MINOR version when we add functionality in a backwards-compatible manner
3. PATCH version when we make backwards-compatible bug fixes

## Download

You can find the latest OSEM releases on our [release page](https://github.com/openSUSE/osem/releases)

## Deploy to the cloud

The easiest way to deploy OSEM is to use one of the many platform as a service providers that support ruby on rails. We have prepared OSEM to be used with [heroku](https://heroku.com). So if you have an account there, you can deploy OSEM by pressing this button:

<a href="https://heroku.com/deploy?template=https://github.com/openSUSE/osem/tree/v1.0">
  <img src="https://www.herokucdn.com/deploy/button.svg" alt="Deploy">
</a>

## Deploy to your own server

We recommend to run OSEM in production with [mod\_passenger](https://www.phusionpassenger.com/download/#open_source)
and the [apache web-server](https://www.apache.org/). There are tons of guides on how to deploy rails apps on various
base operating systems. [Check Google](https://encrypted.google.com/search?hl=en&q=ruby%20on%20rails%20apache%20passenger). Of course there are also other options for the application server and reverse proxy, pick your poison.

## Deploy via docker/docker-compose

There is a rudimentary docker-compose configuration for production usage (`docker-compose.yml.production-example`). It brings [OSEM up](http://0.0.0.0:8080) on port 8080. It uses persistent storage volumes for all the data users might create. You can start it with

1. Configure OSEM (at least `SECRET_KEY_BASE`)
   ```
   cp dotenv.example .env.production
   vim .env.production
   ```
1. Build the container image (every time you change code or config)
   ```
   docker-compose -f docker-compose.yml.production-example build
   ```
1. Setup the database (only once)
   ```
   docker-compose -f docker-compose.yml.production-example run --rm osem bundle exec rake db:bootstrap
   ```
1. Start the services
   ```
   docker-compose -f docker-compose.yml.production-example up
   ```

## Configuration
OSEM is configured through environment variables and falls back to sensible defaults. See the [dotenv.example](https://github.com/openSUSE/osem/blob/master/dotenv.example) for all possible configuration options. However here is a list of things you most likey want to configure because otherwise things will not work as expected.

### `SECRET_KEY_BASE`
A [random string](https://www.randomlists.com/string?base=16&length=64&qty=1) to encrypt sessions/cookies.

### `OSEM_NAME`
The name of your OSEM installation

### How to send emails
By default OSEM tries to send emails over localhost.

#### `OSEM_HOSTNAME`
The host this OSEM instance runs on. This is used for generating urls in emails sent.

#### `OSEM_EMAIL_ADDRESS`
The address OSEM uses to sending mails from.

#### `OSEM_SMTP_ADDRESS`
The mail server we send mail over. (*default*: localhost)

#### `OSEM_SMTP_AUTHENTICATION`
If your mail server requires authentication, you need to specify the authentication type here. This is a symbol and one of :plain (will send the password in the clear), :login (will send password Base64 encoded) or :cram_md5 (combines a Challenge/Response mechanism to exchange information and a cryptographic Message Digest 5 algorithm to hash important information)

#### `OSEM_SMTP_USERNAME`
If your mail server requires authentication, set the username in this setting.

#### `OSEM_SMTP_PASSWORD`
If your mail server requires authentication, set the password in this setting.
