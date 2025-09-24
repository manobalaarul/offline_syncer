import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:profile_app/features/presentation/bloc/profile/profile_bloc.dart';

import 'profile_form_screen.dart';

class ProfileListScreen extends StatefulWidget {
  const ProfileListScreen({super.key});

  @override
  _ProfileListScreenState createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profiles'),
        actions: [
          // IconButton(icon: Icon(Icons.refresh), onPressed: _loadProfiles),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state.errorMsg != null) {
            return Center(child: Text(state.errorMsg!));
          }

          if (state.profiles!.isEmpty) {
            return Center(
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
            );
          }

          return ListView.builder(
            itemCount: state.profiles!.length,
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final profile = state.profiles![index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  // leading: CircleAvatar(
                  //   maxRadius: 30,
                  //   backgroundImage: profile.profileImage != null
                  //       ? CachedNetworkImageProvider(
                  //           '${ApiConstants.baseUrl}/uploads/${profile.profileImage}',
                  //         )
                  //       : null,
                  //   child: profile.profileImage == null
                  //       ? Text(
                  //           '${profile.firstName[0]}${profile.lastName[0]}',
                  //           style: TextStyle(fontWeight: FontWeight.bold),
                  //         )
                  //       : null,
                  // ),
                  title: Text('${profile.firstName} ${profile.lastName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(profile.email), Text(profile.phone)],
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
                        // context.read<ProfileBloc>().add(
                        //   DeleteProfileEvent(profile.id),
                        // );
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
          );
        },
      ),
    );
  }
}
