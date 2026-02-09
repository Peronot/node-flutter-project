import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/appointment.dart';
import '../../services/api_client.dart';
import '../../services/appointment_service.dart';
import '../../state/session.dart';
import '../auth/login_screen.dart';
import 'widgets/sidebar.dart';
import 'widgets/appointment_card.dart';
import 'widgets/stat_card.dart';
import 'widgets/mini_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final AppointmentService _appointmentService;
  bool _loading = true;
  List<AppointmentModel> _appointments = const [];
  List<int> _weekdayCounts = List.filled(7, 0);
  int _completed = 0;
  int _urgent = 0;

  @override
  void initState() {
    super.initState();
    _appointmentService = AppointmentService(ApiClient());
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _appointmentService.list();
      final weekdayCounts = List<int>.filled(7, 0);
      int completed = 0;
      int urgent = 0;
      for (final a in data) {
        if (a.scheduledAt != null) {
          final wd = a.scheduledAt!.weekday % 7; // Monday=1 -> index1
          weekdayCounts[wd] += 1;
        }
        final status = (a.status ?? '').toLowerCase();
        if (status == 'confirmed' || status == 'checked in') completed += 1;
        if (status == 'cancelled' || status == 'pending') urgent += 1;
      }
      if (!mounted) return;
      setState(() {
        _appointments = data;
        _loading = false;
        _weekdayCounts = weekdayCounts;
        _completed = completed;
        _urgent = urgent;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _logout() {
    Session.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          const SizedBox(
            width: 240,
            child: Sidebar(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBar(onLogout: _logout),
                  const SizedBox(height: 18),
                  _ChartsArea(loading: _loading, weekdayCounts: _weekdayCounts),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _AppointmentsSection(
                          appointments: _appointments,
                          loading: _loading,
                          onReload: _load,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          StatCard(
                            title: 'Complete appointments',
                            value: _loading ? '--' : '$_completed/${_appointments.length}',
                            progress: _appointments.isEmpty ? 0 : _completed / _appointments.length,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          StatCard(
                            title: 'Urgent appointments',
                            value: _loading ? '--' : '$_urgent/${_appointments.length}',
                            progress: _appointments.isEmpty ? 0 : _urgent / _appointments.length,
                            color: AppColors.danger,
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback? onLogout;
  const _TopBar({this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        IconButton(onPressed: onLogout, icon: const Icon(Icons.logout)),
        const CircleAvatar(
          backgroundImage: AssetImage('assets/avatar_placeholder.png'),
        )
      ],
    );
  }
}

class _ChartsArea extends StatelessWidget {
  final bool loading;
  final List<int> weekdayCounts;
  const _ChartsArea({required this.loading, required this.weekdayCounts});

  @override
  Widget build(BuildContext context) {
    // Placeholder chart area
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            height: 200,
            child: Center(
              child: loading
                  ? const CircularProgressIndicator()
                  : MiniChart(
                      values: weekdayCounts,
                      labels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
                      maxValue: weekdayCounts.isEmpty ? 0 : (weekdayCounts.reduce((a, b) => a > b ? a : b)),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            height: 200,
            child: const Text('Summary widgets go here'),
          ),
        )
      ],
    );
  }
}

class _AppointmentsSection extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final bool loading;
  final Future<void> Function() onReload;
  const _AppointmentsSection({required this.appointments, required this.loading, required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text('Upcoming Appointments (${appointments.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Create New Appointment'),
                )
              ],
            ),
          ),
          const Divider(height: 1),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            )
          else ...[
            if (appointments.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text('No appointments'),
              )
            else
              ...appointments.map(
                (a) => AppointmentCard(appointment: a),
              ),
            TextButton(
              onPressed: onReload,
              child: const Text('Reload'),
            )
          ]
        ],
      ),
    );
  }
}
