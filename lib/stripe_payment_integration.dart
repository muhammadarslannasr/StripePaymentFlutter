import 'package:flutter/material.dart';
import 'package:flutter_first_project/services/payment-service.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'dart:convert';
import 'dart:io';

class StripePaymentIntegration extends StatefulWidget {

  @override
  _StripePaymentIntegrationState createState() => _StripePaymentIntegrationState();
}

class _StripePaymentIntegrationState extends State<StripePaymentIntegration> {

  Token? _paymentToken;
  PaymentMethod? _paymentMethod;
  String? _error;

  //this client secret is typically created by a backend system
  //check https://stripe.com/docs/payments/payment-intents#passing-to-client
  final String? _paymentIntentClientSecret = null;

  PaymentIntentResult? _paymentIntent;
  Source? _source;

  ScrollController _controller = ScrollController();

  final CreditCard testCard = CreditCard(
    number: '4000002760003184',
    expMonth: 12,
    expYear: 21,
  );

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  initState() {
    super.initState();

    StripeService.init();

    // StripePayment.setOptions(StripeOptions(
    //     publishableKey: "pk_test_51HjRhbJvxVAQkw4RhrOLga8HgntgQr5IDYGnPuvPU82NN8mazUyowKVm9T9H4xWu0L3w2ydmJbyxwWRtgsH55pOg00oMtG4TYK",
    //     merchantId: "Test",
    //     androidPayMode: 'test'));
  }

