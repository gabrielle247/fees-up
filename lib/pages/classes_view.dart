// lib/pages/classes_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';

// -----------------------------------------------------------------------------
// MODELS
// -----------------------------------------------------------------------------
class ClassSummary {
  final String id;
  final String name;
  final String? grade;
  final int studentCount;
  final String roomNumber;
  final String teacherName;
  final String? teacherId;

  ClassSummary({
    required this.id,
    required this.name,
    this.grade,
    required this.studentCount,
    this.roomNumber = 'TBA',
    this.teacherName = 'No Teacher',
    this.teacherId,
  });
}

class TeacherSimple {
  final String id;
  final String name;
  TeacherSimple({required this.id, required this.name});
}

class StudentSimple {
  final String id;
  final String name;
  final String? grade;
  StudentSimple({required this.id, required this.name, this.grade});
}

// -----------------------------------------------------------------------------
// PROVIDERS
// -----------------------------------------------------------------------------

final teachersProvider = FutureProvider.autoDispose<List<TeacherSimple>>((
  ref,
) async {
  final db = DatabaseService.instance;
  final data = await db.getAllTeachers();
  return data
      .map(
        (e) => TeacherSimple(
          id: e['id'] as String,
          name: e['full_name'] as String,
        ),
      )
      .toList();
});

final classListProvider = FutureProvider.autoDispose<List<ClassSummary>>((
  ref,
) async {
  final db = DatabaseService.instance;
  final classesData = await db.getAllClasses();
  final List<ClassSummary> result = [];

  for (final row in classesData) {
    final classId = row['id'] as String;
    final countRows = await db.rawQuery(
      'SELECT COUNT(*) as c FROM enrollments WHERE class_id = ?',
      [classId],
    );
    final count = Sqflite.firstIntValue(countRows) ?? 0;

    result.add(
      ClassSummary(
        id: classId,
        name: row['name'] as String,
        grade: row['grade'] as String?,
        studentCount: count,
        roomNumber: (row['room_number'] as String?) ?? 'TBA',
        teacherName: (row['teacher_name'] as String?) ?? 'Unassigned',
        teacherId: row['teacher_id'] as String?,
      ),
    );
  }
  result.sort((a, b) => a.name.compareTo(b.name));
  return result;
});

final studentSearchProvider = FutureProvider.autoDispose
    .family<List<StudentSimple>, String>((ref, query) async {
      final db = DatabaseService.instance;
      final sanitizedQuery = '%${query.toLowerCase()}%';
      final rows = await db.rawQuery(
        '''SELECT id, full_name, grade FROM students 
       WHERE lower(full_name) LIKE ? AND is_active = 1 
       LIMIT 20''',
        [sanitizedQuery],
      );
      return rows
          .map(
            (r) => StudentSimple(
              id: r['id'] as String,
              name: r['full_name'] as String,
              grade: r['grade'] as String?,
            ),
          )
          .toList();
    });

final classSearchProvider = StateProvider.autoDispose<String>((ref) => '');

// -----------------------------------------------------------------------------
// CONSTANTS
// -----------------------------------------------------------------------------
const List<String> kAllGrades = [
  'ECD A',
  'ECD B',
  'Grade 1',
  'Grade 2',
  'Grade 3',
  'Grade 4',
  'Grade 5',
  'Grade 6',
  'Grade 7',
  'Form 1',
  'Form 2',
  'Form 3',
  'Form 4',
  'Lower 6',
  'Upper 6',
];

// -----------------------------------------------------------------------------
// UI: CLASSES VIEW (LIST)
// -----------------------------------------------------------------------------
class ClassesView extends ConsumerWidget {
  const ClassesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final classesAsync = ref.watch(classListProvider);
    final searchQuery = ref.watch(classSearchProvider).toLowerCase();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 110.0,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: colorScheme.surfaceContainerHighest,
                child: Icon(Icons.class_, color: colorScheme.primary),
              ),
            ),
            title: Text(
              'Manage Classes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton.filled(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddClassModal(context, ref),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SearchBar(
                  hintText: 'Search class...',
                  hintStyle: WidgetStateProperty.all(
                    TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  textStyle: WidgetStateProperty.all(
                    TextStyle(color: colorScheme.onSurface),
                  ),
                  leading: Icon(
                    Icons.search,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(
                    colorScheme.surfaceContainerHighest,
                  ),
                  onChanged: (val) =>
                      ref.read(classSearchProvider.notifier).state = val,
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          classesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, s) =>
                SliverFillRemaining(child: Center(child: Text('Error: $e'))),
            data: (allClasses) {
              final filtered = allClasses
                  .where((c) => c.name.toLowerCase().contains(searchQuery))
                  .toList();

              if (allClasses.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(
                    onAction: () => _showAddClassModal(context, ref),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _ClassCard(
                    classInfo: filtered[index],
                    onTap: () =>
                        _navigateToUpdate(context, ref, filtered[index]),
                  ),
                  childCount: filtered.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  void _showAddClassModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddClassSheet(ref: ref),
    );
  }

  void _navigateToUpdate(
    BuildContext context,
    WidgetRef ref,
    ClassSummary summary,
  ) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => UpdateClassPage(classSummary: summary),
          ),
        )
        .then((_) => ref.invalidate(classListProvider));
  }
}

