import 'package:flutter/material.dart';
import 'package:sports_studio/core/theme/app_colors.dart';
import 'package:sports_studio/data/services/api_service.dart';
import 'package:sports_studio/presentation/screens/admin/add_edit_ground_screen.dart';

class ManageGroundsScreen extends StatefulWidget {
  const ManageGroundsScreen({super.key});

  @override
  State<ManageGroundsScreen> createState() => _ManageGroundsScreenState();
}

class _ManageGroundsScreenState extends State<ManageGroundsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _grounds = [];

  @override
  void initState() {
    super.initState();
    _fetchGrounds();
  }

  Future<void> _fetchGrounds() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final response = await _apiService.get('/grounds');
      final data = response.data['data'] as List;

      setState(() {
        _grounds = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Manage Grounds')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text('Error: $_errorMessage'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _grounds.length,
              itemBuilder: (context, index) {
                final g = _grounds[index];
                return Card(
                  color: AppColors.surface,
                  child: ListTile(
                    leading: g['main_image'] != null
                        ? Image.network(
                            g['main_image'],
                            width: 60,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.stadium_rounded,
                            color: AppColors.primary,
                          ),
                    title: Text(
                      g['name'] ?? 'Unknown',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      g['location'] ?? 'No Address',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditGroundScreen(ground: g),
                          ),
                        );
                        if (result == true) {
                          _fetchGrounds();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditGroundScreen()),
          );
          if (result == true) {
            _fetchGrounds();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
