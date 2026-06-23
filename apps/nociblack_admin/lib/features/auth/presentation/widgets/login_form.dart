import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/auth_controller.dart';

/// Formulaire responsable de la saisie et de sa validation locale.
final class LoginForm extends StatefulWidget {
  const LoginForm({required this.controller, super.key});

  final AuthController controller;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

final class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final isAuthenticated = await widget.controller.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (isAuthenticated) {
      // Informe le gestionnaire d'autoremplissage Android que les identifiants
      // sont valides. Le système peut alors proposer leur enregistrement.
      TextInput.finishAutofillContext(shouldSave: true);
      return;
    }

    if (mounted) {
      // Après un refus, l'utilisateur revient directement à la fin du mot de
      // passe pour corriger une faute sans perdre le clavier ni sa saisie.
      _passwordFocusNode.requestFocus();
      _passwordController.selection = TextSelection.collapsed(
        offset: _passwordController.text.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, child) {
        return AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  key: const Key('login_email_field'),
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  readOnly: widget.controller.isSubmitting,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.email,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Adresse e-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('login_password_field'),
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  readOnly: widget.controller.isSubmitting,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Afficher le mot de passe'
                          : 'Masquer le mot de passe',
                      onPressed: () {
                        setState(
                          () => _obscurePassword = !_obscurePassword,
                        );
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                if (widget.controller.errorMessage case final message?) ...[
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      message,
                      key: const Key('login_error_message'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('login_submit_button'),
                  onPressed: widget.controller.isSubmitting ? null : _submit,
                  child: widget.controller.isSubmitting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Se connecter'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    final separatorIndex = email.indexOf('@');

    if (email.isEmpty) return 'L’adresse e-mail est obligatoire.';
    if (separatorIndex <= 0 || separatorIndex == email.length - 1) {
      return 'Saisissez une adresse e-mail valide.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est obligatoire.';
    }

    return null;
  }
}
