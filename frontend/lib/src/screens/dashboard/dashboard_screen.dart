import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/appointment.dart';
import '../../services/api_client.dart';
import '../../services/appointment_service.dart';
import '../../state/session.dart';
import '../auth/login_screen.dart';
import '../tables/table_screen.dart';
import 'widgets/sidebar.dart';
import 'widgets/appointment_card.dart';
// stat_card unused now
import 'widgets/mini_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final AppointmentService _appointmentService;
  bool _loading = true;
  bool _statsLoading = true;
  List<AppointmentModel> _appointments = const [];
  List<int> _weekdayCounts = List.filled(7, 0);
  int _patientsCount = 0;
  int _appointmentsCount = 0;
  int _treatmentsCount = 0;
  int _paymentsCount = 0;
  double _revenue = 0;
  String _active = 'dashboard';
  Map<String, dynamic>? _activeTable; // holds endpoint/config when a menu item is opened
  bool get _isDoctor =>
      (Session.user?.role.toLowerCase() == 'doctor') ||
      (Session.user?.role == '3') ||
      (Session.user?.role == 'Doctor');
  List<NavItem> get _doctorNav => const [
        NavItem(key: 'dashboard', label: 'Dashboard', icon: Icons.dashboard),
        NavItem(key: 'appointment', label: 'Appointments', icon: Icons.event_available),
        NavItem(key: 'treatment', label: 'Treatments', icon: Icons.healing),
        NavItem(key: 'medicalhistory', label: 'Medical Histories', icon: Icons.history),
      ];

  // _activeTitle unused after redesign

  @override
  void initState() {
    super.initState();
    // If no session (e.g., page refresh on web), bounce back to login.
    if (Session.token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return;
    }
    _appointmentService = AppointmentService(ApiClient());
    _load();
    _loadStats();
  }

  Future<void> _load() async {
    try {
      final data = await _appointmentService.list();
      final weekdayCounts = List<int>.filled(7, 0);
      for (final a in data) {
        if (a.scheduledAt != null) {
          final wd = a.scheduledAt!.weekday % 7; // Monday=1 -> index1
          weekdayCounts[wd] += 1;
        }
      }
      if (!mounted) return;
      setState(() {
        _appointments = data;
        _loading = false;
        _weekdayCounts = weekdayCounts;
      });
    } catch (e) {
      if (!mounted) return;
      if (e is UnauthorizedException) {
        Session.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }
      setState(() => _loading = false);
    }
  }

  Future<void> _loadStats() async {
    setState(() => _statsLoading = true);
    try {
      final api = ApiClient();
      final patientsF = api.getList('/patients');
      final appointmentsF = api.getList('/appointments');
      final treatmentsF = api.getList('/treatments');
      final paymentsF = api.getList('/payments');

      final patients = await _safeList(patientsF);
      final appointments = await _safeList(appointmentsF);
      final treatments = await _safeList(treatmentsF);
      final payments = await _safeList(paymentsF);

      final revenue =
          payments.fold<double>(0, (sum, p) => sum + (double.tryParse((p as Map)['amount']?.toString() ?? '0') ?? 0));
      if (!mounted) return;
      setState(() {
        _patientsCount = patients.length;
        _appointmentsCount = appointments.length;
        _treatmentsCount = treatments.length;
        _paymentsCount = payments.length;
        _revenue = revenue;
        _statsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _statsLoading = false);
    }
  }

  Future<List<dynamic>> _safeList(Future<List<dynamic>> fut) async {
    try {
      return await fut;
    } catch (_) {
      return <dynamic>[];
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
          SizedBox(
            width: 240,
            child: Sidebar(
              activeKey: _active,
              userRole: Session.user?.role ?? 'user',
              userName: Session.user?.fullName ?? 'User',
              items: _isDoctor ? _doctorNav : kDefaultNavItems,
              onSelect: _navigateToTable,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: _activeTable == null
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeaderBar(
                            onLogout: _logout,
                            onMakeAppointment: () => _navigateToTable('appointment'),
                            onAddPatient: () => _navigateToTable('patient'),
                            showAddPatient: !_isDoctor,
                            title: _isDoctor ? 'Doctor Dashboard' : 'Dashboard',
                            subtitle: _isDoctor ? 'Your daily overview' : null,
                          ),
                          const SizedBox(height: 16),
                          _HeroCard(
                            userName: Session.user?.fullName ?? 'User',
                            onViewAppointments: () => _navigateToTable('appointment'),
                            isDoctor: _isDoctor,
                          ),
                          const SizedBox(height: 16),
                          _StatsGrid(
                            loading: _statsLoading,
                            patients: _patientsCount,
                            appointments: _appointmentsCount,
                            treatments: _treatmentsCount,
                            revenue: _revenue,
                            payments: _paymentsCount,
                            isDoctor: _isDoctor,
                          ),
                          const SizedBox(height: 18),
                          _ChartsArea(loading: _loading, weekdayCounts: _weekdayCounts),
                          const SizedBox(height: 18),
                          _AppointmentsSection(
                            appointments: _appointments,
                            loading: _loading,
                            onReload: _load,
                          ),
                        ],
                      ),
                    )
                  : TableScreen(
                      key: ValueKey(_activeTable!['ep']),
                      title: _active,
                      endpoint: _activeTable!['ep'] as String,
                      schemaFields: (_activeTable!['fields'] as List<String>),
                      requiredFields: (_activeTable!['req'] as List<String>?),
                    ),
            ),
          )
        ],
      ),
    );
  }

  void _navigateToTable(String table) {
    setState(() {
      _active = table;
      _activeTable = null;
    });
    if (table == 'dashboard') return;
    final map = _isDoctor
        ? {
            'dashboard': {'ep': '/appointments', 'fields': const <String>[], 'req': const <String>[]},
            'appointment': {
              'ep': '/appointments',
              'fields': const <String>['patient_id', 'doctor_id', 'appointment_date', 'appointment_time', 'status'],
              'req': const <String>['patient_id', 'doctor_id', 'appointment_date', 'appointment_time']
            },
            'treatment': {
              'ep': '/treatments',
              'fields': const <String>['appointment_id', 'doctor_id', 'notes', 'created_at'],
              'req': const <String>['appointment_id', 'doctor_id']
            },
            'patient': {
              'ep': '/patients',
              'fields': const <String>['full_name', 'gender', 'date_of_birth', 'phone', 'address', 'created_at'],
              'req': const <String>['full_name', 'gender', 'date_of_birth']
            },
            'medicalhistory': {
              'ep': '/medical-histories',
              'fields': const <String>['patient_id', 'description', 'created_at'],
              'req': const <String>['patient_id']
            },
          }
        : {
            'allergy': {'ep': '/allergies', 'fields': const <String>['name', 'notes'], 'req': const <String>['name']},
            'appointment': {
              'ep': '/appointments',
              'fields': const <String>['patient_id', 'doctor_id', 'appointment_date', 'appointment_time', 'status'],
              'req': const <String>['patient_id', 'doctor_id', 'appointment_date', 'appointment_time']
            },
            'doctor': {
              'ep': '/doctors',
              'fields': const <String>['full_name', 'specialization', 'phone', 'photo'],
              'req': const <String>['full_name']
            },
            'treatment': {
              'ep': '/treatments',
              'fields': const <String>['appointment_id', 'doctor_id', 'notes', 'created_at'],
              'req': const <String>['appointment_id', 'doctor_id']
            },
            'medicalhistory': {
              'ep': '/medical-histories',
              'fields': const <String>['patient_id', 'description', 'created_at'],
              'req': const <String>['patient_id']
            },
            'invoice': {
              'ep': '/invoices',
              'fields': const <String>['patient_id', 'total', 'status', 'created_at'],
              'req': const <String>['patient_id', 'total']
            },
            'payment': {
              'ep': '/payments',
              'fields': const <String>['invoice_id', 'amount', 'method', 'paid_at', 'status'],
              'req': const <String>['invoice_id', 'amount', 'method']
            },
            'permission': {'ep': '/permissions', 'fields': const <String>['name', 'description'], 'req': const <String>['name']},
            'procedure': {'ep': '/procedures', 'fields': const <String>['name', 'price'], 'req': const <String>['name', 'price']},
            'rolepermission': {
              'ep': '/role-permissions',
              'fields': const <String>['role_id', 'permission_id'],
              'req': const <String>['role_id', 'permission_id']
            },
            'patient': {
              'ep': '/patients',
              'fields': const <String>['full_name', 'gender', 'date_of_birth', 'phone', 'address', 'created_at'],
              'req': const <String>['full_name', 'gender', 'date_of_birth']
            },
            'user': {
              'ep': '/users',
              'fields': const <String>['full_name', 'email', 'password', 'role_id', 'doctor_id', 'created_at'],
              'req': const <String>['full_name', 'email', 'password', 'role_id']
            },
            'userpermission': {
              'ep': '/user-permissions',
              'fields': const <String>['user_id', 'permission_id', 'allow'],
              'req': const <String>['user_id', 'permission_id']
            },
            'roles': {'ep': '/roles', 'fields': const <String>['name'], 'req': const <String>['name']},
            'audit_logs': {'ep': '/audit-logs', 'fields': const <String>['user_id', 'action', 'created_at'], 'req': const <String>['user_id', 'action']},
            'payment_changes': {
              'ep': '/payment-changes',
              'fields': const <String>['payment_id', 'changed_by', 'changes', 'created_at'],
              'req': const <String>['payment_id', 'changed_by', 'changes']
            },
            'refresh_tokens': {
              'ep': '/refresh-tokens',
              'fields': const <String>['user_id', 'token', 'expires_at'],
              'req': const <String>['user_id', 'token', 'expires_at']
            },
          };
    final entry = map[table];
    if (entry == null) return;
    setState(() => _activeTable = entry);
  }
}

