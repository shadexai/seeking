import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:seeking/main.dart';
import 'package:seeking/newidea.dart';

class IdeasScreen extends StatefulWidget {
  const IdeasScreen({super.key});
  @override
  State<IdeasScreen> createState() => _IdeasScreenState();
}

class _IdeasScreenState extends State<IdeasScreen> {
  final _box = Hive.box<Idea>('ideas');
  String _search = '';
  String _filter = 'All';
  final List<String> _categories = ['All', 'Business', 'Creative', 'Tech', 'Personal', 'Random'];

  List<Idea> get _filteredIdeas {
    var list = _box.values.toList();
    if (_filter != 'All') list = list.where((i) => i.category == _filter).toList();
    if (_search.isNotEmpty) {
      list = list.where((i) =>
          i.title.toLowerCase().contains(_search.toLowerCase()) ||
          i.description.toLowerCase().contains(_search.toLowerCase()) ||
          i.tags.any((t) => t.toLowerCase().contains(_search.toLowerCase()))).toList();
    }
    list.sort((a, b) {
      if (a.pinned && !b.pinned) return -1;
      if (!a.pinned && b.pinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  void _deleteIdea(Idea idea) { idea.delete(); setState(() {}); }
  void _togglePin(Idea idea) { idea.pinned = !idea.pinned; idea.save(); setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final ideas = _filteredIdeas;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ideas Vault'),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/newIdea'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Search ideas...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: C.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => FilterChip(
                      label: Text(_categories[i]),
                      selected: _filter == _categories[i],
                      onSelected: (_) => setState(() => _filter = _categories[i]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ideas.isEmpty
                ? const Center(child: Text('No ideas yet. Tap + to create one.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: ideas.length,
                    itemBuilder: (_, i) => IdeaCard(
                      idea: ideas[i],
                      onDelete: () => _deleteIdea(ideas[i]),
                      onPin: () => _togglePin(ideas[i]),
                      onEdit: () => Navigator.pushNamed(context, '/newIdea', arguments: ideas[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class IdeaCard extends StatelessWidget {
  final Idea idea;
  final VoidCallback onDelete, onPin, onEdit;
  const IdeaCard({
    super.key,
    required this.idea,
    required this.onDelete,
    required this.onPin,
    required this.onEdit,
  });

  static const _moodEmoji = ['', '😴', '🤔', '💡', '🔥', '🚀'];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: C.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onEdit,
        isThreeLine: true,
        leading: Icon(idea.pinned ? Icons.push_pin : Icons.push_pin_outlined, color: C.accentLight),
        title: Row(
          children: [
            Expanded(child: Text(idea.title, style: const TextStyle(fontWeight: FontWeight.bold))),
            Text(_moodEmoji[idea.mood.clamp(1, 5)]),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (idea.description.isNotEmpty)
              Text(idea.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              children: [
                Chip(label: Text(idea.category), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ...idea.tags.map((t) => Chip(
                  label: Text('#$t'),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
            IconButton(
              icon: Icon(idea.pinned ? Icons.push_pin : Icons.push_pin_outlined),
              onPressed: onPin,
            ),
          ],
        ),
      ),
    );
  }
}