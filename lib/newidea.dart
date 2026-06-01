import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:seeking/main.dart';

part 'newidea.g.dart';

@HiveType(typeId: 0)
class Idea extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late String category;

  @HiveField(4)
  late List<String> tags;

  @HiveField(5)
  late int mood;

  @HiveField(6)
  late bool pinned;

  @HiveField(7)
  late DateTime createdAt;
}

class NewIdeaScreen extends StatefulWidget {
  const NewIdeaScreen({super.key});
  @override
  State<NewIdeaScreen> createState() => _NewIdeaScreenState();
}

class _NewIdeaScreenState extends State<NewIdeaScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _tagsController;
  late String _category;
  late int _mood;
  Idea? _idea;

  final List<String> _categories = ['Business', 'Creative', 'Tech', 'Personal', 'Random'];
  final List<String> _moodEmojis = ['😴', '🤔', '💡', '🔥', '🚀'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _idea = ModalRoute.of(context)?.settings.arguments as Idea?;
    _titleController = TextEditingController(text: _idea?.title ?? '');
    _descController = TextEditingController(text: _idea?.description ?? '');
    _tagsController = TextEditingController(text: _idea?.tags.join(', ') ?? '');
    _category = _idea?.category ?? 'Creative';
    _mood = _idea?.mood ?? 3;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;
    final box = Hive.box<Idea>('ideas');
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (_idea != null) {
      _idea!
        ..title = _titleController.text.trim()
        ..description = _descController.text.trim()
        ..category = _category
        ..tags = tags
        ..mood = _mood;
      _idea!.save();
    } else {
      box.add(Idea()
        ..id = const Uuid().v4()
        ..title = _titleController.text.trim()
        ..description = _descController.text.trim()
        ..category = _category
        ..tags = tags
        ..mood = _mood
        ..pinned = false
        ..createdAt = DateTime.now());
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_idea != null ? 'Edit Idea' : 'New Idea')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            const Text('Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _categories
                  .map((c) => ChoiceChip(
                        label: Text(c),
                        selected: _category == c,
                        onSelected: (_) => setState(() => _category = c),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('Mood'),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) => Expanded(
                child: InkWell(
                  onTap: () => setState(() => _mood = i + 1),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _mood == i + 1 ? C.accent.withOpacity(0.2) : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _mood == i + 1 ? C.accent : Colors.transparent,
                      ),
                    ),
                    child: Center(
                      child: Text(_moodEmojis[i], style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                ),
              )),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: C.accent,
                  foregroundColor: Colors.white,
                ),
                child: Text(_idea != null ? 'Update' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}