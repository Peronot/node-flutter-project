import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class Sidebar extends StatelessWidget {
  final void Function(String route)? onSelect;
  final String? activeKey;
  final String userRole;
  final String userName;
  final List<NavItem> items;
  const Sidebar({
    super.key,
    this.onSelect,
    this.activeKey,
    this.userRole = 'user',
    this.userName = 'User',
    List<NavItem>? items,
  }) : items = items ?? _items;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sidebar,
      child: SafeArea(
        child: Column(
          children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 30),
              children: items
                  .where((item) => item.adminOnly ? userRole.toLowerCase() == 'admin' : true)
                  .map(
                    (item) => _NavTile(
                      icon: item.icon,
                      label: item.label,
                      active: activeKey == item.key,
                      onTap: () => onSelect?.call(item.key),
                    ),
                  )
                  .toList(),
            ),
          ),
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
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: AppColors.sidebar),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        userRole,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white)
              ],
            ),
            )
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active ? Colors.white.withValues(alpha: 0.14) : Colors.transparent;
    final fg = Colors.white.withValues(alpha: active ? 1 : 0.82);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: fg),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (active)
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 18,
                )
            ],
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final String key;
  final String label;
  final IconData icon;
  final bool adminOnly;
  const NavItem({required this.key, required this.label, required this.icon, this.adminOnly = false});
}

const _items = [
  NavItem(key: 'dashboard', label: 'Dashboard', icon: Icons.dashboard),
  NavItem(key: 'patient', label: 'Patient', icon: Icons.person),
  NavItem(key: 'appointment', label: 'Appointment', icon: Icons.event_available),
  NavItem(key: 'doctor', label: 'Doctor', icon: Icons.medical_services),
  NavItem(key: 'treatment', label: 'Treatment', icon: Icons.healing),
  NavItem(key: 'medicalhistory', label: 'Medical History', icon: Icons.history),
  NavItem(key: 'invoice', label: 'Invoice', icon: Icons.receipt_long),
  NavItem(key: 'payment', label: 'Payment', icon: Icons.payment),
  // Admin-only
  NavItem(key: 'user', label: 'User', icon: Icons.supervised_user_circle, adminOnly: false),
  NavItem(key: 'userpermission', label: 'UserPermission', icon: Icons.verified_user, adminOnly: true),
  NavItem(key: 'rolepermission', label: 'RolePermission', icon: Icons.admin_panel_settings, adminOnly: true),
  NavItem(key: 'roles', label: 'Roles', icon: Icons.security, adminOnly: true),
  NavItem(key: 'audit_logs', label: 'Audit Logs', icon: Icons.policy, adminOnly: true),
  NavItem(key: 'payment_changes', label: 'Payment Changes', icon: Icons.change_circle, adminOnly: true),
  NavItem(key: 'refresh_tokens', label: 'Refresh Tokens', icon: Icons.vpn_key, adminOnly: true),
  NavItem(key: 'procedure', label: 'Procedure', icon: Icons.science),
];

const List<NavItem> kDefaultNavItems = _items;