class _HeaderBar extends StatelessWidget {
  final VoidCallback onMakeAppointment;
  final VoidCallback onAddPatient;
  final VoidCallback? onLogout;
  final String? title;
  final String? subtitle;
  final bool showAddPatient;
  const _HeaderBar({
    required this.onMakeAppointment,
    required this.onAddPatient,
    this.onLogout,
    this.title,
    this.subtitle,
    this.showAddPatient = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (title != null)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title!, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                if (subtitle != null)
                  Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textLight)),
              ],
            ),
          )
        else
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(150, 44),
            alignment: Alignment.center,
          ),
          onPressed: onMakeAppointment,
          child: const Text('Make Appointment', textAlign: TextAlign.center),
        ),
        const SizedBox(width: 8),
        if (showAddPatient)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              minimumSize: const Size(130, 44),
              alignment: Alignment.center,
            ),
            onPressed: onAddPatient,
            child: const Text('Add Patient', textAlign: TextAlign.center),
          ),
        const SizedBox(width: 8),
        IconButton(onPressed: onLogout, icon: const Icon(Icons.logout))
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String userName;
  final VoidCallback onViewAppointments;
  final bool isDoctor;
  const _HeroCard({required this.userName, required this.onViewAppointments, this.isDoctor = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF3C7DF8), Color(0xFF4AB3FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isDoctor ? 'Doctor Dashboard' : 'Dental Clinic',
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('Welcome back, $userName',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                    isDoctor
                        ? 'Track patients and appointments for today.'
                        : 'Track appointments, patients, and revenue in one place.',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: onViewAppointments,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                'View Appointments',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final bool loading;
  final int patients;
  final int appointments;
  final int treatments;
  final double revenue;
  final int payments;
  final bool isDoctor;
  const _StatsGrid({
    required this.loading,
    required this.patients,
    required this.appointments,
    required this.treatments,
    required this.revenue,
    required this.payments,
    this.isDoctor = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = isDoctor
        ? [
            _StatItem('Appointments', appointments.toString(), Icons.event_available),
            _StatItem('Treatments', treatments.toString(), Icons.healing),
            _StatItem('Payments', payments.toString(), Icons.payment),
          ]
        : [
            _StatItem('Patients', patients.toString(), Icons.person),
            _StatItem('Appointments', appointments.toString(), Icons.event_available),
            _StatItem('Treatments', treatments.toString(), Icons.healing),
            _StatItem('Revenue', '\$${revenue.toStringAsFixed(2)}', Icons.account_balance_wallet),
            _StatItem('Payments', payments.toString(), Icons.payment),
          ];
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.8,
      ),
      itemBuilder: (_, i) {
        final it = items[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: loading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      child: Icon(it.icon, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(it.label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text(it.value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      ],
                    )
                  ],
                ),
        );
      },
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  _StatItem(this.label, this.value, this.icon);
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
