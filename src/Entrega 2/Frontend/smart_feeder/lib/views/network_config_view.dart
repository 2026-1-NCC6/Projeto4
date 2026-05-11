import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import '../view_models/network_config_view_model.dart';

class NetworkConfigView extends StatefulWidget {
  const NetworkConfigView({super.key});

  @override
  State<NetworkConfigView> createState() => _NetworkConfigViewState();
}

class _NetworkConfigViewState extends State<NetworkConfigView> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NetworkConfigViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NETWORK SETUP'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark 
            ? const RadialGradient(
                center: Alignment(-0.8, -0.8),
                radius: 1.5,
                colors: [Color(0xFF121212), Color(0xFF080808)],
              )
            : const RadialGradient(
                center: Alignment(-0.8, -0.8),
                radius: 1.5,
                colors: [Color(0xFFF0F0F0), Color(0xFFE0E0E0)],
              ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(isDark),
                        const SizedBox(height: 32),
                        _buildInstructions(isDark),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _ssidController,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          decoration: const InputDecoration(
                            labelText: 'WIFI SSID',
                            prefixIcon: Icon(Icons.wifi, size: 20),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'ENTER WIFI NAME';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          decoration: const InputDecoration(
                            labelText: 'WIFI PASSWORD',
                            prefixIcon: Icon(Icons.lock_outline, size: 20),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'ENTER WIFI PASSWORD';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        if (viewModel.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Text(
                              viewModel.errorMessage!.toUpperCase(),
                              style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (viewModel.isSuccess)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 24.0),
                            child: Text(
                              'CONFIGURATION SENT SUCCESSFULLY!',
                              style: TextStyle(color: AppTheme.cyberGreen, fontSize: 11, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        _buildSubmitButton(viewModel),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cyberGreen.withValues(alpha: 0.1),
          ),
          child: const Icon(
            Icons.router,
            size: 64,
            color: AppTheme.cyberGreen,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'CONFIGURE DEVICE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INSTRUCTIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppTheme.cyberGreen,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '1. Connect your phone to the "SmartFeeder_Setup" Wi-Fi network.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Text(
            '2. Enter your home Wi-Fi details below.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Text(
            '3. Press "SEND CONFIGURATION" to update the device.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(NetworkConfigViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cyberGreen.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: viewModel.isLoading
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  await viewModel.configureNetwork(
                    _ssidController.text.trim(),
                    _passwordController.text,
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.cyberGreen,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
        ),
        child: viewModel.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              )
            : const Text('SEND CONFIGURATION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ),
    );
  }
}
