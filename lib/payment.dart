import 'package:eduflex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentPage extends StatefulWidget {
  final String id;

  const PaymentPage({
    super.key,
    required this.id,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    if (newText.length > 4) {
      return oldValue;
    }

    String formattedText = newText;
    if (newText.length > 2) {
      formattedText = '${newText.substring(0, 2)}/${newText.substring(2)}';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class _PaymentPageState extends State<PaymentPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _cardNumber = '';
  String _name = '';
  String _expDate = '';
  String _ccv = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isProcessing = false;

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> _processPayment() async {
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Update the User_tbl_registredcourse table with payment details
      await supabase.from('User_tbl_registredcourse').update({
        'payment_date': DateTime.now().toIso8601String(),
        'registredcourse_status': 1,
      }).match({
        'user_id': userId,
        'classes_id': widget.id, // Use the string id passed from MyCoursesPage
      });

      return true;
    } catch (e) {
      print('Payment error: $e');
      return false;
    }
  }

  void _submitPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);
      _animationController.forward();

      bool paymentSuccess = await _processPayment();

      setState(() => _isProcessing = false);
      _animationController.reverse();

      if (paymentSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Payment successful!'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
        _formKey.currentState!.reset();
        setState(() {
          _cardNumber = '';
          _name = '';
          _expDate = '';
          _ccv = '';
        });
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PaymentConfirmationPage()),
          );
        });
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Payment Failed'),
            content: const Text('An error occurred while processing your payment.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Error'),
          content: const Text('Please check your payment details.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
    final cleaned = value.replaceAll('/', '');
    if (cleaned.length != 4) return value;
    return '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
  }

  bool _validateExpDate(String value) {
    final cleaned = value.replaceAll('/', '');
    if (cleaned.length != 4) return false;

    final month = int.tryParse(cleaned.substring(0, 2));
    final year = int.tryParse(cleaned.substring(2, 4));

    if (month == null || year == null || month < 1 || month > 12) return false;

    final now = DateTime.now();
    final currentYear = now.year % 100;
    final fullYear = year < currentYear ? 2100 + year : 2000 + year;
    final expDate = DateTime(fullYear, month);

    return expDate.isAfter(DateTime(now.year, now.month));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade200],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Pay for Course',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 5)],
                    ),
                  ),
                  centerTitle: true,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade900, Colors.blue.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardPreview(),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                label: 'Card Number',
                                hint: 'XXXX XXXX XXXX XXXX',
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
                                  setState(() => _cardNumber = _formatCardNumber(value));
                                },
                                initialValue: _cardNumber,
                                icon: Icons.credit_card,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                label: 'Cardholder Name',
                                hint: 'John Doe',
                                validator: (value) {
                                  if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z ]{3,15}$').hasMatch(value)) {
                                    return 'Enter a name (3-15 letters)';
                                  }
                                  return null;
                                },
                                onChanged: (value) => setState(() => _name = value),
                                initialValue: _name,
                                icon: Icons.person,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      label: 'Expiry Date',
                                      hint: 'MM/YY',
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(4),
                                        _ExpiryDateInputFormatter(),
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty || !_validateExpDate(value)) {
                                          return 'Invalid date';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) => setState(() => _expDate = value),
                                      initialValue: _expDate,
                                      icon: Icons.calendar_today,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildTextField(
                                      label: 'CCV',
                                      hint: '123',
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
                                      onChanged: (value) => setState(() => _ccv = value),
                                      initialValue: _ccv,
                                      icon: Icons.lock,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Amount',
                                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                                      ),
                                      Text(
                                        '\$99.99', // Replace with actual amount from database if needed
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: _isProcessing ? null : _submitPayment,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                      elevation: 8,
                                    ),
                                    child: _isProcessing
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.payment),
                                              SizedBox(width: 10),
                                              Text('Pay Now', style: TextStyle(fontSize: 18)),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildPaymentIcon(Icons.credit_card, Colors.blue.shade900, 'Visa'),
                          const SizedBox(width: 20),
                          _buildPaymentIcon(Icons.payment, Colors.red.shade700, 'MasterCard'),
                          const SizedBox(width: 20),
                          _buildPaymentIcon(Icons.account_balance_wallet, Colors.orange, 'UPI'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Course Payment",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                _cardNumber.startsWith('4') ? Icons.credit_card : Icons.payment,
                color: Colors.white,
                size: 30,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _cardNumber.isEmpty ? 'XXXX XXXX XXXX XXXX' : _cardNumber,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              letterSpacing: 2,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cardholder Name',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  Text(
                    _name.isEmpty ? 'YOUR NAME' : _name.toUpperCase(),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Expires',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  Text(
                    _expDate.isEmpty ? 'MM/YY' : _formatExpDate(_expDate),
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    String initialValue = '',
    IconData? icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.blue.shade900),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: Colors.blue.shade700) : null,
            filled: true,
            fillColor: Colors.blue.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          enabled: enabled,
        ),
      ],
    );
  }

  Widget _buildPaymentIcon(IconData icon, Color color, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, size: 30, color: color),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class PaymentConfirmationPage extends StatelessWidget {
  const PaymentConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade600, Colors.green.shade200],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 120, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Thank you for your purchase.',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Back to Courses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}