import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'profile_form_screen.dart';

class ProfileListScreen extends StatefulWidget {
  const ProfileListScreen({super.key});

  @override
  _ProfileListScreenState createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  final _apiService = ApiService();
  List<Profile> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      setState(() => _isLoading = true);
      final profiles = await _apiService.getProfiles();
      setState(() {
        _profiles = profiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profiles: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteProfile(Profile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Profile'),
        content: Text(
          'Are you sure you want to delete ${profile.firstName} ${profile.lastName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteProfile(profile.id!);
        _loadProfiles();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profiles'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadProfiles),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No profiles found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProfiles,
              child: ListView.builder(
                itemCount: _profiles.length,
                padding: EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final profile = _profiles[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profile.profileImage != null
                            ? CachedNetworkImageProvider(
                                '${ApiService.baseUrl}/uploads/${profile.profileImage}',
                              )
                            : null,
                        child: profile.profileImage == null
                            ? Text(
                                '${profile.firstName[0]}${profile.lastName[0]}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      title: Text('${profile.firstName} ${profile.lastName}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile.email),
                          if (profile.phone != null) Text(profile.phone!),
                        ],
                      ),
                      isThreeLine: profile.phone != null,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProfileFormScreen(profile: profile),
                              ),
                            );
                            if (result != null) {
                              _loadProfiles();
                            }
                          } else if (value == 'delete') {
                            _deleteProfile(profile);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
