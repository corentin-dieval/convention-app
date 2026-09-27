import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/models/convention.dart';
import '../convention_provider.dart';

class ConventionFormScreen extends StatefulWidget {
  final int? conventionId;
  const ConventionFormScreen({super.key, this.conventionId});

  @override
  State<ConventionFormScreen> createState() => _ConventionFormScreenState();
}

class _ConventionFormScreenState extends State<ConventionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _saving = false;

  bool get _isNew => widget.conventionId == null;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    if (!_isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadConvention());
    }
  }

  void _loadConvention() {
    final provider = context.read<ConventionProvider>();
    final c = provider.conventions.firstWhere(
      (c) => c.id == widget.conventionId,
    );
    setState(() {
      _nameCtrl.text = c.name;
      _startDate = c.startDate;
      _endDate = c.endDate;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) return;

    setState(() => _saving = true);
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<ConventionProvider>();

    bool ok;
    if (_isNew) {
      final saved = await provider.addConvention(Convention(
        name: _nameCtrl.text.trim(),
        startDate: _startDate!,
        endDate: _endDate,
      ));
      ok = saved != null;
    } else {
      final existing = provider.conventions.firstWhere(
        (c) => c.id == widget.conventionId,
      );
      ok = await provider.updateConvention(existing.copyWith(
        name: _nameCtrl.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        clearEndDate: _endDate == null,
      ));
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFmt = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l10n.addConvention : l10n.editConvention),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration:
                    InputDecoration(labelText: l10n.conventionName),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.conventionStartDate),
                subtitle: Text(
                  _startDate != null
                      ? dateFmt.format(_startDate!)
                      : '—',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(isStart: true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.conventionEndDate),
                subtitle: Text(
                  _endDate != null ? dateFmt.format(_endDate!) : '—',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_endDate != null)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _endDate = null),
                      ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
                onTap: () => _pickDate(isStart: false),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
