import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PaymentPage(),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  String _cardNumber = '';
  String _name = '';
  String _expDate = '';
  String _ccv = '';
  final double _total = 99.99; // Example total, replace with actual data

  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      // Simulate payment processing
      Future.delayed(const Duration(seconds: 1), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState!.reset();
        setState(() {
          _cardNumber = '';
          _name = '';
          _expDate = '';
          _ccv = '';
        });
      });
    } else {
      // Simulate "Not enough item" scenario from HTML
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Not enough item..!!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to cart page (replace with actual route)
                // Navigator.pushNamed(context, '/Customer/mycart/');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String _formatCardNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    final groups = <String>[];
    for (int i = 0; i < cleaned.length; i += 4) {
      groups.add(cleaned.substring(i, i + 4 > cleaned.length ? cleaned.length : i + 4));
    }
    return groups.join(' ');
  }

  String _formatExpDate(String value) {
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length > 2) {
      return '${cleaned.substring(0, 2)}/${cleaned.substring(2, cleaned.length > 4 ? 4 : cleaned.length)}';
    }
    return cleaned;
  }

  bool _validateExpDate(String value) {
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 4) return false;

    final month = int.tryParse(cleaned.substring(0, 2));
    final year = int.tryParse(cleaned.substring(2, 4));
    if (month == null || year == null || month < 1 || month > 12) return false;

    final now = DateTime.now();
    final currentYear = now.year % 100;
    final currentMonth = now.month;

    return year > currentYear || (year == currentYear && month >= currentMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300, // Matches HTML background
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 35,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.credit_card, size: 36, color: Colors.green),
                        const SizedBox(width: 10),
                        const Text(
                          'Pay',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          'ment',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Form Fields
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Column(
                        children: [
                          // Card Number
                          Row(
                            children: [
                              const Text('Card NO:'),
                              const SizedBox(width: 20),
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'XXXX XXXX XXXX XXXX',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      borderSide: const BorderSide(color: Colors.green),
                                    ),
                                    contentPadding: const EdgeInsets.all(10),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(16),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty || value.replaceAll(' ', '').length != 16) {
                                      return 'Enter a valid 16-digit card number';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _cardNumber = _formatCardNumber(value);
                                    });
                                  },
                                  controller: TextEditingController(text: _cardNumber),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Name
                          Row(
                            children: [
                              const Text('Name'),
                              const SizedBox(width: 20),
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'Name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      borderSide: const BorderSide(color: Colors.green),
                                    ),
                                    contentPadding: const EdgeInsets.all(10),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z ]{3,15}$').hasMatch(value)) {
                                      return 'Enter a name (3-15 letters)';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) => _name = value,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Exp Date and CCV
                          Row(
                            children: [
                              const Text('Exp Date'),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'XX/XX',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      borderSide: const BorderSide(color: Colors.green),
                                    ),
                                    contentPadding: const EdgeInsets.all(10),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty || !_validateExpDate(value)) {
                                      return 'Invalid date';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _expDate = _formatExpDate(value);
                                    });
                                  },
                                  controller: TextEditingController(text: _expDate),
                                ),
                              ),
                              const SizedBox(width: 20),
                              const Text('CCV'),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 60,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'XXX',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(11),
                                      borderSide: const BorderSide(color: Colors.green),
                                    ),
                                    contentPadding: const EdgeInsets.all(10),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty || value.length != 3) {
                                      return 'Enter a 3-digit CCV';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) => _ccv = value,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Total
                          Row(
                            children: [
                              const Text('Total'),
                              const SizedBox(width: 20),
                              Text(
                                '\$$_total',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Payment Button
                          ElevatedButton(
                            onPressed: _submitPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 103),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: const BorderSide(color: Colors.green),
                              ),
                              elevation: 0,
                            ).copyWith(
                              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                (states) {
                                  if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
                                    return Colors.green.withOpacity(0.7);
                                  }
                                  return null;
                                },
                              ),
                            ),
                            child: const Text(
                              'Make Payment',
                              style: TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Payment Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.credit_card, size: 48, color: Colors.black), // Visa-like
                        const SizedBox(width: 10),
                        Icon(Icons.payment, size: 48, color: Colors.red.shade700), // PayPal-like
                        const SizedBox(width: 10),
                        Icon(Icons.credit_card, size: 48, color: Colors.blue.shade900), // Mastercard-like
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}