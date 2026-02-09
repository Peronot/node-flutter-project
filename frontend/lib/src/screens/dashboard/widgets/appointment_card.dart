import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/appointment.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  const AppointmentCard({super.key, required this.appointment});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'cancelled':
        return AppColors.danger;
      case 'confirmed':
      case 'checked in':
        return AppColors.primary;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = appointment.scheduledAt != null ? DateFormat.Hm().format(appointment.scheduledAt!) : '--:--';
    final name = appointment.patientName ?? 'Patient #${appointment.patientId ?? '-'}';
    final doctor = appointment.doctorName ?? 'Doctor #${appointment.doctorId ?? '-'}';
    final phone = appointment.phone ?? '';
    final status = appointment.status ?? 'Pending';
    final statusColor = _statusColor(status);

    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: SizedBox(
            width: 60,
            child: Text(time, style: Theme.of(context).textTheme.titleMedium),
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(phone, style: const TextStyle(color: AppColors.textLight)),
          trailing: SizedBox(
            width: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    doctor,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textLight)
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textLight),
                )
              ],
            ),
          ),
        ),
        const Divider(height: 1)
      ],
    );
  }
}