  void setError(dynamic error) {
    _scaffoldKey.currentState!
        .showSnackBar(SnackBar(content: Text(error.toString())));
    setState(() {
      _error = error.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('Plugin example app'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _source = null;
                _paymentIntent = null;
                _paymentMethod = null;
                _paymentToken = null;
              });
            },
          )
        ],
      ),
      body: ListView(

        children: [

          // RaisedButton(
          //   child: Text("Create Source"),
          //   onPressed: () {
          //     StripePayment.createSourceWithParams(SourceParams(
          //       type: 'ideal',
          //       amount: 1099,
          //       currency: 'eur',
          //       returnURL: 'example://stripe-redirect',
          //     )).then((source) {
          //       _scaffoldKey.currentState!.showSnackBar(
          //           SnackBar(content: Text('Received ${source.sourceId}')));
          //       setState(() {
          //         _source = source;
          //       });
          //     }).catchError(setError);
          //   },
          // ),
          // Divider(),
          RaisedButton(
            child: Text("Create Token with Card Form"),
            onPressed: () {

              payViaNewCard(context);
              // StripePayment.paymentRequestWithCardForm(
              //     CardFormPaymentRequest())
              //     .then((paymentMethod) {
              //       print('Credit Card number is: ${paymentMethod.card!.number}');
              //       print('Credit Card expiry month is: ${paymentMethod.card!.expMonth}');
              //       print('Credit Card expiry year is: ${paymentMethod.card!.expYear}');
              //
              //       // final CreditCard testCard = CreditCard(
              //       //   number: ,
              //       //   expMonth: paymentMethod.card!.expMonth,
              //       //   expYear: paymentMethod.card!.expYear,
              //       // );
              //
              //       StripePayment.createTokenWithCard(
              //         testCard,
              //       ).then((token) {
              //         _scaffoldKey.currentState!.showSnackBar(
              //             SnackBar(content: Text('Received ${token.tokenId}')));
              //         setState(() {
              //           _paymentToken = token;
              //         });
              //       }).catchError(setError);
              //
              //   // _scaffoldKey.currentState!.showSnackBar(
              //   //     SnackBar(content: Text('Received ${paymentMethod.card!.token}')));
              //   setState(() {
              //     _paymentMethod = paymentMethod;
              //   });
              // }).catchError(setError);
            },
          ),
          // RaisedButton(
          //   child: Text("Create Token with Card"),
          //   onPressed: () {
          //     StripePayment.createTokenWithCard(
          //       testCard,
          //     ).then((token) {
          //       _scaffoldKey.currentState!.showSnackBar(
          //           SnackBar(content: Text('Received ${token.tokenId}')));
          //       setState(() {
          //         _paymentToken = token;
          //       });
          //     }).catchError(setError);
          //   },
          // ),
          // Divider(),
          // RaisedButton(
          //   child: Text("Create Payment Method with Card"),
          //   onPressed: () {
          //     StripePayment.createPaymentMethod(
          //       PaymentMethodRequest(
          //         card: testCard,
          //       ),
          //     ).then((paymentMethod) {
          //       _scaffoldKey.currentState!.showSnackBar(
          //           SnackBar(content: Text('Received ${paymentMethod.id}')));
          //       setState(() {
          //         _paymentMethod = paymentMethod;
          //       });
          //     }).catchError(setError);
          //   },
          // ),
          // RaisedButton(
          //   child: Text("Create Payment Method with existing token"),
          //   onPressed: _paymentToken == null
          //       ? null
          //       : () {
          //     StripePayment.createPaymentMethod(
          //       PaymentMethodRequest(
          //         card: CreditCard(
          //           token: _paymentToken!.tokenId,
          //         ),
          //       ),
          //     ).then((paymentMethod) {
          //       _scaffoldKey.currentState!.showSnackBar(SnackBar(
          //           content: Text('Received ${paymentMethod.id}')));
          //       setState(() {
          //         _paymentMethod = paymentMethod;
          //       });
          //     }).catchError(setError);
          //   },
          // ),
          // Divider(),
          // RaisedButton(
          //   child: Text("Confirm Payment Intent"),
          //   onPressed:
          //   _paymentMethod == null || _paymentIntentClientSecret == null
          //       ? null
          //       : () {
          //     StripePayment.confirmPaymentIntent(
          //       PaymentIntent(
          //         clientSecret: _paymentIntentClientSecret,
          //         paymentMethodId: _paymentMethod!.id,
          //       ),
          //     ).then((paymentIntent) {
          //       _scaffoldKey.currentState!.showSnackBar(SnackBar(
          //           content: Text(
          //               'Received ${paymentIntent.paymentIntentId}')));
          //       setState(() {
          //         _paymentIntent = paymentIntent;
          //       });
          //     }).catchError(setError);
          //   },
          // ),
          // RaisedButton(
          //   child: Text(
          //     "Confirm Payment Intent with saving payment method",
          //     textAlign: TextAlign.center,
          //   ),
          //   onPressed:
          //   _paymentMethod == null || _paymentIntentClientSecret == null
          //       ? null
          //       : () {
          //     StripePayment.confirmPaymentIntent(
          //       PaymentIntent(
          //         clientSecret: _paymentIntentClientSecret,
          //         paymentMethodId: _paymentMethod!.id!,
          //         isSavingPaymentMethod: true,
          //       ),
          //     ).then((paymentIntent) {
          //       _scaffoldKey.currentState?.showSnackBar(SnackBar(
          //           content: Text(
          //               'Received ${paymentIntent.paymentIntentId}')));
          //       setState(() {
          //         _paymentIntent = paymentIntent;
          //       });
          //     }).catchError(setError);
          //   },
          // ),
          // RaisedButton(
          //   child: Text("Authenticate Payment Intent"),
          //   onPressed: _paymentIntentClientSecret == null
          //       ? null
          //       : () {
          //     StripePayment.authenticatePaymentIntent(
          //         clientSecret: _paymentIntentClientSecret!)
          //         .then((paymentIntent) {
          //       _scaffoldKey.currentState!.showSnackBar(SnackBar(
          //           content: Text(
          //               'Received ${paymentIntent.paymentIntentId}')));
          //       setState(() {
          //         _paymentIntent = paymentIntent;
          //       });
          //     }).catchError(setError);
          //   },
          // ),
          // Divider(),
          // RaisedButton(
          //   child: Text("Native payment"),
          //   onPressed: () {
          //     if (Platform.isIOS) {
          //       _controller.jumpTo(450);
          //     }
          //     StripePayment.paymentRequestWithNativePay(
          //       androidPayOptions: AndroidPayPaymentRequest(
          //         totalPrice: "1.20",
          //         currencyCode: "EUR",
          //       ),
          //       applePayOptions: ApplePayPaymentOptions(
          //         countryCode: 'DE',
          //         currencyCode: 'EUR',
          //         items: [
          //           ApplePayItem(
          //             label: 'Test',
          //             amount: '13',
          //           )
          //         ],
          //       ),
          //     ).then((token) {
          //       setState(() {
          //         _scaffoldKey.currentState!.showSnackBar(
          //             SnackBar(content: Text('Received ${token.tokenId}')));
          //         _paymentToken = token;
          //       });
          //     }).catchError(setError);
          //   },
          // ),
          // RaisedButton(
          //   child: Text("Complete Native Payment"),
          //   onPressed: () {
          //     StripePayment.completeNativePayRequest().then((_) {
          //       _scaffoldKey.currentState!.showSnackBar(
          //           SnackBar(content: Text('Completed successfully')));
          //     }).catchError(setError);
          //   },
          // ),
          // Divider(),
          // Text('Current source:'),
          // Text(
          //   JsonEncoder.withIndent('  ').convert(_source?.toJson() ?? {}),
          //   style: TextStyle(fontFamily: "Monospace"),
          // ),
          // Divider(),
          // Text('Current token:'),
          // Text(
          //   JsonEncoder.withIndent('  ')
          //       .convert(_paymentToken?.toJson() ?? {}),
          //   style: TextStyle(fontFamily: "Monospace"),
          // ),
          // Divider(),
          // Text('Current payment method:'),
          // Text(
          //   JsonEncoder.withIndent('  ')
          //       .convert(_paymentMethod?.toJson() ?? {}),
          //   style: TextStyle(fontFamily: "Monospace"),
          // ),
          // Divider(),
          // Text('Current payment intent:'),
          // Text(
          //   JsonEncoder.withIndent('  ')
          //       .convert(_paymentIntent?.toJson() ?? {}),
          //   style: TextStyle(fontFamily: "Monospace"),
          // ),
          Divider(),
          Text('Current error: $_error'),


        ],

      ),
    );
  }

  payViaNewCard(BuildContext context) async {

    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(
        message: 'Please wait...'
    );
    await dialog.show();

    var response = await StripeService.payWithNewCard(
        amount: '15000',
        currency: 'USD'
    );
    await dialog.hide();
    print(response.message);
    Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          duration: new Duration(milliseconds: response.success == true ? 1200 : 3000),
        )
    );
  }

}