// -----------------------------------------------------------------------------
// COMPONENT: Shared Form Content (Styled like RegisterStudentPage)
// -----------------------------------------------------------------------------
class _ClassFormContent extends StatefulWidget {
  final TextEditingController nameCtrl;
  final TextEditingController roomCtrl;
  final TextEditingController? capacityCtrl;
  final TextEditingController? notesCtrl;
  final String? selectedGrade;
  final String? selectedTeacherId;
  final List<StudentSimple> selectedStudents;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<String?> onTeacherChanged;
  final VoidCallback onAddStudent;
  final ValueChanged<String> onRemoveStudent;

  const _ClassFormContent({
    required this.nameCtrl,
    required this.roomCtrl,
    this.capacityCtrl,
    this.notesCtrl,
    required this.selectedGrade,
    required this.selectedTeacherId,
    required this.selectedStudents,
    required this.onGradeChanged,
    required this.onTeacherChanged,
    required this.onAddStudent,
    required this.onRemoveStudent,
  });

  @override
  State<_ClassFormContent> createState() => _ClassFormContentState();
}

class _ClassFormContentState extends State<_ClassFormContent> {
  Future<void> _quickCreateTeacher(WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final createdId = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surface,
        title: const Text("Add New Teacher"),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Full Name",
            hintText: "e.g. Mr. Chidume",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty) {
                final id = await DatabaseService.instance.createTeacher({
                  'full_name': nameCtrl.text.trim(),
                });
                if (ctx.mounted) Navigator.pop(ctx, id);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
    if (createdId != null) {
      ref.invalidate(teachersProvider);
      widget.onTeacherChanged(createdId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // -- UNIFORM STYLE DECORATION (Same as RegisterStudentPage) --
    final standardBoxDecoration = BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.0),
    );

    return Consumer(
      builder: (context, ref, _) {
        final teachersAsync = ref.watch(teachersProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(title: "CLASS DETAILS"),

            _buildTextField(
              controller: widget.nameCtrl,
              label: "Class Name",
              hint: "e.g. Form 4 East",
              decoration: standardBoxDecoration,
              icon: Icons.menu_book_outlined,
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: standardBoxDecoration,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.selectedGrade,
                  isExpanded: true,
                  hint: Text(
                    "Select Grade Level",
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  items: kAllGrades
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: widget.onGradeChanged,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const _SectionHeader(title: "ACADEMIC STAFF"),

            teachersAsync.when(
              loading: () => const LinearProgressIndicator(minHeight: 2),
              error: (_, _) => const Text(
                "Error loading teachers",
                style: TextStyle(color: Colors.red),
              ),
              data: (teachers) {
                if (teachers.isEmpty) {
                  return InkWell(
                    onTap: () => _quickCreateTeacher(ref),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: standardBoxDecoration,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            "Add First Teacher",
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: standardBoxDecoration,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: widget.selectedTeacherId,
                            isExpanded: true,
                            hint: Text(
                              "Select Teacher",
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            items: teachers
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t.id,
                                    child: Text(t.name),
                                  ),
                                )
                                .toList(),
                            onChanged: widget.onTeacherChanged,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => _quickCreateTeacher(ref),
                        icon: Icon(
                          Icons.add,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        tooltip: "Quick Add Teacher",
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: widget.roomCtrl,
                    label: "Room No.",
                    hint: "e.g. 302",
                    decoration: standardBoxDecoration,
                    icon: Icons.meeting_room_outlined,
                  ),
                ),
                if (widget.capacityCtrl != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: widget.capacityCtrl!,
                      label: "Capacity",
                      hint: "30",
                      decoration: standardBoxDecoration,
                      isNumber: true,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionHeader(title: "STUDENTS"),
                Text(
                  "${widget.selectedStudents.length} Assigned",
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            // Student Search Button (Styled like Input)
            GestureDetector(
              onTap: widget.onAddStudent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: standardBoxDecoration,
                child: Row(
                  children: [
                    Icon(
                      Icons.person_search,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Search to enroll student...",
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.add_circle_outline, color: colorScheme.primary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (widget.selectedStudents.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.selectedStudents
                    .map((s) => _buildStudentChip(context, s))
                    .toList(),
              ),

            if (widget.notesCtrl != null) ...[
              const SizedBox(height: 24),
              const _SectionHeader(title: "NOTES"),
              Container(
                decoration: standardBoxDecoration,
                child: TextField(
                  controller: widget.notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Special requirements...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // --- Helper Methods (Matching RegisterStudentPage) ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required BoxDecoration decoration,
    String? hint,
    IconData? icon,
    bool isNumber = false,
  }) {
    return Container(
      decoration: decoration,
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: icon != null
              ? Icon(icon, color: Colors.grey, size: 20)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentChip(BuildContext context, StudentSimple student) {
    final theme = Theme.of(context);
    final initials = student.name.isNotEmpty
        ? student.name[0].toUpperCase()
        : "?";

    return Chip(
      avatar: CircleAvatar(
        backgroundColor: theme.colorScheme.primary,
        child: Text(
          initials,
          style: TextStyle(fontSize: 10, color: theme.colorScheme.onPrimary),
        ),
      ),
      label: Text(student.name, style: const TextStyle(fontSize: 12)),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => widget.onRemoveStudent(student.id),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PAGE: Update Class (Refactored Layout)
// -----------------------------------------------------------------------------
class UpdateClassPage extends ConsumerStatefulWidget {
  final ClassSummary classSummary;
  const UpdateClassPage({super.key, required this.classSummary});

  @override
  ConsumerState<UpdateClassPage> createState() => _UpdateClassPageState();
}

class _UpdateClassPageState extends ConsumerState<UpdateClassPage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _roomCtrl;
  String? _selectedGrade;
  String? _selectedTeacherId;
  final List<StudentSimple> _selectedStudents = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.classSummary.name);
    _roomCtrl = TextEditingController(text: widget.classSummary.roomNumber);
    _selectedGrade = widget.classSummary.grade;
    _selectedTeacherId = widget.classSummary.teacherId;
    if (_selectedGrade != null && !kAllGrades.contains(_selectedGrade)) {
      _selectedGrade = null;
    }
  }

  void _showStudentSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => _StudentSearchDialog(
        onSelect: (student) {
          if (!_selectedStudents.any((s) => s.id == student.id)) {
            setState(() => _selectedStudents.add(student));
          }
        },
      ),
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty) return;
    setState(() => _isSaving = true);
    final db = DatabaseService.instance;
    try {
      final existing = await db.query(
        'classes',
        where: 'name = ? AND id != ?',
        whereArgs: [_nameCtrl.text.trim(), widget.classSummary.id],
      );
      if (existing.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Class name exists!")));
        }
        setState(() => _isSaving = false);
        return;
      }

      await db.update(
        'classes',
        {
          'name': _nameCtrl.text.trim(),
          'room_number': _roomCtrl.text.trim(),
          'grade': _selectedGrade,
          'teacher_id': _selectedTeacherId,
        },
        'id = ?',
        [widget.classSummary.id],
        queueForSync: true,
      );

      for (var s in _selectedStudents) {
        await db.enrollStudentInClass(
          studentId: s.id,
          classId: widget.classSummary.id,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteClass() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Class?"),
        content: const Text("This will unenroll all students."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseService.instance.delete('classes', 'id = ?', [
        widget.classSummary.id,
      ], queueForSync: true);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("Edit Class"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _deleteClass,
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ClassFormContent(
                  nameCtrl: _nameCtrl,
                  roomCtrl: _roomCtrl,
                  selectedGrade: _selectedGrade,
                  selectedTeacherId: _selectedTeacherId,
                  selectedStudents: _selectedStudents,
                  onGradeChanged: (v) => setState(() => _selectedGrade = v),
                  onTeacherChanged: (v) =>
                      setState(() => _selectedTeacherId = v),
                  onAddStudent: _showStudentSearchDialog,
                  onRemoveStudent: (id) => setState(
                    () => _selectedStudents.removeWhere((s) => s.id == id),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Text(
                            "SAVE CHANGES",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGET: Add Class Sheet (Updated Layout)
// -----------------------------------------------------------------------------
class _AddClassSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddClassSheet({required this.ref});

  @override
  State<_AddClassSheet> createState() => _AddClassSheetState();
}

class _AddClassSheetState extends State<_AddClassSheet> {
  final _nameCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _selectedGrade;
  String? _selectedTeacherId;
  final List<StudentSimple> _selectedStudents = [];
  bool _isSaving = false;

  void _showStudentSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => _StudentSearchDialog(
        onSelect: (student) {
          if (!_selectedStudents.any((s) => s.id == student.id)) {
            setState(() => _selectedStudents.add(student));
          }
        },
      ),
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty) return;
    setState(() => _isSaving = true);
    final db = DatabaseService.instance;
    try {
      final existing = await db.query(
        'classes',
        where: 'name = ?',
        whereArgs: [_nameCtrl.text.trim()],
      );
      if (existing.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Class name exists!")));
        }
        setState(() => _isSaving = false);
        return;
      }
      final classId = await db.createClass({
        'name': _nameCtrl.text.trim(),
        'room_number': _roomCtrl.text.trim(),
        'teacher_id': _selectedTeacherId,
        'grade': _selectedGrade,
      }, queueForSync: true);

      for (var s in _selectedStudents) {
        await db.enrollStudentInClass(studentId: s.id, classId: classId);
      }
      if (mounted) {
        Navigator.pop(context);
        widget.ref.invalidate(classListProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  "Add New Class",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _ClassFormContent(
              nameCtrl: _nameCtrl,
              roomCtrl: _roomCtrl,
              capacityCtrl: _capacityCtrl,
              notesCtrl: _notesCtrl,
              selectedGrade: _selectedGrade,
              selectedTeacherId: _selectedTeacherId,
              selectedStudents: _selectedStudents,
              onGradeChanged: (v) => setState(() => _selectedGrade = v),
              onTeacherChanged: (v) => setState(() => _selectedTeacherId = v),
              onAddStudent: _showStudentSearchDialog,
              onRemoveStudent: (id) => setState(
                () => _selectedStudents.removeWhere((s) => s.id == id),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Save Class",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// WIDGET: Helpers
// -----------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StudentSearchDialog extends ConsumerStatefulWidget {
  final Function(StudentSimple) onSelect;
  const _StudentSearchDialog({required this.onSelect});
  @override
  ConsumerState<_StudentSearchDialog> createState() =>
      _StudentSearchDialogState();
}

class _StudentSearchDialogState extends ConsumerState<_StudentSearchDialog> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(studentSearchProvider(_query));
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Search student...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (val) => setState(() => _query = val),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: searchAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const Center(child: Text("Error searching")),
                data: (students) {
                  if (students.isEmpty) {
                    return const Center(child: Text("No students found"));
                  }
                  return ListView.separated(
                    itemCount: students.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: theme.colorScheme.outlineVariant.withAlpha(50),
                    ),
                    itemBuilder: (ctx, i) {
                      final s = students[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text(s.name[0])),
                        title: Text(
                          s.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(s.grade ?? 'No grade'),
                        onTap: () {
                          widget.onSelect(s);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  final ClassSummary classInfo;
  final VoidCallback onTap;
  const _ClassCard({required this.classInfo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visual = _getGradeVisuals(classInfo.grade);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(50)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: visual.color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _getGradeShort(classInfo.grade),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: visual.color,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classInfo.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.meeting_room_outlined,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            classInfo.roomNumber,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              classInfo.teacherName,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.people, size: 14, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${classInfo.studentCount}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAction;
  const _EmptyState({required this.onAction});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.class_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          const Text(
            "No Classes Yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onAction,
            child: const Text("Create Class"),
          ),
        ],
      ),
    );
  }
}

class _GradeVisual {
  final Color color;
  _GradeVisual(this.color);
}

String _getGradeShort(String? grade) {
  if (grade == null) return "?";
  if (grade.toLowerCase().contains("form")) return grade.split(" ").last;
  if (grade.toLowerCase().contains("grade")) return "G${grade.split(" ").last}";
  if (grade.toLowerCase().contains("ecd")) return "E${grade.split(" ").last}";
  if (grade.toLowerCase().contains("lower")) return "L6";
  if (grade.toLowerCase().contains("upper")) return "U6";
  return grade[0].toUpperCase();
}

_GradeVisual _getGradeVisuals(String? gradeName) {
  final lower = (gradeName ?? "").toLowerCase();
  if (lower.contains('ecd')) return _GradeVisual(Colors.teal);
  if (lower.contains('grade 1') || lower.contains('grade 2')) {
    return _GradeVisual(Colors.orange);
  }
  if (lower.contains('grade 3') || lower.contains('grade 4')) {
    return _GradeVisual(Colors.yellow);
  }
  if (lower.contains('grade 5') ||
      lower.contains('grade 6') ||
      lower.contains('grade 7')) {
    return _GradeVisual(Colors.pink);
  }
  if (lower.contains('form 1')) return _GradeVisual(Colors.blue);
  if (lower.contains('form 2')) return _GradeVisual(Colors.indigo);
  if (lower.contains('form 3')) return _GradeVisual(Colors.purple);
  if (lower.contains('form 4')) return _GradeVisual(Colors.deepPurple);
  if (lower.contains('lower 6')) return _GradeVisual(Colors.cyan);
  if (lower.contains('upper 6')) return _GradeVisual(Colors.red);
  return _GradeVisual(Colors.grey);
}
