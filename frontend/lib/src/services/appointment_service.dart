import '../models/appointment.dart';
import 'api_client.dart';

class AppointmentService {
  AppointmentService(this._api);
  final ApiClient _api;

  Future<List<AppointmentModel>> list() async {
    final data = await _api.getList('/appointments');
    return data.map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
