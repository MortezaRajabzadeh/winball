import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/models.dart';
import '../bloc/wallet/wallet_bloc.dart';
import '../configs/app_configs.dart';

class WalletSettingsScreen extends StatefulWidget {
  const WalletSettingsScreen({Key? key}) : super(key: key);

  @override
  State<WalletSettingsScreen> createState() => _WalletSettingsScreenState();
}

class _WalletSettingsScreenState extends State<WalletSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _seedPhraseController = TextEditingController();
  final _walletAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(LoadWalletInfo());
  }

  @override
  void dispose() {
    _seedPhraseController.dispose();
    _walletAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات کیف پول'),
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppConfigs.redColor,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'بستن',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          } else if (state is WalletLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('اطلاعات کیف پول با موفقیت ذخیره شد'),
                backgroundColor: AppConfigs.greenColor,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('در حال پردازش...'),
                ],
              ),
            );
          }

          // Update form fields if wallet info is loaded
          if (state is WalletLoaded) {
            _seedPhraseController.text = state.walletInfo.seedPhrase;
            _walletAddressController.text = state.walletInfo.walletAddress;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _seedPhraseController,
                    decoration: const InputDecoration(
                      labelText: '24 کلمه بازیابی',
                      hintText: 'کلمات را با فاصله از هم وارد کنید',
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لطفا کلمات بازیابی را وارد کنید';
                      }
                      final words = value.trim().split(' ');
                      if (words.length != 24) {
                        return 'باید دقیقا 24 کلمه وارد کنید';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _walletAddressController,
                    decoration: const InputDecoration(
                      labelText: 'آدرس کیف پول',
                      hintText: 'آدرس کیف پول را وارد کنید',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لطفا آدرس کیف پول را وارد کنید';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final walletInfo = WalletInfo(
                            seedPhrase: _seedPhraseController.text.trim(),
                            walletAddress: _walletAddressController.text.trim(),
                          );
                          context.read<WalletBloc>().add(SaveWalletInfo(walletInfo));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfigs.darkBlueButtonColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('ذخیره اطلاعات'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 