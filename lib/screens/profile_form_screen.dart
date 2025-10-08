import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/data/remote/model/profile_model.dart';
import '../features/domain/entities/profile_entities.dart';
import '../features/presentation/bloc/profile/profile_bloc.dart';

class ProfileFormScreen extends StatefulWidget {
  final ProfileEntities? profile;

  const ProfileFormScreen({super.key, this.profile});

  @override
  _ProfileFormScreenState createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.profile?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.profile?.lastName ?? '',
    );
    _emailController = TextEditingController(text: widget.profile?.email ?? '');
    _phoneController = TextEditingController(text: widget.profile?.phone ?? '');
    _addressController = TextEditingController(
      text: widget.profile?.address ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String? _validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return '$fieldName must contain only letters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email';
    }
    final emailRegExp = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ); // basic email pattern
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter address';
    }
    if (value.trim().length < 5) {
      return 'Address must be at least 5 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null ? 'Add Profile' : 'Edit Profile'),
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.onUnfocus,
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // First Name
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => _validateName(value, "first name"),
            ),
            const SizedBox(height: 16),

            // Last Name
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => _validateName(value, "last name"),
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
            ),
            const SizedBox(height: 16),

            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: _validateAddress,
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: BlocConsumer<ProfileBloc, ProfileState>(
                listenWhen: (previous, current) =>
                    previous.createProfileStatus != current.createProfileStatus,
                listener: (context, state) {
                  if (state.createProfileStatus == CreateProfileStatus.loaded) {
                    _showSnackBar(
                      "Profile ${widget.profile == null ? 'created' : 'updated'} successfully ✅",
                      Colors.green,
                    );
                  }

                  if (state.createProfileStatus == CreateProfileStatus.error) {
                    _showSnackBar(
                      state.createErrorMsg ?? "Something went wrong ❌",
                      Colors.red,
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading =
                      state.createProfileStatus == CreateProfileStatus.loading;

                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              final profile = Profile(
                                id: widget.profile?.id ?? 0,
                                firstName: _firstNameController.text.trim(),
                                lastName: _lastNameController.text.trim(),
                                email: _emailController.text.trim(),
                                phone: _phoneController.text.trim(),
                                address: _addressController.text.trim(),
                              );

                              if (widget.profile == null) {
                                context.read<ProfileBloc>().add(
                                  CreateProfileEvent(profile: profile),
                                );
                              } else {
                                context.read<ProfileBloc>().add(
                                  CreateProfileEvent(profile: profile),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLoading ? Colors.grey : null,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : Text(
                            widget.profile == null
                                ? 'Create Profile'
                                : 'Update Profile',
                            style: const TextStyle(fontSize: 16),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
