import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _primary = Color.fromRGBO(255, 184, 3, 1);
  static const _accent = Color.fromRGBO(33, 158, 188, 1);
  static const _bgColor = Color(0xFFF0F4F8);

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          if (provider.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(provider.errorMessage!),
                backgroundColor: Colors.red[700],
              ));
              provider.clearError();
            });
          }

          return CustomScrollView(
            slivers: [
              // ── Header ───────────────────────────────
              SliverAppBar(
                expandedHeight: 185,
                pinned: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      color: _primary,
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/trackoLogo.png',
                                      width: 34,
                                      height: 34,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Tracko',
                                        style: TextStyle(
                                            fontSize: 34,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('نظّم يومك، حقّق أهدافك ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 18),
                            // Stats
                            Row(
                              children: [
                                _statCard(' ${provider.totalCount}', 'المجموع'),
                                const SizedBox(width: 10),
                                _statCard(' ${provider.doneCount}', 'منجزة'),
                                const SizedBox(width: 10),
                                _statCard(
                                    ' ${provider.pendingCount}', 'قيد التنفيذ'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Section label ─────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.list_alt_rounded,
                          color: _accent, size: 20),
                      const SizedBox(width: 6),
                      Text('قائمة المهام',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _accent)),
                      const Spacer(),
                    ],
                  ),
                ),
              ),

              // ── Loading / Empty / List ─────────────────
              if (provider.isLoading && provider.tasks.isEmpty)
                const SliverFillRemaining(
                  child:
                      Center(child: CircularProgressIndicator(color: _accent)),
                )
              else if (provider.tasks.isEmpty)
                SliverFillRemaining(child: _emptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _taskCard(ctx, provider.tasks[i], provider),
                      childCount: provider.tasks.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),

      // ── FAB ──────────────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goAdd(context),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 5,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text('مهمة جديدة',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }

  // ── Stat card ─────────────────────────────────────────
  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Text(label,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ── Task card ─────────────────────────────────────────
  Widget _taskCard(BuildContext ctx, Task task, TaskProvider provider) {
    final cfg = _pCfg[task.priority]!;
    final pColor = cfg['color'] as Color;
    final pBg = cfg['bg'] as Color;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: _swipeBg(),
      confirmDismiss: (_) => _confirmDelete(ctx, task.title),
      onDismissed: (_) async {
        await provider.deleteTask(task.id);
        if (ctx.mounted) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text('تم حذف "${task.title}"'),
            backgroundColor: Colors.red[400],
          ));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            // ── Left color strip ──────────────────────
            Container(
              width: 5,
              height: 80,
              decoration: BoxDecoration(
                color: task.isDone ? Colors.grey[300] : pColor,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
            ),

            // ── Checkbox ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GestureDetector(
                onTap: () => provider.toggleStatus(task.id),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: task.isDone ? _accent : Colors.transparent,
                    border: Border.all(
                      color: task.isDone ? _accent : Colors.grey[350]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: task.isDone
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16)
                      : null,
                ),
              ),
            ),

            // ── Content ───────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: task.isDone ? Colors.grey[400] : Colors.black87,
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        // Priority tag
                        _tag(
                          icon: cfg['icon'] as IconData,
                          label: cfg['label'] as String,
                          color: task.isDone ? Colors.grey : pColor,
                          bg: task.isDone ? Colors.grey[100]! : pBg,
                        ),
                        // Deadline tag
                        if (task.deadline != null)
                          _tag(
                            icon: Icons.calendar_today_rounded,
                            label: _fmtDate(task.deadline!),
                            color: _isOverdue(task.deadline!) && !task.isDone
                                ? Colors.red[600]!
                                : Colors.blueGrey[500]!,
                            bg: _isOverdue(task.deadline!) && !task.isDone
                                ? Colors.red[50]!
                                : Colors.blueGrey[50]!,
                          ),
                        // Status tag
                        _tag(
                          icon: task.isDone
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          label: task.isDone ? 'منجزة' : 'قيد التنفيذ',
                          color: task.isDone
                              ? Colors.green[600]!
                              : Colors.orange[600]!,
                          bg: task.isDone
                              ? Colors.green[50]!
                              : Colors.orange[50]!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Edit button
            GestureDetector(
              onTap: () => _goEdit(ctx, task),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF2FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_rounded, size: 18, color: _accent),
              ),
            ),

// Delete button
            GestureDetector(
              onTap: () async {
                final confirm = await _confirmDelete(ctx, task.title);
                if (confirm) {
                  await provider.deleteTask(task.id);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text('تم حذف "${task.title}"'),
                      backgroundColor: Colors.red[400],
                    ));
                  }
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8, left: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: Color(0xFFE53935)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(
      {required IconData icon,
      required String label,
      required Color color,
      required Color bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _swipeBg() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red[400],
        borderRadius: BorderRadius.circular(16),
      ),
      child:
          const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
        Text('حذف', style: TextStyle(color: Colors.white, fontSize: 11)),
      ]),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset(
          'assets/icons/trackoLogo2.png',
          width: 72,
          height: 72,
        ),
        const SizedBox(height: 14),
        Text('لا توجد مهام بعد',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: _accent)),
        const SizedBox(height: 6),
        Text('اضغط على + لإضافة أول مهمة',
            style: TextStyle(fontSize: 13, color: _accent)),
      ]),
    );
  }

  bool _isOverdue(String d) {
    try {
      return DateTime.parse(d).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return d;
    }
  }

  Future<void> _goAdd(BuildContext ctx) async {
    await Navigator.push(
        ctx, MaterialPageRoute(builder: (_) => const AddEditScreen()));
    if (mounted) context.read<TaskProvider>().loadTasks();
  }

  Future<void> _goEdit(BuildContext ctx, Task task) async {
    await Navigator.push(
        ctx, MaterialPageRoute(builder: (_) => AddEditScreen(task: task)));
    if (mounted) context.read<TaskProvider>().loadTasks();
  }

  Future<bool> _confirmDelete(BuildContext ctx, String title) async {
    final res = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف المهمة'),
        content: Text('هل تريد حذف\n"$title"؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    return res ?? false;
  }
}
