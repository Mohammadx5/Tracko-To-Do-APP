import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class AddEditScreen extends StatefulWidget {
  final Task? task;
  const AddEditScreen({super.key, this.task});
  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  static const _primary = Color.fromRGBO(255, 184, 3, 1);
  static const _accent = Color.fromRGBO(33, 158, 188, 1);

  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _priority = 'medium';
  String? _deadline;
  bool _clearDeadline = false;
  bool _isSaving = false;

  bool get _isEdit => widget.task != null;

  static const Map<String, Map<String, dynamic>> _pCfg = {
    'high': {
      'label': 'عالية',
      'icon': Icons.keyboard_double_arrow_up_rounded,
      'color': Color(0xFFE53935),
      'bg': Color(0xFFFFEBEE)
    },
    'medium': {
      'label': 'متوسطة',
      'icon': Icons.drag_handle_rounded,
      'color': Color(0xFFF57C00),
      'bg': Color(0xFFFFF3E0)
    },
    'low': {
      'label': 'منخفضة',
      'icon': Icons.keyboard_double_arrow_down_rounded,
      'color': Color(0xFF388E3C),
      'bg': Color(0xFFE8F5E9)
    },
  };

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _ctrl.text = widget.task!.title;
      _priority = widget.task!.priority;
      _deadline = widget.task!.deadline;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline != null ? DateTime.parse(_deadline!) : now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx)
            .copyWith(colorScheme: const ColorScheme.light(primary: _accent)),
        child: child!,
      ),
    );
    if (picked != null)
      setState(() {
        _deadline =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        _clearDeadline = false;
      });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final provider = context.read<TaskProvider>();

    final success = _isEdit
        ? await provider.editTask(
            widget.task!.id, _ctrl.text, _priority, _deadline, _clearDeadline)
        : await provider.addTask(_ctrl.text, _priority, _deadline);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? '✅ تم تحديث المهمة' : '✅ تمت إضافة المهمة'),
        backgroundColor: _accent,
      ));
      Navigator.pop(context);
    } else {
      final err = provider.errorMessage;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), backgroundColor: Colors.red[700]));
        provider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(_isEdit ? 'تعديل المهمة' : 'مهمة جديدة',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon header ────────────────────────
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCEAF8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isEdit ? Icons.edit_note_rounded : Icons.add_task_rounded,
                    color: _accent,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Title ──────────────────────────────
              _label('📝 عنوان المهمة'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ctrl,
                autofocus: true,
                maxLength: 200,
                decoration:
                    _deco('اكتب عنوان المهمة...', Icons.task_alt_rounded),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'الرجاء كتابة عنوان';
                  if (v.trim().length < 2) return 'العنوان قصير جداً';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── Priority ───────────────────────────
              _label('🚦 الأولوية'),
              const SizedBox(height: 10),
              Row(
                children: _pCfg.entries.map((e) {
                  final sel = _priority == e.key;
                  final color = e.value['color'] as Color;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = e.key),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: sel ? color : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: sel ? color : Colors.grey[200]!,
                              width: 1.5),
                          boxShadow: sel
                              ? [
                                  BoxShadow(
                                      color: color.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3))
                                ]
                              : [],
                        ),
                        child: Column(children: [
                          Icon(e.value['icon'] as IconData,
                              color: sel ? Colors.white : color, size: 22),
                          const SizedBox(height: 4),
                          Text(e.value['label'] as String,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      sel ? Colors.white : Colors.grey[600])),
                        ]),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),

              // ── Deadline ───────────────────────────
              _label('📅 الموعد النهائي (اختياري)'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                          color: const Color(0xFFDCEAF8),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.calendar_month_rounded,
                          color: _accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _deadline ?? 'اختر تاريخاً...',
                      style: TextStyle(
                          fontSize: 14,
                          color: _deadline != null ? _accent : Colors.grey[400],
                          fontWeight: _deadline != null
                              ? FontWeight.w600
                              : FontWeight.normal),
                    ),
                    const Spacer(),
                    if (_deadline != null)
                      GestureDetector(
                        onTap: () => setState(() {
                          _deadline = null;
                          _clearDeadline = true;
                        }),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.red, size: 18),
                      ),
                  ]),
                ),
              ),
              const SizedBox(height: 36),

              // ── Save ───────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Icon(_isEdit
                          ? Icons.save_rounded
                          : Icons.add_circle_rounded),
                  label: Text(
                    _isSaving
                        ? 'جاري الحفظ...'
                        : (_isEdit ? 'حفظ التعديلات' : 'إضافة المهمة'),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Cancel ─────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _accent, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  label: const Text('إلغاء',
                      style: TextStyle(
                          fontSize: 18,
                          color: _accent,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF374151)));

  InputDecoration _deco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: _accent),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _accent, width: 2)),
        filled: true,
        fillColor: Colors.white,
      );
}
