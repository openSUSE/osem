# Payments through Stripe
Here you will find all the information that you need to setup your Stripe account and integrate it into OSEM.
If you experience any problems, don't hesitate to [contact us](https://github.com/openSUSE/osem#contact)

**To enable payments, you need to add the API keys, provided by Stripe, in OSEM.**

## Add Stripe credentials
To integrate Stripe into OSEM, all you need to do is add the *publishable* and *secret* keys into the Rails environment.

1. Register with Stripe [here](https://dashboard.stripe.com/register) and get your API keys for free

2. Add your Stripe API keys in the following variables of your `.env` file:

  * For **development**  
    * `STRIPE_PUBLISHABLE_KEY = 'pk_**test**_random123example456'`  
    * `STRIPE_SECRET_KEY = 'sk_**test**_random123example456'`  

    In development mode, the Stripe integration is useful for feature testing purposes. However, if you wish to enable payments for users, you need to use the live API keys.

  *  For **production**

    * `STRIPE_PUBLISHABLE_KEY = 'pk_**live**_random123example456'`  

    * `STRIPE_SECRET_KEY = 'sk_**live**_random123example456'`  

3. You are ready to start accepting payments from users

## Feature tests in development mode
You can test the payment feature in development mode using test credit cards; check out the list [here](https://stripe.com/docs/testing#cards).

### PCI Self Assessment Questionnaire(SAQ)
> As long as you serve your payment pages over TLS, and use either Checkout or Stripe.js
> as the only way of handling card information, Stripe automatically creates a prefilled SAQ A questionnaire for you,
> and you won’t need to undergo a PCI audit. If card data is stored or transferred through your servers,
> you are responsible for following PCI DSS guidelines for handling card data, and periodic audits by a PCI-certified auditor.

As we are using Stripe Checkout for accepting payments, Stripe will help you for filling SAQ for your application.
You can read the full security documentation [here](https://stripe.com/docs/security).

## Configure Stripe to send emails for successful transactions
Stripe can send email reciepts for every successful payment done through its gateway.
Please refer [here](https://dashboard.stripe.com/account/emails) to enable invoice emails for your users.

## Customize Stripe invoice emails for your application
You can customise your payment reciepts by adding your personalisation like organisation name, logo etc.
Please see the options for invoice personalisation [here](https://dashboard.stripe.com/account/public).
