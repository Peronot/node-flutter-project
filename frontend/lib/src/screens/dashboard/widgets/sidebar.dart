import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sidebar,
      child: Column(
        children: [
          const SizedBox(height: 30),
          _NavTile(icon: Icons.dashboard, label: 'Dashboard', active: true, onTap: () {}),
          _NavTile(icon: Icons.person, label: 'Patients', onTap: () {}),
          _NavTile(icon: Icons.medical_information_outlined, label: 'Doctors', onTap: () {}),
          _NavTile(icon: Icons.calendar_month, label: 'Calendar', onTap: () {}),
          _NavTile(
            icon: Icons.mail_outline,
            label: 'Messages',
            badge: '250',
            onTap: () {},
          ),
          _NavTile(icon: Icons.payment, label: 'Payments', onTap: () {}),
          _NavTile(icon: Icons.bar_chart, label: 'Analytics', onTap: () {}),
          _NavTile(icon: Icons.settings, label: 'Settings', onTap: () {}),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('assets/avatar_placeholder.png'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Amanda Piterson', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      Text('Manager', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white)
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final String? badge;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: active ? 1 : 0.75)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: active ? 1 : 0.85),
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 12)),
              )
          ],
        ),
      ),
    );
  }
}
