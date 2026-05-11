import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_feeder/core/theme/app_theme.dart';
import '../view_models/auth_view_model.dart';

class DeleteAccountView extends StatelessWidget {
  const DeleteAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DELETE ACCOUNT'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new, 
            size: 20, 
            color: isDark ? AppTheme.cyberGreen : Colors.black
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.redAccent),
                    const SizedBox(height: 24),
                    Text(
                      'ARE YOU SURE?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'THIS ACTION IS PERMANENT AND CANNOT BE UNDONE. ALL YOUR DATA WILL BE ERASED.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 48),
                    if (authViewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Text(
                          authViewModel.errorMessage!.toUpperCase(),
                          style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ElevatedButton(
                      onPressed: authViewModel.isLoading
                          ? null
                          : () async {
                              final confirm = await _showConfirmDialog(context);
                              if (confirm == true) {
                                final success = await authViewModel.deleteAccount();
                                if (success && context.mounted) {
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: authViewModel.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('DELETE MY ACCOUNT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('FINAL CONFIRMATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Do you really want to delete your account? This is your last chance to cancel.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
