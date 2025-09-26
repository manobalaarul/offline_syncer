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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null ? 'Add Profile' : 'Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter first name' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter last name' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter email';
                }
                if (!value!.contains('@')) {
                  return 'Please enter valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: BlocConsumer<ProfileBloc, ProfileState>(
                listener: (context, state) {
                  if (state.status == ProfileStatus.loaded &&
                      state.successMsg != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.successMsg!),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context); // go back after success
                  } else if (state.status == ProfileStatus.error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMsg ?? "Error"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: () {
                      // if (_formKey.currentState!.validate()) {
                      final profile = Profile(
                        id: 7,
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
                        // context.read<ProfileBloc>().add(
                        //   UpdateProfileEvent(profile: profile),
                        // );
                      }
                      // }
                    },
                    child: state.status == ProfileStatus.loading
                        ? const CircularProgressIndicator(color: Colors.white)
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
