import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:seeking/main.dart';

class MyAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  ConcatenatingAudioSource? _playlist;

  MyAudioHandler() {
    _player.playbackEventStream.listen(_broadcastState);
    _player.positionStream.listen((p) =>
        playbackState.add(playbackState.value.copyWith(updatePosition: p)));
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) stop();
    });
    _player.currentIndexStream.listen((index) {
      if (index != null && _playlist != null && index < _playlist!.length) {
        final q = queue.value;
        if (index < q.length) mediaItem.add(q[index]);
      }
    });
    _setupAudioSession();
  }

  Future<void> _setupAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 3],
      processingState: {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    ));
  }

  Future<void> setPlaylist(List<MediaItem> items) async {
    if (items.isEmpty) return;
    _playlist = ConcatenatingAudioSource(
      children: items.map((i) => AudioSource.file(File(i.id))).toList(),
    );
    await _player.setAudioSource(_playlist!);
    queue.add(items);
    mediaItem.add(items.first);
    await _player.play();
  }

  Future<void> playFile(MediaItem item) async {
    await _player.setAudioSource(AudioSource.file(File(item.id)));
    queue.add([item]);
    mediaItem.add(item);
    await _player.play();
  }

  @override Future<void> play() => _player.play();
  @override Future<void> pause() => _player.pause();
  @override Future<void> seek(Duration position) => _player.seek(position);
  @override Future<void> stop() async { await _player.stop(); await super.stop(); }
  @override Future<void> skipToNext() async { if (_player.hasNext) await _player.seekToNext(); }
  @override Future<void> skipToPrevious() async { if (_player.hasPrevious) await _player.seekToPrevious(); }
  @override Future<void> onTaskRemoved() async { await _player.dispose(); await super.onTaskRemoved(); }
}

class FileItem {
  final String path;
  final String name;
  const FileItem({required this.path, required this.name});
}

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});
  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  List<FileItem> _playlist = [];
  bool _isLoading = false;

  Future<void> _pickAudioFiles() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final files = result.files
            .where((f) => f.path != null)
            .map((f) => FileItem(path: f.path!, name: f.name))
            .toList();
        setState(() => _playlist = files);
        await audioHandler.setPlaylist(files
            .map((f) => MediaItem(id: f.path, title: f.name, artist: 'Local File'))
            .toList());
      }
    } catch (e) {
      debugPrint('File pick error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music Player')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickAudioFiles,
              icon: Icon(_isLoading ? Icons.hourglass_empty : Icons.folder_open),
              label: Text(_isLoading ? 'Loading...' : 'Pick Audio Files'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
          if (_playlist.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _playlist.length,
                itemBuilder: (_, i) => ListTile(
                  leading: const Icon(Icons.audiotrack),
                  title: Text(_playlist[i].name),
                  onTap: () => audioHandler.playFile(
                    MediaItem(id: _playlist[i].path, title: _playlist[i].name, artist: 'Local File'),
                  ),
                ),
              ),
            )
          else
            const Expanded(
              child: Center(child: Text('No tracks loaded. Tap the button above.')),
            ),
          const SizedBox(height: 16),
          const _NowPlayingCard(),
        ],
      ),
    );
  }
}

class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (_, mediaSnap) {
        final item = mediaSnap.data;
        if (item == null) return const SizedBox.shrink();
        return StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (_, stateSnap) {
            final playing = stateSnap.data?.playing ?? false;
            final position = stateSnap.data?.updatePosition ?? Duration.zero;
            final duration = item.duration ?? Duration.zero;
            final maxMs = duration.inMilliseconds.toDouble();
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.audiotrack, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(item.artist ?? '', style: const TextStyle(fontSize: 12, color: C.hint)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                        iconSize: 32,
                        onPressed: () => playing ? audioHandler.pause() : audioHandler.play(),
                      ),
                      IconButton(icon: const Icon(Icons.stop), onPressed: audioHandler.stop),
                    ],
                  ),
                  Slider(
                    value: maxMs > 0
                        ? position.inMilliseconds.toDouble().clamp(0.0, maxMs)
                        : 0.0,
                    min: 0,
                    max: maxMs > 0 ? maxMs : 1,
                    onChanged: maxMs > 0
                        ? (v) => audioHandler.seek(Duration(milliseconds: v.toInt()))
                        : null,
                    activeColor: C.accentLight,
                    inactiveColor: C.hint,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(icon: const Icon(Icons.skip_previous), onPressed: audioHandler.skipToPrevious),
                      IconButton(icon: const Icon(Icons.skip_next), onPressed: audioHandler.skipToNext),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}