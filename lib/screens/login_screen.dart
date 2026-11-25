import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:raitabazzar/l10n/app_localizations.dart';
import 'package:raitabazzar/provider/app_provider.dart';
import 'package:raitabazzar/screens/buyer_home_screen.dart';
import 'package:raitabazzar/screens/farmer_home_screen.dart';
import 'package:raitabazzar/services/weather_service.dart';
import 'package:raitabazzar/utils/constant.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();

  bool _isOtpSent = false;
  bool _needsProfileSetup = false;
  bool _isLoading = false;
  String _selectedDistrict = 'Mandya';

  String? _phoneError;
  String? _otpError;
  String? _nameError;

  static const String _mockOtp = '123456';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  void _handleSendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      setState(() {
        _phoneError = 'Please enter a valid 10-digit mobile number';
      });
      return;
    }

    setState(() {
      _phoneError = null;
      _isOtpSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification code sent to +91 $phone (Demo OTP: $_mockOtp)'),
        backgroundColor: AppConstants.primaryGreen,
      ),
    );
  }

  Future<void> _handleVerifyOtp(AppProvider appProvider) async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() {
        _otpError = 'Please enter the 6-digit verification code';
      });
      return;
    }

    if (otp != _mockOtp) {
      setState(() {
        _otpError = 'Invalid OTP. Please enter $_mockOtp for demo verification.';
      });
      return;
    }

    setState(() {
      _otpError = null;
      _isLoading = true;
    });

    final rawPhone = _phoneController.text.trim();
    final role = appProvider.selectedUser;
    final isNewUser = await appProvider.loginWithPhone(rawPhone, role);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (isNewUser) {
      setState(() => _needsProfileSetup = true);
      return;
    }

    _navigateToRoleHome(appProvider);
  }

  Future<void> _handleCompleteSetup(AppProvider appProvider) async {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      setState(() {
        _nameError = 'Please enter your name';
      });
      return;
    }

    setState(() {
      _nameError = null;
      _isLoading = true;
    });

    await appProvider.completeOnboarding(
      name: name,
      location: '$_selectedDistrict, Karnataka',
      business: _businessController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    _navigateToRoleHome(appProvider);
  }

  void _navigateToRoleHome(AppProvider appProvider) {
    if (appProvider.selectedUser == AppConstants.roleBuyer) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BuyerHomeScreen()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const FarmerHomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final appProvider = Provider.of<AppProvider>(context);
    final isFarmer = appProvider.selectedUser == AppConstants.roleFarmer;

    return Scaffold(
      appBar: AppBar(
        title: Text(_needsProfileSetup ? 'Quick Profile Setup' : loc.login),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Role Badge Indicator
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppConstants.lightGreenBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppConstants.primaryGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFarmer ? Icons.agriculture_rounded : Icons.storefront_rounded,
                        color: AppConstants.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isFarmer ? loc.roleFarmer : loc.roleBuyer,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.deepGreen,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Header Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: AppConstants.lightGreenBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _needsProfileSetup
                        ? Icons.person_add_alt_1_rounded
                        : _isOtpSent
                            ? Icons.mark_email_read_rounded
                            : Icons.phone_android_rounded,
                    size: 48,
                    color: AppConstants.primaryGreen,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (_needsProfileSetup) ...[
                Text(
                  isFarmer ? 'Welcome! Tell us about you' : 'Welcome! Setup Trader Profile',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'One-time setup for +91 ${_phoneController.text.trim()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 28),

                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: isFarmer ? 'Full Name / ನಿಮ್ಮ ಹೆಸರು *' : 'Buyer / Trade Name *',
                    prefixIcon: const Icon(Icons.person_outline, color: AppConstants.primaryGreen),
                    errorText: _nameError,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),

                if (!isFarmer) ...[
                  TextField(
                    controller: _businessController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Business Type (e.g. Wholesale / Retail)',
                      prefixIcon: const Icon(Icons.storefront_outlined, color: AppConstants.primaryGreen),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                DropdownButtonFormField<String>(
                  initialValue: _selectedDistrict,
                  decoration: InputDecoration(
                    labelText: 'District / ಜಿಲ್ಲೆ',
                    prefixIcon: const Icon(Icons.location_on_outlined, color: AppConstants.primaryGreen),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: WeatherService.supportedDistricts
                      .map((d) => DropdownMenuItem(value: d, child: Text('$d, Karnataka')))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDistrict = val);
                  },
                ),
                const SizedBox(height: 28),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleCompleteSetup(appProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            loc.continueButton,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ] else ...[
                Text(
                  _isOtpSent ? loc.enterOtp : loc.enterMobileNumber,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isOtpSent
                      ? '${loc.otpSentTo} ${_phoneController.text}'
                      : loc.mobileNumberSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 32),

                if (!_isOtpSent) ...[
                  // Phone Number Input Card
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _phoneError != null ? Colors.red : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.12),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '🇮🇳 +91',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: loc.phoneHint,
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_phoneError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _phoneError!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],

                  const SizedBox(height: 28),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _handleSendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        loc.sendOtp,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // OTP Input Field
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _otpError != null ? Colors.red : AppConstants.primaryGreen,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        counterText: '',
                        hintText: '• • • • • •',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 12,
                      ),
                    ),
                  ),

                  if (_otpError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _otpError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Resend OTP & Change Number Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text(loc.editMobile),
                        onPressed: () {
                          setState(() {
                            _isOtpSent = false;
                            _otpController.clear();
                            _otpError = null;
                          });
                        },
                      ),
                      TextButton(
                        child: Text(
                          loc.resendOtp,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('OTP Resent! (Demo OTP: $_mockOtp)')),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _handleVerifyOtp(appProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              loc.verifyOtp,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
