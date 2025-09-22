import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:profile_app/core/constants/app_constants.dart';

class ProfileFormScreen extends StatefulWidget {
  final Profile? profile;

  const ProfileFormScreen({super.key, this.profile});

  @override
  _ProfileFormScreenState createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _imagePicker = ImagePicker();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  File? _selectedImage;
  bool _isLoading = false;

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

  Future<void> _pickImage() async {
    final permissionStatus = await Permission.camera.request();

    if (permissionStatus.isGranted) {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied to access gallery')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profile = Profile(
        id: widget.profile?.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );

      Profile savedProfile;
      if (widget.profile == null) {
        savedProfile = (await _apiService.createProfile(
          profile,
          _selectedImage,
        ))!;
      } else {
        savedProfile = await _apiService.updateProfile(profile, _selectedImage);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.profile == null
                ? 'Profile created successfully!'
                : 'Profile updated successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
          padding: EdgeInsets.all(16),
          children: [
            // Profile Image Section
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        image: _selectedImage != null
                            ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : widget.profile?.profileImage != null
                            ? DecorationImage(
                                image: NetworkImage(
                                  '${ApiConstants.baseUrl}/uploads/${widget.profile!.profileImage}',
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child:
                          _selectedImage == null &&
                              widget.profile?.profileImage == null
                          ? Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey[600],
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap to change photo',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Form Fields
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter first name' : null,
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter last name' : null,
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
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
            SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.profile == null
                            ? 'Create Profile'
                            : 'Update Profile',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
