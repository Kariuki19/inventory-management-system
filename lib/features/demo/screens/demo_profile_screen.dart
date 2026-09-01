import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../help/screens/help_support_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/models/user_model.dart';
import '../../../core/providers/demo_mode_provider.dart';
import '../../../core/utils/consultation_utils.dart';
import '../../../screens/demo_exited_screen.dart';

/// A sandboxed stand-in for [ProfileScreen] used inside the interactive demo.
///
/// The real ProfileScreen calls AuthService/Firestore directly (edit profile,
/// change password, sign out, admin tools) with no demo-mode guard. Reusing
/// it here would let a demo visitor trigger real auth writes, or accidentally
/// sign a genuinely logged-in user out of their real account. This screen
/// shows the real anonymous user data and funnels every action toward sign-up.
class DemoProfileScreen extends StatelessWidget {
  const DemoProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = AuthService.currentUser;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor:
                            Theme.of(context).primaryColor.withValues(alpha: 0.15),
                        child: Text(
                          'DA',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'DEMO',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser?.displayName ?? 'Demo User',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                  Text(
                    currentUser?.isAnonymous == true
                        ? 'Demo session — your data is saved in the cloud'
                        : 'Sandbox session — nothing here is saved',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _buildInfoCard(context, isDark, currentUser),
            const SizedBox(height: 16),
            _buildSettingsCard(context),
            const SizedBox(height: 16),
            _buildSignUpCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark, AppUser? currentUser) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Text(
                  'Profile Information',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(context, 'Full Name', currentUser?.displayName ?? 'Demo User'),
            _infoRow(context, 'Email', currentUser?.email?.isNotEmpty == true ? currentUser!.email : 'Anonymous'),
            _infoRow(context, 'Role', currentUser?.isAdmin == true ? 'Admin (Demo)' : 'Staff (Demo)'),
            _infoRow(context, 'Status', currentUser?.isAnonymous == true ? 'Demo account — upgrade to save' : 'Sandbox — not a real account'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white60 : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.white.withValues(alpha: 0.87) : Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Text(
                  'Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _lockedOption(
              context,
              icon: Icons.notifications,
              title: 'Notifications',
              iconColor: isDark ? Colors.amber[300] : Colors.amber[700],
            ),
            _lockedOption(
              context,
              icon: Icons.security,
              title: 'Security',
              iconColor: isDark ? Colors.orange[300] : Colors.orange[700],
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.blue[300]! : Colors.blue[700]!)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.help,
                    color: isDark ? Colors.blue[300] : Colors.blue[700]),
              ),
              title: Text(
                'Help & Support',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16, color: isDark ? Colors.white54 : Colors.grey[600]),
              onTap: () => Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const HelpSupportScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lockedOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Theme.of(context).primaryColor).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.grey[800],
        ),
      ),
      trailing: Icon(Icons.lock_outline,
          size: 18, color: isDark ? Colors.white38 : Colors.grey[400]),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title is disabled in the demo — contact us to get started.'),
            action: SnackBarAction(
              label: 'Get started',
              onPressed: () => ConsultationUtils.showConsultationDialog(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignUpCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Like what you see?',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Contact us to get started with your own inventory, invite staff, and get real stock alerts.',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => ConsultationUtils.showConsultationDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Get started',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DemoExitedScreen()),
                ),
                child: Text(
                  'Exit Demo',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
