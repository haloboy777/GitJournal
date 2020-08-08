import 'dart:collection';

import 'package:test/test.dart';

import 'package:gitjournal/core/md_yaml_doc.dart';
import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/note_serializer.dart';

void main() {
  group('Note Serializer Test', () {
    test('Test emojis', () {
      var props = LinkedHashMap<String, dynamic>.from(
          <String, dynamic>{"title": "Why not :coffee:?"});
      var doc = MdYamlDoc("I :heart: you", props);

      var serializer = NoteSerializer.raw();
      serializer.settings.saveTitleAsH1 = false;

      var note = Note(null, "file-path-not-important");
      serializer.decode(doc, note);

      expect(note.body, "I ❤️ you");
      expect(note.title, "Why not ☕?");

      note.body = "Why not ☕?";
      note.title = "I ❤️ you";

      serializer.encode(note, doc);
      expect(doc.body, "Why not :coffee:?");
      expect(doc.props['title'].toString(), "I :heart: you");
    });

    test('Test Title Serialization', () {
      var props = <String, dynamic>{};
      var doc = MdYamlDoc("# Why not :coffee:?\n\nI :heart: you", props);

      var serializer = NoteSerializer.raw();
      serializer.settings.saveTitleAsH1 = true;

      var note = Note(null, "file-path-not-important");
      serializer.decode(doc, note);

      expect(note.body, "I ❤️ you");
      expect(note.title, "Why not ☕?");

      note.body = "Why not ☕?";
      note.title = "I ❤️ you";

      serializer.encode(note, doc);
      expect(doc.body, "# I :heart: you\n\nWhy not :coffee:?");
      expect(doc.props.length, 0);
    });

    test('Test Title Reading with blank lines', () {
      var props = <String, dynamic>{};
      var doc = MdYamlDoc("\n# Why not :coffee:?\n\nI :heart: you", props);

      var serializer = NoteSerializer.raw();

      var note = Note(null, "file-path-not-important");
      serializer.decode(doc, note);

      expect(note.body, "I ❤️ you");
      expect(note.title, "Why not ☕?");
    });

    test('Test Title Reading with blank lines and no body', () {
      var props = <String, dynamic>{};
      var doc = MdYamlDoc("\n# Why not :coffee:?", props);

      var serializer = NoteSerializer.raw();

      var note = Note(null, "file-path-not-important");
      serializer.decode(doc, note);

      expect(note.body.length, 0);
      expect(note.title, "Why not ☕?");
    });

    test('Test Old Title Serialization', () {
      var props = LinkedHashMap<String, dynamic>.from(
          <String, dynamic>{"title": "Why not :coffee:?"});
      var doc = MdYamlDoc("I :heart: you", props);

      var serializer = NoteSerializer.raw();
      serializer.settings.saveTitleAsH1 = true;

      var note = Note(null, "file-path-not-important");
      serializer.decode(doc, note);

      expect(note.body, "I ❤️ you");
      expect(note.title, "Why not ☕?");

      serializer.encode(note, doc);
      expect(doc.body, "# Why not :coffee:?\n\nI :heart: you");
      expect(doc.props.length, 0);
    });
  });
}
