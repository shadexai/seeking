import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:seeking/main.dart';
import 'package:seeking/db_helper.dart';

class NewIdeaScreen extends StatefulWidget {
  const NewIdeaScreen({super.key});
  @override
  State<NewIdeaScreen> createState() => _NewIdeaScreenState();
}

class _NewIdeaScreenState extends State<NewIdeaScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _tagsCtrl;
  late String _category;
  late int _mood;
  Idea? _idea;
  bool _saving = false;

  final List<String> _categories = [
    'Business', 'Creative', 'Tech', 'Personal', 'Random'
  ];
  final List<String> _moodEmojis = ['😴', '🤔', '💡', '🔥', '🚀'];
  final List<String> _moodLabels = ['Sleepy', 'Thinking', 'Inspired', 'On Fire', 'Rocket'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _idea = ModalRoute.of(context)?.settings.arguments as Idea?;
    _titleCtrl = TextEditingController(text: _idea?.title ?? '');
    _descCtrl = TextEditingController(text: _idea?.description ?? '');
    _tagsCtrl = TextEditingController(text: _idea?.tags.join(', ') ?? '');
    _category = _idea?.category ?? 'Creative';
    _mood = _idea?.mood ?? 3;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (_idea != null) {
      _idea!
        ..title = _titleCtrl.text.trim()
        ..description = _descCtrl.text.trim()
        ..category = _category
        ..tags = tags
        ..mood = _mood;
      await DBHelper.updateIdea(_idea!);
    } else {
      await DBHelper.insertIdea(Idea(
        id: const Uuid().v4(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _category,
        tags: tags,
        mood: _mood,
        pinned: false,
        createdAt: DateTime.now(),
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_idea != null ? 'Edit Idea' : 'New Idea'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save',
                  style: TextStyle(color: C.accentLight, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleCtrl,
              autofocus: _idea == null,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Idea title...',
                fillColor: C.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe your idea...',
                fillColor: C.card,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category
            const Text('Category',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: C.textSecondary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((c) {
                final selected = _category == c;
                return GestureDetector(
                  onTap: () => setState(() => _category = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? C.accent : C.card,
                      borderRadius: BorderRadius.circular(20),
                      border: selected
                          ? null
                          : Border.all(color: C.hint.withOpacity(0.3)),
                    ),
                    child: Text(c,
                        style: TextStyle(
                            color: selected ? Colors.white : C.textSecondary,
                            fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Mood
            const Text('Mood',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: C.textSecondary)),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (i) {
                final selected = _mood == i + 1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _mood = i + 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? C.accent.withOpacity(0.2) : C.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? C.accent : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(_moodEmojis[i],
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(_moodLabels[i],
                              style: TextStyle(
                                  fontSize: 9,
                                  color:
                                      selected ? C.accentLight : C.hint)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Tags
            const Text('Tags',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: C.textSecondary)),
            const SizedBox(height: 10),
            TextField(
              controller: _tagsCtrl,
              decoration: InputDecoration(
                hintText: 'flutter, startup, design...',
                helperText: 'Separate with commas',
                helperStyle: const TextStyle(color: C.hint, fontSize: 11),
                prefixIcon:
                    const Icon(Icons.tag, color: C.hint, size: 18),
                fillColor: C.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: C.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _idea != null ? 'Update Idea' : 'Save Idea',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
