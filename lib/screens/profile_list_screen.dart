import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_syncer/offline_syncer.dart';

import '../features/presentation/bloc/profile/profile_bloc.dart';
import 'profile_form_screen.dart';

class ProfileListScreen extends StatefulWidget {
  const ProfileListScreen({super.key});

  @override
  _ProfileListScreenState createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  final OfflineSyncManager _offlineSync = OfflineSyncManager();

  @override
  void initState() {
    super.initState();
    // Trigger initial profile load
    Future.microtask(() {
      context.read<ProfileBloc>().add(GetProfileEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profiles'),
        actions: [
          Badge(
            label: FutureBuilder<int>(
              future: _offlineSync.getPendingCount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("...");
                }
                if (snapshot.hasError) {
                  return const Text("Error");
                }
                return Text("${snapshot.data ?? 0}");
              },
            ),
            child: IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _offlineSync.manualRetrySync();
                context.read<ProfileBloc>().add(GetProfileEvent());
              },
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileFormScreen()),
          );
          if (result != null) {
            context.read<ProfileBloc>().add(GetProfileEvent());
          }
        },
        child: Icon(Icons.add),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.deleteProfileStatus == DeleteProfileStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.deleteErrorMsg ?? 'Failed to delete'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.deleteProfileStatus == DeleteProfileStatus.loaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMsg!),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading &&
              (state.profiles == null || state.profiles!.isEmpty)) {
            return Center(child: CircularProgressIndicator());
          }

          if (state.profiles == null || state.profiles!.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileBloc>().add(GetProfileEvent());
              },
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No profiles found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap + to create a new profile',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileBloc>().add(GetProfileEvent());
            },
            child: ListView.builder(
              itemCount: state.profiles!.length,
              padding: EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final profile = state.profiles![index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text('${profile.firstName} ${profile.lastName}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.email),
                        if (profile.phone.isNotEmpty) Text(profile.phone),
                      ],
                    ),
                    isThreeLine: profile.phone.isNotEmpty,
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
                            context.read<ProfileBloc>().add(GetProfileEvent());
                          }
                        } else if (value == 'delete') {
                          // Show confirmation dialog
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Profile'),
                              content: Text(
                                'Are you sure you want to delete ${profile.firstName} ${profile.lastName}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            context.read<ProfileBloc>().add(
                              DeleteProfileEvent(id: profile.id),
                            );
                          }
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
          );
        },
      ),
    );
  }
}
