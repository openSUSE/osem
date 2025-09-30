[![Build Status](https://github.com/openSUSE/osem/actions/workflows/spec.yml/badge.svg?branch=master)](https://github.com/openSUSE/osem/actions)
[![Code Climate](https://codeclimate.com/github/openSUSE/osem.png)](https://codeclimate.com/github/openSUSE/osem)
[![codecov](https://codecov.io/gh/opensuse/osem/branch/master/graph/badge.svg)](https://codecov.io/gh/opensuse/osem)
[![Dependencies](https://badges.depfu.com/badges/8fcd630367d20f5b48d393774c00c5fd/overview.svg)](https://depfu.com/repos/openSUSE/osem)

# Open Source Event Manager - [osem.io](https://osem.io)
![OSEM Logo](doc/osem-logo.png)

An event management tool tailored to Free and Open Source Software conferences.

## Trial

Check out our demo at https://osem.copyleft.dev

## Installation
Please refer to our [installation guide](INSTALL.md).

## DEBUG MAIL ISSUES

If you're experiencing email delivery problems, use these commands to diagnose SMTP configuration issues.
For these tests, it supposes that you have a valid .env.production file in your home directory.

### Show current mail configuration
```bash
bundle exec rake mail:config
```

### Test SMTP connection and send test email
```bash
TEST_EMAIL_TO=your-email@example.com bundle exec rake mail:test
```

The test command will:
- Display your SMTP settings (with passwords hidden)
- Show detailed SMTP protocol conversation for debugging
- Attempt to send a test email
- Provide troubleshooting hints if delivery fails

**Common issues:**
- Authentication method mismatch (try `OSEM_SMTP_AUTHENTICATION=login` instead of `plain`)
- SSL certificate verification (try `OSEM_SMTP_OPENSSL_VERIFY_MODE=none` for testing)

### Using with devbox

If you're using [devbox](https://www.jetpack.io/devbox/docs/quickstart/) for development, prefix commands with `devbox run`:

```bash
devbox run bundle exec rake mail:config
devbox run TEST_EMAIL_TO=your-email@example.com bundle exec rake mail:test
```

## How to contribute to OSEM
Please refer to our [contributing guide](CONTRIBUTING.md).

## Contact
GitHub issues are the primary way for communicating about specific proposed changes to this project. If you have other questions feel free chat us up in the #osem channel on [libera.chat IRC](https://libera.chat).

https://web.libera.chat/#osem

