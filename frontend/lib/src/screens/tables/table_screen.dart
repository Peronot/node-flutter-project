import 'dart:convert';
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_client.dart';
import '../../state/session.dart';
import '../auth/login_screen.dart';
import '../../widgets/alerts.dart';

class TableScreen extends StatefulWidget {
  final String title;
  final String endpoint; // e.g. '/patients'
  final List<String>? schemaFields; // optional fixed fields when list is empty
  final List<String>? requiredFields; // optional required list

  const TableScreen({
    super.key,
    required this.title,
    required this.endpoint,
    this.schemaFields,
    this.requiredFields,
  });

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  late Future<List<Map<String, dynamic>>> _future;
  final ApiClient _api = ApiClient();
  String _search = '';
  final Map<String, String> _selectionLabels = {};
  final Map<String, TextEditingController> _lookupTextControllers = {};
  final Map<String, List<_LookupOption>> _lookupCache = {};
  final Map<String, Timer?> _lookupTimers = {};
  String _friendlyLabel(String raw) {
    return raw
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    for (final t in _lookupTimers.values) {
      t?.cancel();
    }
    for (final c in _lookupTextControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final list = await _api.getList(widget.endpoint, query: _search.isEmpty ? null : {'search': _search});
    return list.map((e) => (e as Map).map((k, v) => MapEntry(k.toString(), v))).toList();
  }

  Future<List<Map<String, dynamic>>> _loadRoles() async {
    final data = await _api.getList('/roles');
    return data.map((e) => (e as Map).map((k, v) => MapEntry(k.toString(), v))).toList();
  }

  String _fieldType(String f) {
    final lf = f.toLowerCase();
    if (lf == 'id') return 'id';
    if (lf.endsWith('id')) return 'number';
    if (lf.contains('time')) return 'time';
    if (['amount', 'price', 'total', 'qty'].contains(lf)) return 'number';
    if (['allow'].contains(lf)) return 'bool';
    if ([
      'appointment_date',
      'issued_at',
      'paid_at',
      'scheduled_at',
      'date_of_birth',
      'created_at',
      'expires_at'
    ].contains(lf)) {
      return 'date';
    }
    return 'string';
  }

  dynamic _parseValue(String input, String type) {
    switch (type) {
      case 'number':
        final n = num.tryParse(input);
        return n;
      case 'bool':
        return (input == '1' || input.toLowerCase() == 'true') ? 1 : 0;
      case 'time':
        final t = _parseTime(input);
        return t ?? input;
      case 'datetime':
      case 'date':
        final d = _parseDate(input);
        return d != null ? DateFormat('yyyy-MM-dd').format(d) : input;
      default:
        return input;
    }
  }

  DateTime? _parseDate(String input) {
    if (input.isEmpty) return null;
    try {
      // try common formats
      final fmts = ['MM/dd/yyyy', 'yyyy-MM-dd', 'yyyy-MM-ddTHH:mm:ss', 'yyyy-MM-ddTHH:mm:ss.SSSZ'];
      for (final f in fmts) {
        final parsed = DateFormat(f).tryParse(input);
        if (parsed != null) return parsed;
      }
    } catch (_) {}
    return DateTime.tryParse(input);
  }

  String? _parseTime(String input) {
    if (input.isEmpty) return null;
    final fmts = ['h:mm a', 'hh:mm a', 'H:mm', 'HH:mm', 'HH:mm:ss', 'h:mm', 'hh:mm'];
    for (final f in fmts) {
      try {
        final parsed = DateFormat(f).tryParse(input);
        if (parsed != null) {
          return DateFormat('HH:mm:ss').format(parsed);
        }
      } catch (_) {}
    }
    return null;
  }

  String? _rowPath(Map<String, dynamic> row) {
    if (row['id'] != null) return '${widget.endpoint}/${row['id']}';
    if (row['treatment_id'] != null && row['procedure_id'] != null) {
      return '${widget.endpoint}/${row['treatment_id']}/${row['procedure_id']}';
    }
    if (row['treatmentId'] != null && row['procedureId'] != null) {
      return '${widget.endpoint}/${row['treatmentId']}/${row['procedureId']}';
    }
    if (row['invoice_id'] != null && row['procedure_id'] != null) {
      return '${widget.endpoint}/${row['invoice_id']}/${row['procedure_id']}';
    }
    if (row['patient_id'] != null && row['allergy_id'] != null) {
      return '${widget.endpoint}/${row['patient_id']}/${row['allergy_id']}';
    }
    if (row['role_id'] != null && row['permission_id'] != null && widget.endpoint.contains('role-permissions')) {
      return '${widget.endpoint}/${row['role_id']}/${row['permission_id']}';
    }
    if (row['user_id'] != null && row['token'] != null && widget.endpoint.contains('refresh-tokens')) {
      return '${widget.endpoint}/${row['id']}';
    }
    return null;
  }

  String _widgetType(String f) {
    final lf = f.toLowerCase();
    if (lf == 'gender') return 'gender';
    if (lf == 'status' && widget.title == 'appointment') return 'appointment_status';
    if (lf == 'status' && widget.title == 'payment') return 'payment_status';
    if (lf == 'method') return 'payment_method';
    if (lf == 'role_id') return 'role';
    if (['photo', 'image', 'picture', 'avatar'].contains(lf)) return 'photo';
    if (['appointment_date', 'issued_at', 'paid_at', 'scheduled_at', 'date_of_birth', 'created_at', 'expires_at']
        .contains(lf)) {
      return 'date';
    }
    if (_fieldType(f) == 'bool') return 'bool';
    if (lf.contains('time')) return 'time';
    return 'text';
  }

  Widget _buildFieldInput(String f, TextEditingController controller, void Function(VoidCallback fn) setStateDialog,
      {Map<String, TextEditingController>? allControllers}) {
    final wt = _widgetType(f);
    final lf = f.toLowerCase();
    final friendly = _friendlyLabel(f);
    if (lf == 'patient_id') {
      return _lookupField(
        label: 'Patient name',
        controller: controller,
        fieldKey: 'patient_id',
        endpoint: '/patients',
        displayField: 'full_name',
        idField: 'id',
        setStateDialog: setStateDialog,
        hintText: 'Type patient name to search',
      );
    }
    if (lf == 'doctor_id') {
      if (widget.title.toLowerCase() == 'user') {
        final roleId = allControllers?['role_id']?.text;
        if (!_needsDoctor(roleId)) {
          return const SizedBox.shrink();
        }
      }
      return _lookupField(
        label: 'Doctor',
        controller: controller,
        fieldKey: 'doctor_id',
        endpoint: '/doctors',
        displayField: 'full_name',
        idField: 'id',
        setStateDialog: setStateDialog,
        hintText: 'Type doctor name to search',
      );
    }
    if (lf == 'role_id') {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadRoles(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
          if (snap.hasError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Roles load failed: ${snap.error}', style: const TextStyle(color: Colors.red)),
                TextButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                )
              ],
            );
          }
          final roles = snap.data ?? [];
          final current = controller.text.isEmpty ? null : controller.text;
          return DropdownButtonFormField<String>(
            initialValue: current,
            decoration: const InputDecoration(labelText: 'Role'),
            items: roles
                .map(
                  (r) => DropdownMenuItem(
                    value: r['id']?.toString(),
                    child: Text(r['name']?.toString() ?? ''),
                  ),
                )
                .toList(),
            onChanged: (v) {
              controller.text = v ?? '';
              final name = roles.firstWhere(
                (e) => e['id']?.toString() == v,
                orElse: () => {},
              )['name']?.toString();
              if (name != null) _selectionLabels['role_id'] = name;
              allControllers?['doctor_id']?.clear();
              setStateDialog(() {});
            },
          );
        },
      );
    }
    if (widget.title.toLowerCase() == 'payment' && lf == 'invoice_id') {
      return _lookupField(
        label: 'Invoice (patient name)',
        controller: controller,
        fieldKey: 'invoice_id',
        endpoint: '/invoices',
        displayField: 'patient_name',
        idField: 'id',
        displayBuilder: (item) {
          final id = item['id'];
          final patient = item['patient_name'] ?? 'Unknown';
          final total = item['total'] ?? '';
          final status = item['status'] ?? '';
          return '#$id • $patient • $total • $status';
        },
        hintText: 'Qor magaca bukaanka si aad u hesho invoice',
        setStateDialog: setStateDialog,
        onPickItem: (item) {
          final amt = _toDouble(item['total']);
          if (allControllers != null) {
            if (amt != null && allControllers['amount'] != null) {
              allControllers['amount']!.text = amt.toStringAsFixed(2);
            }
            if (allControllers['status'] != null && allControllers['status']!.text.isEmpty) {
              allControllers['status']!.text = (item['status']?.toString().isNotEmpty ?? false)
                  ? item['status'].toString()
                  : 'paid';
            }
            if (allControllers['method'] != null && allControllers['method']!.text.isEmpty) {
              allControllers['method']!.text = 'cash';
            }
            if (allControllers['paid_at'] != null && allControllers['paid_at']!.text.isEmpty) {
              allControllers['paid_at']!.text = DateFormat('MM/dd/yyyy').format(DateTime.now());
            }
          }
        },
      );
    }
    if (widget.title.toLowerCase() == 'payment' && lf == 'amount') {
      return TextField(
        controller: controller,
        readOnly: true,
        decoration: const InputDecoration(labelText: 'Amount (from invoice)'),
      );
    }
    if (lf == 'appointment_id') {
      return _lookupField(
        label: 'Appointment',
        controller: controller,
        fieldKey: 'appointment_id',
        endpoint: '/appointments',
        displayField: 'appointment_date',
        idField: 'id',
        displayBuilder: (item) {
          final id = item['id'];
          final date = item['appointment_date'] ?? '';
          final time = item['appointment_time'] ?? '';
          final status = item['status'] ?? '';
          final patient = item['patient_id'] != null ? 'Patient ${item['patient_id']}' : '';
          return '#$id $date $time $status $patient'.trim().replaceAll(RegExp(r'\s+'), ' ');
        },
        setStateDialog: setStateDialog,
        hintText: 'Search appointment (date / patient)',
      );
    }
    if (wt == 'gender') {
      final current = controller.text.toLowerCase();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(f, style: const TextStyle(fontWeight: FontWeight.w600)),
          Wrap(
            spacing: 12,
            children: [
              ChoiceChip(
                label: const Text('Male'),
                selected: current == 'male',
                onSelected: (_) {
                  controller.text = 'male';
                  setStateDialog(() {});
                },
              ),
              ChoiceChip(
                label: const Text('Female'),
                selected: current == 'female',
                onSelected: (_) {
                  controller.text = 'female';
                  setStateDialog(() {});
                },
              ),
            ],
          )
        ],
      );
    }
    if (wt == 'date') {
      final now = DateTime.now();
      if ((widget.title == 'appointment' && f == 'appointment_date') || f == 'created_at') {
        if (controller.text.isEmpty) {
          controller.text = DateFormat('MM/dd/yyyy').format(now);
        }
      }
      return TextField(
        controller: controller,
        readOnly: true,
        focusNode: _AlwaysDisabledFocusNode(),
        enableInteractiveSelection: false,
        keyboardType: TextInputType.none,
        decoration: InputDecoration(
          labelText: friendly,
          hintText: 'mm/dd/yyyy',
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          final parsed = _parseDate(controller.text);
          final initial = parsed ?? now;
          final picked = await showDatePicker(
            context: context,
            firstDate: widget.title == 'appointment'
                ? DateTime(now.year, now.month, now.day)
                : DateTime(1950),
            lastDate: DateTime(2100),
            initialDate: initial,
          );
          if (!mounted) return;
          if (picked != null) {
            controller.text = DateFormat('MM/dd/yyyy').format(picked);
            setStateDialog(() {});
          }
        },
      );
    }
    if (wt == 'time') {
      return TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: f,
          suffixIcon: const Icon(Icons.access_time),
        ),
        onTap: () async {
          final parsed = _parseTime(controller.text);
          final initial = parsed != null
              ? TimeOfDay(
                  hour: int.tryParse(parsed.split(':')[0]) ?? TimeOfDay.now().hour,
                  minute: int.tryParse(parsed.split(':')[1]) ?? TimeOfDay.now().minute)
              : TimeOfDay.now();
          final picked = await showTimePicker(
            context: context,
            initialTime: initial,
          );
          if (!mounted) return;
          if (picked != null) {
            controller.text = picked.format(context);
            setStateDialog(() {});
          }
        },
      );
    }
    if (wt == 'appointment_status') {
      const options = ['pending', 'booked', 'confirmed', 'cancelled', 'completed'];
      return _dropdownField(f, controller, options, setStateDialog);
    }
    if (wt == 'payment_status') {
      const options = ['paid', 'unpaid', 'pending', 'cancelled'];
      return _dropdownField(f, controller, options, setStateDialog);
    }
    if (wt == 'payment_method') {
      const options = ['cash', 'card', 'transfer', 'mobile', 'other'];
      return _dropdownField(f, controller, options, setStateDialog);
    }
    if (wt == 'role') {
      const options = ['1', '2', '3', '4']; // IDs; ideally populate from roles table
      return _dropdownField(f, controller, options, setStateDialog, labelBuilder: (v) => 'Role $v');
    }
    if (wt == 'photo') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(f, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.upload),
                label: const Text('Choose image'),
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    withData: true,
                  );
                  if (result != null && result.files.isNotEmpty) {
                    final file = result.files.single;
                    final bytes = file.bytes;
                    if (bytes != null) {
                      const maxSize = 512 * 1024; // 0.5MB guard to avoid DB packet limits
                      if (bytes.length > maxSize) {
                        // ignore: use_build_context_synchronously
                        await AlertHelper.error(context, 'Image too large (max 0.5MB). Please choose a smaller file.');
                        return;
                      }
                      final ext = (file.extension ?? '').toLowerCase();
                      final mime = ext.isNotEmpty ? 'image/$ext' : 'image/*';
                      final dataUri = 'data:$mime;base64,${base64Encode(bytes)}';
                      controller.text = dataUri;
                      setStateDialog(() {});
                    }
                  }
                },
              ),
              const SizedBox(width: 12),
              if (controller.text.isNotEmpty)
                Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    SizedBox(width: 6),
                    Text('Selected', style: TextStyle(color: Colors.green)),
                  ],
                )
            ],
          ),
          if (controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(controller.text.split(',').last),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      );
    }
    if (wt == 'bool') {
      final current = controller.text == '1' || controller.text.toLowerCase() == 'true';
      return SwitchListTile(
        title: Text(f),
        value: current,
        onChanged: (v) {
          controller.text = v ? '1' : '0';
          setStateDialog(() {});
        },
        dense: true,
        contentPadding: EdgeInsets.zero,
      );
    }
    // default text / number
    return TextField(
      controller: controller,
      keyboardType: _fieldType(f) == 'number' ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: friendly),
    );
  }

  Widget _dropdownField(String label, TextEditingController controller, List<String> options,
      void Function(VoidCallback fn) setStateDialog, {String Function(String)? labelBuilder}) {
    final current = controller.text.isEmpty ? null : controller.text;
    return DropdownButtonFormField<String>(
      initialValue: current,
      decoration: InputDecoration(labelText: label),
      items: options
          .map((o) => DropdownMenuItem(
                value: o,
                child: Text(labelBuilder != null ? labelBuilder(o) : o),
              ))
          .toList(),
      onChanged: (v) {
        controller.text = v ?? '';
        setStateDialog(() {});
      },
    );
  }

  Widget _lookupField({
    required String label,
    required TextEditingController controller,
    required String fieldKey,
    required String endpoint,
    required String displayField,
    required String idField,
    String Function(Map<String, dynamic> item)? displayBuilder,
    String? hintText,
    void Function(Map<String, dynamic> item)? onPickItem,
    required void Function(VoidCallback fn) setStateDialog,
  }) {
    final selectedName = _selectionLabels[fieldKey];
    final cache = _lookupCache[fieldKey] ?? const <_LookupOption>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Autocomplete<_LookupOption>(
          displayStringForOption: (opt) => opt.label,
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.trim();
            _scheduleLookup(
              fieldKey: fieldKey,
              query: query,
              endpoint: endpoint,
              displayField: displayField,
              idField: idField,
              displayBuilder: displayBuilder,
              setStateDialog: setStateDialog,
            );
            if (query.isEmpty) return cache;
            return cache.where((o) => o.label.toLowerCase().contains(query.toLowerCase()));
          },
          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
            if (_lookupTextControllers[fieldKey] == null) {
              _lookupTextControllers[fieldKey] = textController;
              if (selectedName != null && selectedName.isNotEmpty) {
                textController.text = selectedName;
              }
            } else {
              textController.value = _lookupTextControllers[fieldKey]!.value;
            }
            return TextField(
              controller: textController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: hintText ?? 'Type to search',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                suffixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) {
                // clear selected id when user edits
                controller.text = '';
                _selectionLabels.remove(fieldKey);
                _scheduleLookup(
                  fieldKey: fieldKey,
                  query: v,
                  endpoint: endpoint,
                  displayField: displayField,
                  idField: idField,
                  displayBuilder: displayBuilder,
                  setStateDialog: setStateDialog,
                );
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            final opts = options.toList();
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260, maxWidth: 460),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: opts.length,
                    itemBuilder: (_, i) {
                      final opt = opts[i];
                      return ListTile(
                        title: Text(opt.label),
                        subtitle: Text('ID: ${opt.id}'),
                        onTap: () => onSelected(opt),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: (opt) {
            controller.text = opt.id.toString();
            _selectionLabels[fieldKey] = opt.label;
            final dc = _lookupTextControllers[fieldKey];
            if (dc != null) dc.text = opt.label;
            if (onPickItem != null) {
              onPickItem(opt.raw);
            }
            setStateDialog(() {});
          },
        ),
      ],
    );
  }

  void _scheduleLookup({
    required String fieldKey,
    required String query,
    required String endpoint,
    required String displayField,
    required String idField,
    String Function(Map<String, dynamic> item)? displayBuilder,
    required void Function(VoidCallback fn) setStateDialog,
  }) {
    _lookupTimers[fieldKey]?.cancel();
    _lookupTimers[fieldKey] = Timer(const Duration(milliseconds: 250), () async {
      try {
        final data = await _api.getList(endpoint, query: query.isEmpty ? null : {'search': query});
        final options = data
            .map((e) => (e as Map).map((k, v) => MapEntry(k.toString(), v)))
            .map((item) => _LookupOption(
                  item[idField],
                  displayBuilder != null ? displayBuilder(item) : (item[displayField]?.toString() ?? ''),
                  item,
                ))
            .toList();
        setStateDialog(() {
          _lookupCache[fieldKey] = options;
        });
      } catch (_) {
        // swallow errors; UI already guards with validation
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) {
                setState(() {
                  _search = v;
                  _future = _load();
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            if (snap.error is UnauthorizedException) {
              Session.clear();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              });
              return const Center(child: Text('Unauthorized, redirecting to login...'));
            }
            return Center(
              child: Text(
                'Error: ${snap.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final rows = snap.data ?? [];
          final baseCols = rows.isNotEmpty
              ? rows.first.keys.map((e) => e.toString()).toList()
              : (widget.schemaFields ?? const <String>[]);
          if (baseCols.isEmpty) {
            return const Center(child: Text('No schema available for this table'));
          }
          final columns = [...baseCols];
          columns.add('actions');
          return Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ElevatedButton(
                    onPressed: () => _openCreateDialog(context, baseCols),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 44),
                      alignment: Alignment.center,
                    ),
                    child: const Text('Add New', textAlign: TextAlign.center),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: columns
                          .map((c) => DataColumn(
                                label: Text(
                                  c,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ))
                          .toList(),
                      rows: rows
                          .map((r) => DataRow(
                                cells: columns
                                    .map(
                                      (c) => DataCell(
                                        c == 'actions'
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit, size: 18),
                                                    onPressed: _rowPath(r) != null
                                                        ? () => _openEditDialog(context, baseCols, r)
                                                        : null,
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                                    onPressed: _rowPath(r) != null ? () => _deleteRow(r) : null,
                                                  ),
                                                ],
                                              )
                                            : SizedBox(
                                                width: 140,
                                                child: Text('${r[c] ?? ''}'),
                                              ),
                                      ),
                                    )
                                    .toList(),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openCreateDialog(BuildContext context, List<String> columns) async {
    // Custom flow for invoices so we can pick patient, procedure, qty and auto-create items.
    if (widget.title.toLowerCase() == 'invoice') {
      await _openInvoiceCreateDialog(context);
      return;
    }
    final fields = columns.where((c) => c.toLowerCase() != 'id').toList();
    if (fields.isEmpty) {
      // ignore: use_build_context_synchronously
      await AlertHelper.error(context, 'No fields to create');
      return;
    }
    final controllers = {for (var f in fields) f: TextEditingController()};
    if (widget.title.toLowerCase() == 'payment') {
      controllers['status']?.text = controllers['status']?.text.isNotEmpty == true ? controllers['status']!.text : 'paid';
      controllers['method']?.text = controllers['method']?.text.isNotEmpty == true ? controllers['method']!.text : 'cash';
    }
    if (widget.title.toLowerCase() == 'user') {
      controllers['created_at']?.text = DateFormat('MM/dd/yyyy').format(DateTime.now());
      controllers['password']?.text = controllers['password']?.text.isNotEmpty == true ? controllers['password']!.text : '123456';
    }
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setStateDialog) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Create ${widget.title}'),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: fields
                      .map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildFieldInput(f, controllers[f]!, setStateDialog, allControllers: controllers),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final payload = <String, dynamic>{};
                  for (final f in fields) {
                    final v = controllers[f]!.text;
                    if (v.isNotEmpty) payload[f] = _parseValue(v, _fieldType(f));
                  }
                  if (widget.title.toLowerCase() == 'user' && (payload['password'] == null || payload['password'].toString().isEmpty)) {
                    payload['password'] = '123456';
                  }
                  final req = widget.requiredFields ?? const [];
              final missing = req.where((r) => (payload[r] == null || payload[r].toString().isEmpty)).toList();
              if (missing.isNotEmpty) {
                await AlertHelper.error(dialogContext, 'Missing required: ${missing.join(', ')}');
                return;
              }
              if (widget.title.toLowerCase() == 'user' && _needsDoctor(payload['role_id']?.toString())) {
                if (payload['doctor_id'] == null || payload['doctor_id'].toString().isEmpty) {
                  await AlertHelper.error(dialogContext, 'Doctor profile waa qasab marka role = Doctor');
                  return;
                }
              }
              if (!mounted) return;
              final navigator = Navigator.of(dialogContext);
              navigator.pop();
              try {
                await _api.post(widget.endpoint, payload);
                    if (!context.mounted) return;
                    await AlertHelper.success(context, 'Created successfully');
                    setState(() {
                      _future = _load();
                    });
                  } catch (e) {
                    if (e is UnauthorizedException) {
                      if (!context.mounted) return;
                      Session.clear();
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                      );
                      return;
                    }
                    if (!context.mounted) return;
                    await AlertHelper.error(context, 'Create failed: $e');
                  }
                },
                child: const Text('Save'),
              )
            ],
          );
        },
      ),
    );
  }

  Future<void> _openInvoiceCreateDialog(BuildContext context) async {
    final patientCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    String? selectedProcedureId;
    double? selectedPrice;
    bool saving = false;
    List<Map<String, dynamic>> procedures = [];

    Future<void> loadProcedures([String? search]) async {
      final data = await _api.getList('/procedures', query: search == null || search.isEmpty ? null : {'search': search});
      procedures = data.map((e) => (e as Map).map((k, v) => MapEntry(k.toString(), v))).toList();
      // refresh selected price when list updates
      if (selectedProcedureId != null) {
        final p = procedures.cast<Map<String, dynamic>?>().firstWhere(
          (e) => e?['id'].toString() == selectedProcedureId,
          orElse: () => null,
        );
        selectedPrice = _toDouble(p?['price']);
      }
    }

    await loadProcedures();

    double subtotal() {
      final qty = int.tryParse(qtyCtrl.text) ?? 0;
      if (selectedPrice == null) return 0;
      return _round2((selectedPrice ?? 0) * qty);
    }

    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: !saving,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setStateDialog) {
          return AlertDialog(
            title: const Text('Create Invoice'),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _lookupField(
                    label: 'Patient',
                    controller: patientCtrl,
                    fieldKey: 'patient_id',
                    endpoint: '/patients',
                    displayField: 'full_name',
                    idField: 'id',
                    hintText: 'Type patient name...',
                    setStateDialog: setStateDialog,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedProcedureId,
                    decoration: const InputDecoration(labelText: 'Procedure'),
                    items: procedures
                        .map(
                          (p) => DropdownMenuItem(
                            value: p['id'].toString(),
                            child: Text('${p['name']} (${p['price'] ?? ''})'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      selectedProcedureId = v;
                      final p = procedures.cast<Map<String, dynamic>?>().firstWhere(
                        (e) => e?['id'].toString() == v,
                        orElse: () => null,
                      );
                      selectedPrice = _toDouble(p?['price']);
                      setStateDialog(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    onChanged: (_) => setStateDialog(() {}),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Subtotal: ${subtotal().toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Back'),
              ),
              ElevatedButton(
                onPressed: saving
                    ? null
                    : () async {
                        final patientId = int.tryParse(patientCtrl.text);
                        final procId = int.tryParse(selectedProcedureId ?? '');
                        final qty = int.tryParse(qtyCtrl.text);
                        final sub = subtotal();
                        if (patientId == null) {
                          await AlertHelper.error(dialogContext, 'Fadlan ka dooro bukaanka liiska (magac keliya ha qorin).');
                          return;
                        }
                        if (procId == null) {
                          await AlertHelper.error(dialogContext, 'Fadlan dooro procedure.');
                          return;
                        }
                        if (qty == null || qty < 1) {
                          await AlertHelper.error(dialogContext, 'Quantity must be at least 1');
                          return;
                        }
                        if (selectedPrice == null) {
                          await AlertHelper.error(dialogContext, 'Price lama helin procedure-ka. Xogta procedures-ka hubi.');
                          return;
                        }
                        setStateDialog(() => saving = true);
                        try {
                          final created = await _api.post('/invoices', {
                            'patient_id': patientId,
                            'total': sub,
                            'status': 'unpaid',
                          });
                          final invoiceId = created['id'];
                          await _api.post('/invoice-items', {
                            'invoice_id': invoiceId,
                            'procedure_id': procId,
                            'price': selectedPrice,
                            'qty': qty,
                            'subtotal': sub,
                          });
                          if (!context.mounted) return;
                          Navigator.pop(dialogContext);
                          setState(() {
                            _future = _load();
                          });
                          if (!context.mounted) return;
                          await AlertHelper.success(context, 'Invoice created');
                        } catch (e) {
                          if (context.mounted) {
                            await AlertHelper.error(dialogContext, 'Create failed: $e');
                          }
                          setStateDialog(() => saving = false);
                        }
                      },
                child: saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Create Invoice'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openEditDialog(BuildContext context, List<String> columns, Map<String, dynamic> row) async {
    final path = _rowPath(row);
    if (path == null) {
      await AlertHelper.error(context, 'Cannot edit: missing key');
      return;
    }
    final fields = columns.where((c) => c.toLowerCase() != 'id').toList();
    final controllers = {
      for (var f in fields) f: TextEditingController(text: '${row[f] ?? ''}')
    };
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setStateDialog) {
          return AlertDialog(
            title: Text('Edit ${widget.title} #${row['id']}'),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: fields
                      .map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildFieldInput(f, controllers[f]!, setStateDialog, allControllers: controllers),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (!mounted) return;
                  final navigator = Navigator.of(dialogContext);
                  navigator.pop();
                  final payload = <String, dynamic>{};
                  for (final f in fields) {
                    final text = controllers[f]!.text;
                    if (text.isEmpty) continue;
                    final val = _parseValue(text, _fieldType(f));
                    if (val != null && val.toString().isNotEmpty) {
                      payload[f] = val;
                    }
                  }
                  final req = widget.requiredFields ?? const [];
                  final missing = req.where((r) => (payload[r] == null || payload[r].toString().isEmpty)).toList();
                  if (missing.isNotEmpty) {
                    await AlertHelper.error(dialogContext, 'Missing required: ${missing.join(', ')}');
                    return;
                  }
                  if (widget.title.toLowerCase() == 'user' && _needsDoctor(payload['role_id']?.toString())) {
                    if (payload['doctor_id'] == null || payload['doctor_id'].toString().isEmpty) {
                      await AlertHelper.error(dialogContext, 'Doctor profile waa qasab marka role = Doctor');
                      return;
                    }
                  }
                  try {
                    await _api.put(path, payload);
                    if (!mounted) return;
                    setState(() {
                      _future = _load();
                    });
                    // ignore: use_build_context_synchronously
                    await AlertHelper.success(context, 'Updated successfully');
                  } catch (e) {
                    if (e is UnauthorizedException) {
                      if (!mounted) return;
                      Session.clear();
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (_) => false,
                      );
                      return;
                    }
                    if (!mounted) return;
                    // ignore: use_build_context_synchronously
                    await AlertHelper.error(context, 'Update failed: $e');
                  }
                },
                child: const Text('Save'),
              )
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteRow(Map<String, dynamic> row) async {
    final path = _rowPath(row);
    if (path == null) {
      // ignore: use_build_context_synchronously
      await AlertHelper.error(context, 'Cannot delete: missing key');
      return;
    }
    final confirmed = await AlertHelper.confirm(context, title: 'Delete?', desc: 'Do you want to delete this record?');
    if (!confirmed) return;
    try {
      await _api.delete(path);
      if (!mounted) return;
      setState(() {
        _future = _load();
      });
      await AlertHelper.success(context, 'Deleted successfully');
    } catch (e) {
      if (e.toString().toLowerCase().contains('foreign key')) {
        // ignore: use_build_context_synchronously
        await AlertHelper.error(context, 'Cannot delete: record is referenced by other data (FK constraint).');
        return;
      }
      if (e is UnauthorizedException) {
        if (!mounted) return;
        Session.clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
        return;
      }
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      await AlertHelper.error(context, 'Delete failed: $e');
    }
  }
}

class _AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class _LookupOption {
  final dynamic id;
  final String label;
  final Map<String, dynamic> raw;
  _LookupOption(this.id, this.label, this.raw);
}

double _round2(double v) => (v * 100).roundToDouble() / 100;

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

bool _needsDoctor(String? roleId, [String? roleLabel]) {
  final lbl = roleLabel ?? '';
  if (lbl.toLowerCase().contains('doctor')) return true;
  return roleId == '3'; // default doctor role id fallback
}
