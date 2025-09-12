import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly_app/shared/shimmer_loading.dart';
import 'package:rewardly_app/widgets/custom_button.dart';
import 'package:rewardly_app/providers/user_data_provider.dart';
import 'package:rewardly_app/withdrawal_service.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  String _withdrawAmount = '';
  String _paymentMethod = 'PayPal'; // Default payment method
  bool _isLoading = false;
  final WithdrawalService _withdrawalService = WithdrawalService();
  final TextEditingController _paymentDetailsController = TextEditingController();

  @override
  void dispose() {
    _paymentDetailsController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submitWithdrawal() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final user = Provider.of<User?>(context, listen: false);
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('User not logged in.');
        return;
      }

      final int amount = int.parse(_withdrawAmount);

      String? error = await _withdrawalService.submitWithdrawal(
        uid: user.uid,
        amount: amount,
        paymentMethod: _paymentMethod,
        paymentDetails: _paymentDetailsController.text,
      );

      if (error != null) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar(error);
        return;
      }

      setState(() {
        _isLoading = false;
        _withdrawAmount = '';
      });
      _showSnackBar('Withdrawal request submitted for $amount coins via $_paymentMethod!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);

    if (user == null || userDataProvider.userData == null) {
      return const _WithdrawScreenLoading();
    }

    Map<String, dynamic> userData = userDataProvider.userData!.data() as Map<String, dynamic>;
    int currentCoins = userData['coins'] ?? 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo, Colors.blue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Withdraw Coins',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Available Coins: $currentCoins',
                      style: const TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount to Withdraw',
                        prefixIcon: Icon(Icons.money, color: Colors.indigo),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (int.tryParse(val) == null || int.parse(val) <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() => _withdrawAmount = val);
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _paymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        prefixIcon: Icon(Icons.payment, color: Colors.indigo),
                        border: OutlineInputBorder(),
                      ),
                      items: <String>['PayPal', 'Bank Transfer', 'Crypto']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _paymentMethod = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '$_paymentMethod Details (e.g., email, account number)',
                        prefixIcon: const Icon(Icons.info, color: Colors.indigo),
                        border: const OutlineInputBorder(),
                      ),
                      controller: _paymentDetailsController,
                      validator: (val) => val!.isEmpty ? 'Please enter payment details' : null,
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const ShimmerLoading.rectangular(height: 50)
                        : CustomButton(
                            text: 'Submit Withdrawal',
                            onPressed: _submitWithdrawal,
                            startColor: Colors.indigo,
                            endColor: Colors.blue,
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

class _WithdrawScreenLoading extends StatelessWidget {
  const _WithdrawScreenLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo, Colors.blue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ShimmerLoading.rectangular(height: 28, width: 200),
                  const SizedBox(height: 20),
                  const ShimmerLoading.rectangular(height: 18, width: 150),
                  const SizedBox(height: 20),
                  const ShimmerLoading.rectangular(height: 50),
                  const SizedBox(height: 20),
                  const ShimmerLoading.rectangular(height: 50),
                  const SizedBox(height: 20),
                  const ShimmerLoading.rectangular(height: 50),
                  const SizedBox(height: 20),
                  const ShimmerLoading.rectangular(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
