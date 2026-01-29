import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/avatar_utils.dart';
import '../../../../core/utils/helpers.dart';

class AvatarSelectorOverlay extends StatefulWidget {
  const AvatarSelectorOverlay({super.key});

  @override
  State<AvatarSelectorOverlay> createState() => _AvatarSelectorOverlayState();
}

class _AvatarSelectorOverlayState extends State<AvatarSelectorOverlay> {
  String? _selectedAvatarId;

  @override
  void initState() {
    super.initState();
    // Pre-Select Current Avatar if it Exists
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _selectedAvatarId = auth.userData?['avatarId'];
  }

  // Save Avatar
  void _onSave() async {
    if (_selectedAvatarId == null) return;

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .updateAvatar(_selectedAvatarId!);
      if (mounted) {
        Navigator.pop(context);
        Helpers.showSnackBar(context, 'Avatar updated successfully!', isError: false);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to save avatar: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Avatar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                ),
                itemCount: AvatarUtils.avatars.length,
                itemBuilder: (context, index) {
                  final id = AvatarUtils.avatars.keys.elementAt(index);
                  final icon = AvatarUtils.avatars.values.elementAt(index);
                  final isSelected = _selectedAvatarId == id;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatarId = id;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFff7e5f).withOpacity(0.1)
                            : Colors.grey.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFff7e5f)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? const Color(0xFFff7e5f)
                            : const Color(0xFF666666),
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedAvatarId != null ? _onSave : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFff7e5f),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Avatar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}