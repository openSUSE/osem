# Integrate your Stripe account to accept your user's payments
Here you will find all the information that you need to setup your Stripe account into OSEM.
If you have any problems with installing don't hesitate to [contact us](https://github.com/openSUSE/osem#contact)

## Configure Stripe into the application
To configure Stripe into your application all you need to do is add the private and publishable keys into the Rails environment.
You can register to Stripe [here](https://dashboard.stripe.com/register) and get your API keys for free.
**You need to set the API keys provided by Stripe into the application first to get the feature running.**

Add your Stripe API keys in `.env` file into these variables:

If you are using the application in development mode your config should look like this:  
  `STRIPE_PUBLISHABLE_KEY = 'pk_**test**_random123example456'`  
  `STRIPE_SECRET_KEY = 'sk_**test**_random123example456'`  
The application in development mode can be used to test the whole test feature but is still not ready to be used by your users.
You need to use the live API keys to use the payment feature in production mode.

In production mode, it should look like:  
  `STRIPE_PUBLISHABLE_KEY = 'pk_**live**_random123example456'`  
  `STRIPE_SECRET_KEY = 'sk_**live**_random123example456'`  
In this mode, you can start accepting payments from your users.

## Testing feature in development mode
You can test the payment feature in development mode with some test cards.
Check out the list of test cards [here](https://stripe.com/docs/testing#cards).

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
